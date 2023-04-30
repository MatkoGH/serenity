import SwiftUI

// MARK: - Breathing Model

class BreathingModel: ObservableObject {
    
    /// The state of the breathing.
    @Published var state: BreathingState = .idle
    
    // MARK: Function
    
    /// Start the selected breathing exercise, if possible.
    func startActivity() {
        if case let .exercise(exercise) = state, exercise.activityAvailable {
            state = .activity(exercise: exercise)
        }
    }
    
    /// Ends the current activity, if possible.
    func endActivity() {
        if case let .activity(exercise) = state {
            state = .exercise(exercise: exercise)
        }
    }
}

// MARK: - State

enum BreathingState {
    
    /// Idle; showing intoductory views.
    case idle
    
    /// Breathing; showing the breathing view for the exercise.
    case exercise(exercise: BreathingExercise)
    
    /// Doing an activity; showing the activity view for the exercise.
    case activity(exercise: BreathingExercise)
}

// MARK: Exercise

enum BreathingExercise: CaseIterable, Hashable, Identifiable {
    
    /// The box breathing exercise.
    case box
    
    /// The counting breathing exercise.
    case counting
    
    /// The diaphragmatic breathing exercise.
    case diaphragmatic
    
    /// The quotes for this breathing exercise.
    var quotes: Quotes.Breathing.Exercise {
        Quotes.shared.breathing.quotes(for: self)
    }
    
    /// Boolean indicating whether there is an activity available for the exercise.
    var activityAvailable: Bool {
        switch self {
        case .box:
            return true
        default:
            return false
        }
    }
    
    /// Conformance to identifiable.
    var id: String { quotes.title }
}
