import SwiftUI

// MARK: - Prevention Container

struct PreventionContainer<Content>: View where Content: View {
    
    @EnvironmentObject var model: SerenityModel
    
    /// The prevention view that is being displayed.
    var prevention: Prevention
    
    /// The content to show within the container.
    var content: () -> Content
    
    // MARK: Properties
    
    /// Boolean indicating whether the child views prefer a minimized title.
    @State private var titleVisibility: PreventionTitleVisibility = .identity
    
    // MARK: Computed
    
    /// Boolean indicating whether the prevention has a walkthrough.
    var hasWalkthrough: Bool {
        prevention.walkthrough != nil
    }
    
    /// Boolean indicating whether the walkthrough has been read.
    var didReadWalkthrough: Bool {
        switch prevention {
        case .breathing:
            return model.didFinishBreathingWalkthrough
        case .pomodoro:
            return model.didFinishPomodoroWalkthrough
        case .tips:
            return model.didFinishTipsWalkthrough
        }
    }
    
    // MARK: Init
    
    init(for prevention: Prevention, @ViewBuilder content: @escaping () -> Content) {
        self.prevention = prevention
        self.content = content
    }
    
    // MARK: Content
    
    var body: some View {
        if didReadWalkthrough || !hasWalkthrough {
            ZStack {
                content()
                    .frame(maxWidth: K.textContentMaxWidth)
                    .onPreferenceChange(PreventionTitlePreferenceKey.self) { value in
                        withAnimation(.screen) {
                            titleVisibility = value
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topLeading) {
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        SerenitySecondaryButton("Back", icon: "xmark") {
                            withAnimation(.screen) {
                                model.activeView = .none
                            }
                        }
                        
                        if hasWalkthrough {
                            SerenitySecondaryButton("Learn again", icon: "rectangle.and.text.magnifyingglass", iconOnly: false) {
                                withAnimation(.screen) {
                                    setDidReadWalkthrough(to: false)
                                }
                            }
                        }
                    }
                    
                    if titleVisibility == .minimized {
                        Text(prevention.title)
                            .font(.minimizedPreventionTitle)
                            .textCase(.uppercase)
                            .transition(.minimizedPreventionTitle)
                    }
                }
                .padding(.leading, 24)
                .padding(.top, 16)
            }
            .transition(.scaling)
        } else {
            Walkthrough(sections: prevention.walkthrough!) {
                withAnimation(.screen) {
                    setDidReadWalkthrough(to: true)
                }
            }
            .transition(.scaling)
        }
    }
    
    // MARK: Function
    
    /// Set the `didFinishWalkthrough` property of the model based on the displayed prevention.
    /// - Parameter toggle: Boolean indicating whether the walkthrough has been read.
    func setDidReadWalkthrough(to toggle: Bool) {
        switch prevention {
        case .breathing:
            model.didFinishBreathingWalkthrough = toggle
        case .pomodoro:
            model.didFinishPomodoroWalkthrough = toggle
        case .tips:
            model.didFinishTipsWalkthrough = toggle
        }
    }
}

// MARK: - Title Modifier

struct PreventionTitleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.preventionTitle)
            .textCase(.uppercase)
    }
}

extension View {
    
    func preventionTitle() -> some View {
        ModifiedContent(content: self, modifier: PreventionTitleModifier())
    }
}

// MARK: - Title Preference

struct PreventionTitlePreferenceKey: PreferenceKey {
    
    static var defaultValue: PreventionTitleVisibility = .identity
    
    static func reduce(value: inout PreventionTitleVisibility, nextValue: () -> PreventionTitleVisibility) {
        value = nextValue()
    }
}

enum PreventionTitleVisibility: Hashable {
    
    /// The title of the prevention is in its initial state.
    case identity
    
    /// The title of the prevention is minimized at the top.
    case minimized
}

extension View {
    
    func preventionTitleVisibility(_ visibility: PreventionTitleVisibility = .minimized) -> some View {
        preference(key: PreventionTitlePreferenceKey.self, value: visibility)
    }
}
