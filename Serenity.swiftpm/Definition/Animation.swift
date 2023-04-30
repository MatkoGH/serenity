import SwiftUI

// MARK: - Animation

extension Animation {
    
    /// The animation to use for button presses.
    static var button: Animation {
        .spring(response: 0.15, dampingFraction: 0.86)
    }
    
    /// The animation to use for the home view buttons.
    static var viewButton: Animation {
        .easeOut(duration: 0.15)
    }
    
    /// The animation to use for when buttons appear.
    static var buttonAppear: Animation {
        .interpolatingSpring(mass: 2.0, stiffness: 200, damping: 50)
    }
    
    /// The animation to use when full-screen animations occur.
    static var screen: Animation {
        .easeInOut(duration: 0.35)
    }
    
    /// The animation to use on minimized titles when full-screen animations occur.
    static var minimizedTitle: Animation {
        .easeInOut(duration: 0.15)
    }
    
    // MARK: Home
    
    /// The animation to use for swipe discovery.
    static var swipeDiscovery: Animation {
        .easeInOut(duration: 1).delay(0.5)
    }
    
    /// The animation to use for the appearance of discovery elements.
    static var discoveryAppear: Animation {
        .easeInOut(duration: 0.5)
    }
    
    // MARK: Prevention
    
    /// The animation to use for the breathing animations.
    /// - Parameter duration: The duration of the animation.
    static func breathing(duration: TimeInterval) -> Animation {
        .easeInOut(duration: duration)
    }
    
    /// The animation to use for the Pomodoro timer controls.
    static var pomodoroControl: Animation {
        .interpolatingSpring(stiffness: 250, damping: 20)
    }
    
    // MARK: Onboarding
    
    /// The animation to use for onboarding step change.
    static var onboardingStep: Animation {
        .interpolatingSpring(mass: 10.0, stiffness: 250, damping: 75)
    }
}
