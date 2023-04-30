import SwiftUI

// MARK: - Typewriter Stack

struct TypewriterStack: View {
    
    @Environment(\.shouldFastForward) var shouldFastForward
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.displayScale) var displayScale
    
    @Environment(\.font) var font
    @Environment(\.multilineTextAlignment) var textAlignment
    
    @Environment(\.scenePhase) var scenePhase
    
    /// Array of paragraphs to show in the stack.
    var paragraphs: [String]
    
    /// The delay, in seconds, to wait before starting the animation.
    var startDelay: TimeInterval
    
    /// The delay, in seconds, to pause between each paragraph.
    var paragraphDelay: TimeInterval
    
    /// The horizontal alignment to align the paragraphs to.
    var alignment: HorizontalAlignment
    
    /// The spacing to include between each paragraph.
    var spacing: CGFloat
    
    // MARK: Properties
    
    /// One optional image that should take the place of the single texts to improve performance.
    @State private var image: UIImage?
    
    /// The total size of the paragraph stack.
    @State private var size: CGSize = .zero
    
    /// Boolean indicating whether the elements in the stack have finished writing.
    @State private var didFinishWriting: Bool = false
    
    // MARK: Computed
    
    /// An enumerated array of strings within the provided content.
    var elements: [EnumeratedSequence<[String]>.Element] {
        Array(paragraphs.enumerated())
    }
    
    // MARK: Init
    
    init(
        _ paragraphs: [String],
        pauseFor pauseDuration: TimeInterval = 0,
        delayStartBy startDelay: TimeInterval = 0,
        alignment: HorizontalAlignment = .leading,
        spacing: CGFloat = 16.0
    ) {
        self.paragraphs = paragraphs
        self.paragraphDelay = pauseDuration
        self.startDelay = startDelay
        
        self.alignment = alignment
        self.spacing = spacing
    }
    
    // MARK: Content
    
    var body: some View {
        if let image {
            Image(uiImage: image)
                .onChange(of: colorScheme) { newScheme in
                    captureView(colorScheme: newScheme)
                }
        } else {
            VStack(alignment: alignment, spacing: spacing) {
                ForEach(elements, id: \.offset) { index, text in
                    let delay = delay(for: index) + paragraphDelay * Double(index) + startDelay
                    TypewriterText(text, delayStartBy: delay, isInStack: true)
                }
            }
            .instantGeometryCapture { geometry in
                // Capture the size of the view
                size = geometry.size
                
                // Capture an image once it's finished writing
                captureOnceNecessary()
            }
            .onChange(of: scenePhase) { newPhase in
                // Generate an image once the app is active, if it has finished writing
                if newPhase == .active, didFinishWriting, image == nil {
                    captureView()
                }
            }
            .onChange(of: didFinishWriting) { didFinish in
                // Once it's finished writing, generate an image if the app is active
                if didFinish, scenePhase == .active {
                    captureView()
                }
            }
            .onChange(of: shouldFastForward) { newValue in
                // Fast-forward the typewriting upon request of a parent view.
                fastForwardIfNecessary(newValue)
            }
            .onAppear {
                fastForwardIfNecessary()
            }
        }
    }
    
    // MARK: Function
    
    @MainActor
    /// Fast-forward this typewriter to its finished state.
    func fastForwardIfNecessary(_ value: Bool = false) {
        if shouldFastForward || value {
            didFinishWriting = true
            captureView()
        }
    }
    
    // MARK: Delay
    
    /// Get the appearance delay for the paragraph at the provided index.
    /// - Parameter index: The index of the paragraph.
    /// - Returns: The delay, in seconds.
    func delay(for index: Int) -> TimeInterval {
        guard index > 0, index < paragraphs.count else {
            return 0
        }
        
        // Get the current paragraph and get its write time
        let paragraph = paragraphs[index]
        let delay = TypewriterText.writeTime(for: paragraph)
        
        return paragraphs[0...index]
            .reduce(0) { partial, string in
                partial + TypewriterText.writeTime(for: string)
            } - delay
    }
}

// MARK: - Image Capture

private extension TypewriterStack {
    
    @ViewBuilder
    /// Create a duplicate of the body in its completed state.
    /// - Parameter size: The size of the view.
    func completedBody(size: CGSize) -> some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(elements, id: \.offset) { index, text in
                let characters = text.map { String($0) }
                let elements = Array(characters.enumerated())
                
                MultilineTextLayout(text: text, textAlignment: textAlignment) {
                    ForEach(elements, id: \.offset) { offset, character in
                        Text(character)
                            .font(font)
                            .fixedSize()
                    }
                }
            }
        }
        .frame(width: size.width, height: size.height)
    }
    
    @MainActor
    /// Capture an image of the typewriter view.
    /// - Parameter colorScheme: An optional color scheme to use.
    func captureView(colorScheme: ColorScheme? = nil) {
        // Duplicate the body in its completed state
        let imageContent = completedBody(size: size)
            .environment(\.colorScheme, colorScheme ?? self.colorScheme)
        
        // Create the image renderer and set the display scale
        let renderer = ImageRenderer(content: imageContent)
        renderer.scale = displayScale
        
        // Set the image value
        self.image = renderer.uiImage
    }
    
    /// Start a timer to determine when it's done writing, then set `didFinishWriting` to true, causing an image capture.
    func captureOnceNecessary() {
        let writeTime = TypewriterStack.writeTime(for: paragraphs) + startDelay + TypewriterStack.delay(paragraphDelay, paragraphs: paragraphs.count)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + writeTime) {
            didFinishWriting = true
        }
    }
}

// MARK: - Static

extension TypewriterStack {
    
    /// Gets the amount of time it would take to write the provided content.
    /// - Parameter content: An array of paragraphs.
    /// - Returns: The time, in seconds.
    static func writeTime(for content: [String]) -> TimeInterval {
        content.reduce(0) { partial, string in
            partial + TypewriterText.writeTime(for: string)
        }
    }
    
    /// Gets the total delay time for the given paragraph count.
    /// - Parameters:
    ///   - paragraphDelay: The delay, in seconds, between each paragraph.
    ///   - paragraphs: The number of paragraphs.
    /// - Returns: The total delay, in seconds.
    static func delay(_ paragraphDelay: TimeInterval, paragraphs: Int) -> TimeInterval {
        paragraphDelay * Double(paragraphs - 1)
    }
}

// MARK: - Extension

extension TypewriterText {
    
    fileprivate init(_ fullText: String, delayStartBy startDelay: TimeInterval = 0, isInStack: Bool) {
        self.init(fullText, delayStartBy: startDelay)
        self.isInStack = isInStack
    }
}
