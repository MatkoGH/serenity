import SwiftUI

// MARK: - Serenity Model

class SerenityModel: ObservableObject {
    
    /// Stored boolean indicating whether the app is in onboarding.
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    /// The active prevention view.
    @Published var activeView: Prevention? = .none
    
    /// Stored boolean indicating whether the user has finished the walkthrough for the breathing prevention.
    @AppStorage("didFinishBreathingWalkthrough") var didFinishBreathingWalkthrough = false
    
    /// Stored boolean indicating whether the user has finished the walkthrough for the Pomodoro prevention.
    @AppStorage("didFinishPomodoroWalkthrough") var didFinishPomodoroWalkthrough = false
    
    /// Stored boolean indicating whether the user has finished the walkthrough for the tips prevention.
    @AppStorage("didFinishTipsWalkthrough") var didFinishTipsWalkthrough = false
}

// MARK: - Prevention

enum Prevention: CaseIterable {
    
    /// Breathing view is active.
    case breathing
    
    /// Pomodoro view is active.
    case pomodoro
    
    /// Tips view is active.
    case tips
    
    /// The icon associated with this view.
    var icon: String {
        switch self {
        case .breathing:
            return "microbe"
        case .pomodoro:
            return "timer"
        case .tips:
            return "bubbles.and.sparkles"
        }
    }
    
    /// The title associated with this view.
    var title: String {
        switch self {
        case .breathing:
            return "Breathing Exercises"
        case .pomodoro:
            return "Pomodoro Technique"
        case .tips:
            return "Prevention Tips"
        }
    }
    
    /// The quotes associated with this view.
    var quotes: Quotes.Preventions.Prevention {
        Prevention.quotes(for: self)
    }
    
    /// Get the quotes associated with the provided view.
    /// - Parameter prevention: The prevention view.
    /// - Returns: The associated quotes.
    static func quotes(for prevention: Prevention) -> Quotes.Preventions.Prevention {
        let quotes = Quotes.shared.preventions
        
        switch prevention {
        case .breathing:
            return quotes.breathing
        case .pomodoro:
            return quotes.pomodoro
        case .tips:
            return quotes.tips
        }
    }
    
    /// The optional walkthrough for the prevention.
    var walkthrough: Quotes.Walkthrough? {
        let quotes = Quotes.shared.preventions
        
        switch self {
        case .breathing:
            return quotes.breathing.walkthrough
        case .pomodoro:
            return quotes.pomodoro.walkthrough
        case .tips:
            return quotes.tips.walkthrough
        }
    }
}
