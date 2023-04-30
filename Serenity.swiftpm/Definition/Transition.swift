import SwiftUI

// MARK: - Transition

extension AnyTransition {
    
    /// Button appear/disappear transition.
    static var button: AnyTransition {
        .scale(scale: 0.86)
        .combined(with: .blur(radius: 8))
        .combined(with: .opacity)
    }
    
    /// Scaling screen transition.
    static var scaling: AnyTransition {
        .asymmetric(insertion: .scale(scale: 0.86), removal: .scale(scale: 1/0.86))
        .combined(with: .opacity)
    }
    
    /// Horizontal moving screen transition.
    static var horizontalMove: AnyTransition {
        .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
        .combined(with: .opacity)
    }
    
    /// Horizontal moving screen transition.
    static var horizontalOffset: AnyTransition {
        .asymmetric(insertion: .offset(x: 24), removal: .offset(x: -24))
        .combined(with: .opacity)
    }
    
    // MARK: Prevention
    
    /// The transition to use for prevention texts.
    static var prevention: AnyTransition {
        .asymmetric(insertion: .offset(x: 24), removal: .offset(x: -24))
        .combined(with: .blur(radius: 8))
        .combined(with: .opacity)
    }
    
    /// The transition to use for the appearance of the minimized prevention title.
    static var minimizedPreventionTitle: AnyTransition {
        .scale(scale: 0.86, anchor: .leading)
        .combined(with: .blur(radius: 8))
        .combined(with: .opacity)
    }
    
    /// The transition to use for the appearance of the pomodoro controls.
    static var pomodoroControl: AnyTransition {
        .scale(scale: 0.25)
        .combined(with: .opacity)
    }
    
    // MARK: Custom
    
    /// A transition that moves with a blur with a provided radius.
    /// - Parameter radius: The blur radius to apply to the view in transition.
    static func blur(radius: CGFloat) -> AnyTransition {
        .modifier(
            active: BlurModifier(radius: radius),
            identity: BlurModifier(radius: .zero)
        )
    }
}

// MARK: - Modifiers

struct BlurModifier: ViewModifier {
    
    /// The radius of the blur.
    var radius: CGFloat
    
    // MARK: Protocol
    
    func body(content: Content) -> some View {
        content.blur(radius: radius)
    }
}
