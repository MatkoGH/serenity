import SwiftUI

// MARK: - Font

extension Font {
    
    /// The primary font used for body text.
    static var _body: Font {
        .system(size: 16)
    }
    
    /// The font used for large titles.
    static var _largeTitle: Font {
        .system(size: 64).weight(.black).width(.expanded)
    }
    
    /// The font used for titles.
    static var _title: Font {
        .system(size: 24).weight(.bold)
    }
    
    /// The font used for section headers.
    static var _heading: Font {
        .system(size: 20).weight(.medium)
    }
    
    /// The font used for section subheaders.
    static var _subheading: Font {
        .system(size: 16).weight(.bold)
    }
    
    /// The font used for caption text.
    static var _caption: Font {
        .system(size: 14)
    }
    
    // MARK: Button
    
    /// The font used for button titles.
    static var buttonTitle: Font {
        ._body.weight(.semibold)
    }
    
    // MARK: Home
    
    /// The font to use for titles in the home screen.
    static var homeTitle: Font {
        .system(size: 24).weight(.black).width(.expanded)
    }
    
    // MARK: Prevention
    
    /// The font to use for prevention titles.
    static var preventionTitle: Font {
        .system(size: 44).weight(.black).width(.expanded)
    }
    
    /// The minimized font to use for prevention titles.
    static var minimizedPreventionTitle: Font {
        .system(size: 24).weight(.black).width(.expanded)
    }
    
    /// The font to use for breathing exercise titles.
    static var breathingExerciseTitle: Font {
        .system(size: 20).weight(.black).width(.expanded)
    }
    
    /// The font to use for breathing exercise information text.
    static var breathingExerciseInfo: Font {
        .system(size: 14).weight(.medium)
    }
    
    /// The font to use for breathing activity titles.
    static var breathingActivityTitle: Font {
        .system(size: 32).weight(.black).width(.expanded)
    }
    
    /// The font to use for the pomodoro timer time.
    static var pomodoroTime: Font {
        .system(size: 96).weight(.heavy).monospacedDigit()
    }
    
    /// The font to use for pomodoro technique titles.
    static var pomodoroTitle: Font {
        .system(size: 24).weight(.semibold)
    }
    
    /// The font to use for pomodoro technique captions.
    static var pomodoroCaption: Font {
        .system(size: 20).italic()
    }
    
    /// The font to use for the pomodoro timer's primary control icon.
    static var pomodoroPrimaryControl: Font {
        .system(size: 48, design: .rounded).weight(.bold)
    }
    
    /// The font to use for the pomodoro timer's secondary control icons.
    static var pomodoroSecondaryControl: Font {
        .system(size: 32, design: .rounded).weight(.bold)
    }
    
    /// The font to use for tip titles.
    static var tipsTipTitle: Font {
        .system(size: 32).weight(.black).width(.expanded)
    }
    
    /// The font to use for tip information.
    static var tipsTipInfo: Font {
        .system(size: 14).weight(.medium)
    }
    
    // MARK: Onboarding
    
    /// The font used for onboarding titles.
    static var walkthroughTitle: Font {
        .system(size: 36).weight(.bold)
    }
    
    /// The font used for onboarding questions.
    static var walkthroughBody: Font {
        .system(size: 24)
    }
}
