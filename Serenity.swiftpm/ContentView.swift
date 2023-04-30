import SwiftUI

// MARK: - Content View

struct ContentView: View {

    @EnvironmentObject var model: SerenityModel
    
    // MARK: Properties
    
    /// Stored boolean indicating whether the user knows about the swipe feature.
    @AppStorage("isSwipeFeatureKnown") var isSwipeFeatureKnown: Bool = false
    
    /// Boolean indicating whether the indicator is animating.
    @State private var isSwipeDiscoveryAnimating: Bool = false
    
    /// The index of the active view.
    @State private var activeIndex: Int = 0
    
    // MARK: Computed
    
    /// The maximum index of the prevention view's stack.
    var maxIndex: Int {
        Prevention.allCases.count - 1
    }
    
    /// Enumerated array of each prevention view.
    var enumeratedViews: [EnumeratedSequence<[Prevention]>.Element] {
        Array(Prevention.allCases.enumerated())
    }
    
    // MARK: Content
    
    var body: some View {
        if model.isOnboarding {
            OnboardingView()
                .transition(.scaling)
        } else {
            Group {
                switch model.activeView {
                case .breathing:
                    BreathingView()
                case .pomodoro:
                    PomodoroView()
                case .tips:
                    TipsView()
                default:
                    homeView
                }
            }
            .transition(.scaling)
        }
    }
    
    var homeView: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Image("TextIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 48)
                
                Text(Quotes.shared.homeBlurb)
                    .font(._body)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .trailing, spacing: 16) {
                SwipeablePagingStack(index: $activeIndex, maxIndex: maxIndex, axis: .horizontal, spacing: 48) { isDragging in
                    ForEach(enumeratedViews, id: \.offset) { offset, view in
                        let isActive = isActive(offset)
                        
                        PreventionCard(for: view)
                            .blur(radius: isActive || isDragging ? 0 : 4)
                            .opacity(isActive ? 1 : (isDragging ? 0.5 : 0.25))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .onChange(of: isDragging) { newValue in
                        withAnimation(.discoveryAppear) {
                            isSwipeFeatureKnown = true
                        }
                    }
                }
                .blur(radius: !isSwipeFeatureKnown && isSwipeDiscoveryAnimating ? 8 : 0)
                .animation(.discoveryAppear, value: !isSwipeFeatureKnown && isSwipeDiscoveryAnimating)
                .overlay {
                    if !isSwipeFeatureKnown {
                        SwipeDiscovery(axis: .horizontal, travelLength: 256, isAnimating: isSwipeDiscoveryAnimating)
                            .hidden(!isSwipeDiscoveryAnimating)
                            .allowsHitTesting(false)
                    }
                }
                .padding(24)
                .background {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(.secondary, lineWidth: 2)
                }
                .padding(.horizontal, -24)
                .onAppear {
                    showSwipeFeature()
                }
                
                HStack(spacing: 16) {
                    SerenitySecondaryButton("Onboarding", icon: "arrow.left", iconOnly: false) {
                        withAnimation(.screen) {
                            model.isOnboarding = true
                        }
                    }
                    
                    Spacer()
                    
                    SerenityButton("Try it out", icon: "arrow.right") {
                        withAnimation(.screen) {
                            model.activeView = Prevention.allCases[activeIndex]
                        }
                    }
                }
            }
        }
        .frame(maxWidth: K.textContentMaxWidth)
        .padding(.horizontal, 24)
        .padding(24)
    }
    
    // MARK: Function
    
    /// Show the swipe feature for discovery.
    func showSwipeFeature() {
        guard !isSwipeFeatureKnown else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + K.swipeFeatureDiscoveryAppearDelay) {
            isSwipeDiscoveryAnimating = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isSwipeDiscoveryAnimating = false
                showSwipeFeature()
            }
        }
    }
    
    /// Check if the view at the provided index is active.
    /// - Parameter offset: The index of the view.
    /// - Returns: Boolean indicating whether the view is active.
    func isActive(_ offset: Int) -> Bool {
        activeIndex == offset
    }
}

// MARK: - Prevention Card

struct PreventionCard: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var model: SerenityModel
    
    /// The prevention view to display.
    var view: Prevention
    
    // MARK: Properties
    
    /// Boolean indicating whether the button is pressed.
    @State private var isPressed: Bool = false
    
    // MARK: Computed
    
    /// Shortcut to the blurb for this prevention.
    var blurb: String {
        view.quotes.blurb
    }
    
    /// Shortcut to the (optional) benefits of this prevention.
    var benefits: [Quotes.Preventions.Prevention.Benefit]? {
        view.quotes.benefits
    }
    
    /// Optional enumerated benefits array.
    var enumeratedBenefits: [EnumeratedSequence<[Quotes.Preventions.Prevention.Benefit]>.Element]? {
        if let benefits {
            return Array(benefits.enumerated())
        } else {
            return nil
        }
    }
    
    /// Shortcut to the (optional) further reading of this prevention.
    var furtherReading: String? {
        view.quotes.furtherReading
    }
    
    /// The foreground style used in titles.
    var titleStyle: some ShapeStyle {
        LinearGradient(
            gradient: .serenityGreen,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: Init
    
    init(for view: Prevention) {
        self.view = view
    }
    
    // MARK: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    Text(view.title)
                    Spacer()
                    Image(systemName: view.icon)
                        .fontWeight(.semibold)
                        .foregroundStyle(titleStyle)
                }
                .font(.homeTitle)
                
                Text(blurb)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                if let enumeratedBenefits {
                    Text("Benefits")
                        .font(._title)
                    
                    ForEach(enumeratedBenefits, id: \.offset) { offset, benefit in
                        benefitView(for: benefit, at: offset)
                    }
                }
                
                if let furtherReading {
                    Text("Additional information")
                        .font(._title)
                    
                    furtherReadingView(text: furtherReading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    func benefitView(for benefit: Quotes.Preventions.Prevention.Benefit, at offset: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(benefit.title, systemImage: "plus")
                .font(._heading)
                .foregroundStyle(titleStyle)
            
            Text(benefit.body)
                .font(._caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder
    func furtherReadingView(text: String) -> some View {
        Text(text)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
    }
}

// MARK: - Swipe Discovery

struct SwipeDiscovery: View {
    
    @Environment(\.hidden) var hidden
    
    /// The axis to travel along.
    var axis: Axis
    
    /// The travel length of the indicator.
    var travelLength: CGFloat
    
    /// Boolean indicating whether the indicator is animating.
    var isAnimating: Bool
    
    // MARK: Properties
    
    /// Boolean indicating whether the indicator is hidden.
    @State private var isHidden: Bool = true
    
    // MARK: Computed
    
    /// The offset size based on if the indicator is animating.
    private var offset: CGSize {
        let displacement = isAnimating ? -travelLength / 2 : travelLength / 2
        
        switch axis {
        case .horizontal:
            return CGSize(width: displacement, height: 0)
        case .vertical:
            return CGSize(width: 0, height: displacement)
        }
    }
    
    // MARK: Content
    
    var body: some View {
        Circle()
            .fill(Color.accent.opacity(0.5))
            .frame(width: 32, height: 32)
            .opacity(isHidden ? 0 : 1)
            .scaleEffect(isHidden ? 1.5 : 1)
            .offset(offset)
            .animation(.swipeDiscovery, value: isAnimating)
            .onChange(of: hidden) { newValue in
                withAnimation(.discoveryAppear) {
                    isHidden = newValue
                }
            }
    }
}
