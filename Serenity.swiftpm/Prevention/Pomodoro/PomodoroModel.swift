import SwiftUI

// MARK: - Pomodoro Model

class PomodoroModel: ObservableObject {
    
    /// The state of the Pomodoro.
    @Published var state: PomodoroState = .idle
    
    // MARK: Setup Properties
    
    /// The user-selected preset.
    @Published var preset: Preset = .standard
    
    /// Amount of time to work on something; defaults to **15 minutes**.
    var workingTime: TimeInterval {
        preset.workingTime
    }
    
    /// Amount of time in between working periods; defaults to **5 minutes**.
    var breakTime: TimeInterval {
        preset.breakTime
    }
    
    // MARK: Function
    
    /// Start the timer.
    func start() {
        state = .timer(period: .working)
    }
    
    /// Set the next state.
    func next() {
        if case let .timer(period) = state {
            switch period {
            case .working:
                state = .timer(period: .break)
            case .break:
                state = .idle
            }
        }
    }
    
    /// Reset the timer.
    func reset() {
        state = .idle
    }
    
    /// Get the amount of time that is set for the provided period.
    /// - Parameter period: The Pomodoro period.
    /// - Returns: The time, in seconds.
    func time(for period: PomodoroPeriod) -> TimeInterval {
        switch period {
        case .working:
            return workingTime
        case .break:
            return breakTime
        }
    }
}

// MARK: - State

enum PomodoroState {
    
    /// Idle; showing introductory views.
    case idle
    
    /// Timer; showing timer with period.
    case timer(period: PomodoroPeriod)
}

// MARK: - Period

enum PomodoroPeriod {
    
    /// Working state; the user is working on something.
    case working
    
    /// Break state; the user is currently taking a break from working.
    case `break`
    
    /// The title string for this period.
    var title: String {
        Quotes.shared.pomodoro.title(for: self)
    }
    
    /// A random caption for this period.
    var caption: String {
        Quotes.shared.pomodoro.caption(for: self)
    }
}

// MARK: - Preset

extension PomodoroModel {
    
    enum Preset: TimeInterval, CaseIterable, Hashable, Identifiable {
        
        /// 1 min / 1 min
        case minute = 60
        
        /// 5 min / 1 min
        case fiveMinutes = 300
        
        /// 15 min / 3 min
        case quarterHour = 900
        
        /// 25 min / 5 min
        case standard = 1500
        
        /// 30 min / 5 min
        case halfHour = 1800
        
        /// 1 hr / 10 min
        case hour = 3600
        
        /// 2 hr / 15 min
        case twoHours = 7200
        
        /// Preset identifier.
        var id: RawValue { rawValue }
        
        /// Description string.
        var description: String {
            switch self {
            case .minute:
                return "Shortest (1:00/0:30)"
            case .fiveMinutes:
                return "Shorter (5:00/1:00)"
            case .quarterHour:
                return "Short (15:00/3:00)"
            case .standard:
                return "Standard (25:00/5:00)"
            case .halfHour:
                return "Long (30:00/5:00)"
            case .hour:
                return "Longer (60:00/10:00)"
            case .twoHours:
                return "Longest (120:00/15:00)"
            }
        }
        
        /// The amount of time to spend on working.
        var workingTime: TimeInterval {
            rawValue
        }
        
        /// The amount of time to spend between working periods.
        var breakTime: TimeInterval {
            switch self {
            case .minute:
                return 30
            case .fiveMinutes:
                return 60
            case .quarterHour:
                return 180
            case .standard, .halfHour:
                return 300
            case .hour:
                return 600
            case .twoHours:
                return 900
            }
        }
    }
}
