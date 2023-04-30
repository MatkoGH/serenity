import SwiftUI

struct K {
    
    /// The name of this application.
    static let appName: String = "Serenity"
    
    // MARK: Properties
    
    /// The maximum width of screen-wide text content.
    static let textContentMaxWidth: CGFloat = 128 * 6
    
    /// The amount of seconds to wait before showing the swipe discovery feature.
    static let swipeFeatureDiscoveryAppearDelay: TimeInterval = 3.0
    
    // MARK: Date
    
    /// The symbol to use for "AM" when formatting times.
    static let amTimeSymbol: String = "am"
    
    /// The symbol to use for "PM" when formatting times.
    static let pmTimeSymbol: String = "pm"
    
    // MARK: Prevention
    
    /// The amount of microbes around a breathing circle.
    static let breathingMicrobes: Int = 12
    
    /// The diameter of each microbe around a breathing circle.
    static let breathingMicrobeDiameter: CGFloat = 36
    
    /// The spacing between each microbe and the primary circle of a breathing circle.
    static let breathingMicrobeSpacing: CGFloat = 24
    
    /// The places to use for displaying the time left.
    static let pomodoroTimePlaces: [TimeInterval.Place] = [.minutes, .seconds]
    
    /// The amound of time, in seconds, to wait to randomize the caption.
    static let pomodoroCaptionRandomizeTime: TimeInterval = 120
    
    // MARK: Walkthrough
    
    /// The amount of spacing between sections
    static let walkthroughSectionSpacing: CGFloat = 64
    
    /// The amount of spacing between paragraphs within a section.
    static let walkthroughSectionParagraphSpacing: CGFloat = 24
    
    /// The amount of seconds to wait before the title begins typing.
    static let walkthroughTitleAppearDelay: TimeInterval = 1.0
    
    /// The amount of seconds to wait before the body begins typing.
    static let walkthroughBodyAppearDelay: TimeInterval = 0.5
    
    /// The amount of seconds to wait between paragraphs.
    static let walkthroughParagraphPauseDuration: TimeInterval = 0.1
    
    /// The amount of seconds to wait before the fast-forward button appears.
    static let fastForwardButtonAppearDelay: TimeInterval = 5.0
    
    /// The amount of seconds to wait before the continue button appears.
    static let walkthroughContinueButtonAppearDelay: TimeInterval = 0.0
}
