import SwiftUI

struct Quotes: Decodable {
    
    /// Blurb for the home screen.
    var homeBlurb: String
    
    /// Quotes for **Onboarding**.
    var onboarding: Onboarding
    
    struct Onboarding: Decodable {
        
        /// Onboarding walkthrough.
        var walkthrough: Walkthrough
    }
    
    /// Quotes for **breathing**.
    var breathing: Breathing
    
    struct Breathing: Decodable {
        
        /// The diaphragmatic exercise.
        var diaphragmatic: Exercise
        
        /// The box exercise.
        var box: Exercise
        
        /// The counting exercise.
        var counting: Exercise
        
        struct Exercise: Decodable {
            
            /// The title of the exercise.
            var title: String
            
            /// The body (description) of the exercise.
            var body: String
            
            /// The steps to perform the exercise.
            var steps: [String]
            
            /// The difficulty level of the exercise.
            var difficulty: Difficulty
            
            enum Difficulty: Int, Decodable {
                
                /// The exercise is easy.
                case easy = 1
                
                /// The exercise is not easy nor hard.
                case normal = 2
                
                /// The exercise is difficult.
                case difficult = 3
            }
            
            /// The approximate duration of the exercise.
            var duration: String
        }
    }
    
    /// Quotes for **Pomodoro**.
    var pomodoro: Pomodoro
    
    struct Pomodoro: Decodable {
        
        /// Pomodoro titles.
        var titles: Titles
        
        struct Titles: Decodable {
            
            /// Title for the `.working` period.
            var working: String
            
            /// Title for the `.break` period.
            var `break`: String
        }
        
        /// Pomodoro captions.
        var captions: Captions
        
        struct Captions: Decodable {
            
            /// Captions for the `.working` period.
            var working: [String]
            
            /// Captions for the `.break` period.
            var `break`: [String]
        }
    }
    
    /// Quotes for **tips**.
    var tips: Tips
    
    struct Tips: Decodable {
        
        /// Array of tips.
        var entries: [Tip]
        
        struct Tip: Decodable, Hashable {
            
            /// The benefits of following the tip.
            var benefits: [String]
            
            /// The description of the tip.
            var description: String
            
            /// The goal of the tip.
            var goal: String
            
            /// The qualities of life improved by following the tip.
            var improvedQualities: [String]
            
            /// The title of the tip.
            var title: String
            
            enum CodingKeys: String, CodingKey {
                case benefits
                case description
                case goal
                case improvedQualities = "improved_qualities"
                case title
            }
        }
    }
    
    /// Quotes for **preventions**.
    var preventions: Preventions
    
    struct Preventions: Decodable {
        
        /// Data for **breathing**.
        var breathing: Prevention
        
        /// Data for **Pomodoro**.
        var pomodoro: Prevention
        
        /// Data for **tips**.
        var tips: Prevention
        
        struct Prevention: Decodable {
            
            /// Blurb text.
            var blurb: String
            
            /// The benefits of this prevention.
            var benefits: [Benefit]?
            
            struct Benefit: Decodable {
                
                /// The title of the benefit.
                var title: String
                
                /// The body or description text of the benefit.
                var body: String
            }
            
            /// Further reading about this prevention.
            var furtherReading: String?
            
            /// Walkthrough for this prevention.
            var walkthrough: Walkthrough?
            
            enum CodingKeys: String, CodingKey {
                case blurb
                case benefits
                case furtherReading = "further_reading"
                case walkthrough
            }
        }
    }
}

// MARK: Walkthrough

extension Quotes {
    
    typealias Walkthrough = [WalkthroughQuote]
    
    struct WalkthroughQuote: Decodable, WalkthroughSection {
        
        /// The title of the section.
        var title: String?
        
        /// The body paragraphs in the section.
        var body: [String]
    }
}

extension Quotes.Walkthrough {
    
    /// Get a section based on its index.
    /// - Parameter number: The index of the section.
    /// - Returns: The section.
    func section(_ number: Int) -> WalkthroughSection {
        self[number - 1]
    }
}

// MARK: Breathing

extension Quotes.Breathing {
    
    /// Get the quotes for the provided exercise.
    /// - Parameter exercise: The breathing exercise.
    /// - Returns: The associated quotes.
    func quotes(for exercise: BreathingExercise) -> Exercise {
        switch exercise {
        case .diaphragmatic:
            return diaphragmatic
        case .box:
            return box
        case .counting:
            return counting
        }
    }
}

// MARK: Pomodoro

extension Quotes.Pomodoro {
    
    /// Get the title for the provided period.
    /// - Parameter period: The Pomodoro period.
    /// - Returns: The title string.
    func title(for period: PomodoroPeriod) -> String {
        switch period {
        case .working:
            return titles.working
        case .break:
            return titles.break
        }
    }
    
    /// Get a random encouraging caption for the provided period.
    /// - Parameter period: The Pomodoro period.
    /// - Returns: A caption string, if found.
    func caption(for period: PomodoroPeriod) -> String {
        switch period {
        case .working:
            return captions.working.randomElement()!
        case .break:
            return captions.break.randomElement()!
        }
    }
}

// MARK: Decoding

extension Quotes {
    
    /// Shared quotes
    static let shared = Quotes()
    
    fileprivate init() {
        guard let fileURL = Bundle.main.url(forResource: "Quotes", withExtension: "json") else {
            fatalError("Failed to load quotes.")
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode(Quotes.self, from: data)
            
            self = decoded
        } catch {
            fatalError("Failed to decode quotes: \(error)")
        }
    }
}
