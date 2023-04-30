import SwiftUI

// MARK: - Typewriter Text

struct TypewriterText: View {
    
    @Environment(\.shouldFastForward) var shouldFastForward
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.displayScale) var displayScale
    
    @Environment(\.font) var font
    @Environment(\.multilineTextAlignment) var textAlignment
    
    @Environment(\.scenePhase) var scenePhase
    
    /// The full text to display.
    let fullText: String
    
    /// The delay, in seconds, to wait before starting the animation.
    var startDelay: TimeInterval
    
    /// Array containing the offsets and delay times for each punctuation character within the string.
    var delays: [(offset: Int, delay: TimeInterval)]
    
    /// Boolean indicating whether this view is within a stack.
    var isInStack: Bool = false
    
    // MARK: Properties
    
    /// Boolean indicating whether the text should be visible.
    @State private var isVisible: Bool = false
    
    /// One optional image that should take the place of the single texts to improve performance.
    @State private var image: UIImage?
    
    /// The total size of the paragraph stack.
    @State private var size: CGSize = .zero
    
    /// Boolean indicating whether the elements in the stack have finished writing.
    @State private var didFinishWriting: Bool = false
    
    // MARK: Computed
    
    /// An enumerated array of stringified characters within the provided full text.
    var elements: [EnumeratedSequence<[String]>.Element] {
        let characters = fullText.map { String($0) }
        return Array(characters.enumerated())
    }
    
    // MARK: Init
    
    init(_ fullText: String, delayStartBy startDelay: TimeInterval = 0) {
        self.fullText = fullText
        self.startDelay = startDelay
        self.delays = []
        
        elements.forEach { offset, element in
            if let delay = Self.punctuationDelay(for: element) {
                let newElement = (offset, delay)
                delays.append(newElement)
            }
        }
    }
    
    // MARK: Content
    
    var body: some View {
        if let image {
            Image(uiImage: image)
                .onChange(of: colorScheme) { newScheme in
                    captureView(colorScheme: newScheme)
                }
        } else {
            MultilineTextLayout(text: fullText, textAlignment: textAlignment) {
                ForEach(elements, id: \.offset) { offset, character in
                    let delay = delay(at: offset)
                    
                    Text(character)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .scaleEffect(isVisible ? 1.0 : 0.5)
                        .fixedSize()
                        .animation(.typewriter.delay(delay), value: isVisible)
                }
            }
            .if(!isInStack) { $0
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
                    // Fast-forward the typewriting if a parent requested it.
                    fastForwardIfNecessary()
                }
            }
            .onAppear {
                isVisible.toggle()
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
    
    /// Get the delay at the provided character offset.
    /// - Parameter offset: The character offset.
    /// - Returns: The delay, in seconds, based on the character and if it is a punctuation character.
    func delay(at offset: Int) -> TimeInterval {
        Self.characterDelay * Double(offset) +
        punctuationDelay(at: offset) +
        startDelay
    }
    
    /// Get the delay for the character at the provided offset if it is valid punctuation.
    /// - Parameter offset: The character offset.
    /// - Returns: The delay, in seconds.
    func punctuationDelay(at offset: Int) -> TimeInterval {
        let filtered = delays.filter { offset > $0.offset }
        return filtered.reduce(0) { $0 + $1.delay }
    }
}

// MARK: - Static

extension TypewriterText {
    
    /// The delay, in seconds, between each added character.
    static var characterDelay: TimeInterval = 0.02
    
    /// The delay, in seconds, for the provided character if it is valid punctuation.
    static func punctuationDelay(for character: String) -> TimeInterval? {
        switch character {
        case "-", "–", "—":
            return 0.1
        case ",", ";", ":":
            return 0.5
        case ".", "!", "?":
            return 1.0
        default:
            return nil
        }
    }
    
    /// Gets the amount of time it would take to write the provided text.
    /// - Parameter text: The text.
    /// - Returns: The time, in seconds.
    static func writeTime(for text: String) -> TimeInterval {
        let delays = text
            .map { String($0) }
            .reduce(0) { $0 + (punctuationDelay(for: $1) ?? 0) }
        
        return Self.characterDelay * Double(text.count - 1) + delays
    }
}

// MARK: - Image Capture

private extension TypewriterText {
    
    @ViewBuilder
    /// Create a duplicate of the body in its completed state.
    /// - Parameter size: The size of the view.
    func completedBody(size: CGSize) -> some View {
        MultilineTextLayout(text: fullText, textAlignment: textAlignment) {
            ForEach(elements, id: \.offset) { offset, character in
                Text(character)
                    .font(font)
                    .fixedSize()
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
        let writeTime = TypewriterText.writeTime(for: fullText) + startDelay
        
        DispatchQueue.main.asyncAfter(deadline: .now() + writeTime) {
            didFinishWriting = true
        }
    }
}

// MARK: - Environment

struct FastForwardEnvironmentKey: EnvironmentKey {
    
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    
    /// Boolean indicating whether a typewriter (if any) should fast-forward.
    var shouldFastForward: Bool {
        get { self[FastForwardEnvironmentKey.self] }
        set { self[FastForwardEnvironmentKey.self] = newValue }
    }
}

extension View {
    
    /// Make any typewriters within the environment will be fast-forwarded, if possible.
    /// - Parameter value: Boolean indicating whether typewriting should fast forward.
    func shouldFastForward(_ value: Bool) -> some View {
        environment(\.shouldFastForward, value)
    }
}

// MARK: - Extension

extension Animation {
    
    /// The animation to use for the typewritten text.
    fileprivate static var typewriter: Animation {
        .interpolatingSpring(mass: 2.0, stiffness: 400, damping: 25, initialVelocity: 0.75)
    } 
}
