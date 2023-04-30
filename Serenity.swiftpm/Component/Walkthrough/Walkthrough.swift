import SwiftUI

// MARK: - Section Protocol

protocol WalkthroughSection {
    
    /// The title of the section.
    var title: String? { get }
    
    /// An array containing the paragraphs of the body within the section.
    var body: [String] { get }
}

// MARK: - Walkthrough

struct Walkthrough: View {
    
    @EnvironmentObject var model: SerenityModel
    
    /// The sections.
    var sections: [WalkthroughSection]
    
    /// The callback to run once finished the walkthrough.
    var onFinished: () -> Void
    
    // MARK: Properties
    
    /// The index of the active section.
    @State private var index: Int = 0
    
    /// The index of the last section that has been presented.
    @State private var currentPresentedIndex: Int = 0
    
    /// Boolean indicating whether the typewriting should be fast-forwarded.
    @State private var shouldFastForward: Bool = false
    
    /// Boolean indicating whether the fast-forward button is showing.
    @State private var isFastForwardShowing: Bool = false
    
    /// Boolean indicating whether the continue button is showing.
    @State private var isContinueShowing: Bool = false
    
    // MARK: Computed
    
    /// The enumerated sections.
    var enumeratedSections: [EnumeratedSequence<[WalkthroughSection]>.Element] {
        Array(sections.enumerated())
    }
    
    // MARK: Init
    
    init(sections: [WalkthroughSection], onFinished: @escaping () -> Void) {
        self.sections = sections
        self.onFinished = onFinished
    }
    
    // MARK: Content
    
    var body: some View {
        VStack(alignment: .trailing, spacing: K.walkthroughSectionParagraphSpacing) {
            SwipeablePagingStack(index: $index, maxIndex: currentPresentedIndex, spacing: K.walkthroughSectionSpacing) { isDragging in
                ForEach(enumeratedSections, id: \.offset) { index, section in
                    if isPresented(index: index) {
                        let isActive = isActive(index: index)
                        
                        let inactiveOpacity: CGFloat = isDragging ? 0.5 : 0.25
                        let inactiveBlur: CGFloat = isDragging ? 0 : 4
                        
                        WalkthroughSectionView(section)
                            .opacity(isActive ? 1.0 : inactiveOpacity)
                            .blur(radius: isActive ? 0 : inactiveBlur)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.pagingStack, value: isActive)
                            .onAppear {
                                guard !shouldFastForward else {
                                    return
                                }
                                
                                showContinueWithDelay(section: section)
                            }
                    }
                }
            }
            .frame(idealWidth: K.textContentMaxWidth, maxWidth: K.textContentMaxWidth)
            .shouldFastForward(shouldFastForward)
            .scrollDisabled(!isContinueShowing)
            .onAppear {
                withAnimation(.buttonAppear.delay(K.fastForwardButtonAppearDelay)) {
                    isFastForwardShowing = true
                }
            }
            
            HStack(spacing: 16) {
                fastForwardButton
                    .hidden(!isFastForwardShowing)
                Spacer()
                continueButton
                    .hidden(!isContinueShowing)
            }
            .frame(maxWidth: K.textContentMaxWidth)
        }
    }
    
    var fastForwardButton: some View {
        SerenitySecondaryButton("Fast-forward", icon: "forward", iconOnly: true) {
            fastForward()
            
            withAnimation(.buttonAppear) {
                isContinueShowing = true
                isFastForwardShowing = false
            }
        }
    }
    
    var continueButton: some View {
        let isLast = isLast(index: index)
        
        return SerenityButton(isLast ? "Finish" : "Continue", icon: isLast ? "sparkles" : "arrow.down") {
            if isLast {
                onFinished()
            } else if index < currentPresentedIndex {
                withAnimation(.pagingStack) { 
                    index += 1
                }
            } else {
                withAnimation(.buttonAppear) {
                    isContinueShowing = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.pagingStack) {
                        currentPresentedIndex += 1
                        index = currentPresentedIndex
                    }
                }
            }
        }
    }
    
    // MARK: Function
    
    /// Check if the view at the provided index has been presented.
    /// - Parameter index: The index of the view.
    /// - Returns: Boolean indicating whether the view has been presented.
    func isPresented(index: Int) -> Bool {
        index <= currentPresentedIndex
    }
    
    /// Check if the view at the provided index is active.
    /// - Parameter index: The index of the view.
    /// - Returns: Boolean indicating whether the view is active.
    func isActive(index: Int) -> Bool {
        index == self.index
    }
    
    /// Check if the section at the provided index is the last one.
    /// - Parameter index: The section's index.
    /// - Returns: Boolean indicating whether the view is last.
    func isLast(index: Int) -> Bool {
        index == sections.count - 1
    }
    
    /// Fast-forwards the current typewriter.
    func fastForward() {
        currentPresentedIndex = sections.count - 1
        shouldFastForward = true
    }
    
    /// Show the continue button after a given delay.
    /// - Parameter section: The section to calculate the delay for.
    func showContinueWithDelay(section: WalkthroughSection) {
        let delay = continueButtonAppearDelay(for: section)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.buttonAppear) {
                isContinueShowing = true
                
                if isLast(index: index) {
                    isFastForwardShowing = false
                }
            }
        }
    }
    
    /// Get the delay time for the continue button's appearance.
    /// - Parameter section: The active and presented section.
    /// - Returns: The delay, in seconds.
    func continueButtonAppearDelay(for section: WalkthroughSection) -> TimeInterval {
        (section.title != nil ? K.walkthroughTitleAppearDelay + TypewriterText.writeTime(for: section.title!) : 0) +
        K.walkthroughBodyAppearDelay +
        TypewriterStack.writeTime(for: section.body) +
        K.walkthroughContinueButtonAppearDelay
    }
}

// MARK: - Walkthrough Section

struct WalkthroughSectionView: View {
    
    /// The walkthrough section.
    var section: WalkthroughSection
    
    // MARK: Init
    
    init(_ section: WalkthroughSection) {
        self.section = section
    }
    
    // MARK: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: K.walkthroughSectionParagraphSpacing) {
            if let title = section.title {
                TypewriterText(title, delayStartBy: titleAppearDelay)
                    .font(.walkthroughTitle)
            }
            
            TypewriterStack(section.body, delayStartBy: bodyAppearDelay, spacing: K.walkthroughSectionParagraphSpacing)
                .font(.walkthroughBody)
        }
    }
    
    // MARK: Delay
    
    /// The delay, in seconds, for the title text's appearance.
    var titleAppearDelay: TimeInterval {
        K.walkthroughTitleAppearDelay
    }
    
    /// The delay, in seconds, for the body text's appearance.
    var bodyAppearDelay: TimeInterval {
        (section.title != nil ? titleAppearDelay + TypewriterText.writeTime(for: section.title ?? "") : 0) +
        K.walkthroughBodyAppearDelay
    }
}
