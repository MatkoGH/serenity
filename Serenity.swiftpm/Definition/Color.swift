import SwiftUI

// MARK: - Color

extension Color {
    
    /// Shortcut for the accent color.
    /// - `Color.accentColor` did not play well when converted to a `UIColor`.
    static var accent: Color {
        Color("AccentColor")
    }
    
    /// The default Serenity green color.
    static var serenityGreen: Color {
        Color(.serenityGreen)
    }
    
    /// A lighter Serenity green color.
    static var lightSerenityGreen: Color {
        Color(.serenityGreen.adjustingLightness(by: 0.16))
    }
    
    /// A darker Serenity green color.
    static var darkSerenityGreen: Color {
        Color(.serenityGreen.adjustingLightness(by: -0.16))
    }
    
    /// The Serenity green color used for shadows.
    static var serenityGreenShadow: Color {
        Color(.serenityGreen, opacity: 0.45)
    }
    
    /// The action Serenity blue color.
    static var serenityBlue: Color {
        Color(.serenityBlue)
    }
    
    /// The destructive Serenity red color.
    static var serenityRed: Color {
        Color(.serenityRed)
    }
    
    // MARK: Dynamic
    
    /// A dynamic Serenity green, based on the `lightSerenityGreen` and `darkSerenityGreen` colors.
    static var dynamicSerenityGreen: Color {
        let uiColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(darkSerenityGreen)
            default:
                return UIColor(lightSerenityGreen)
            }
        }
        
        return Color(uiColor: uiColor)
    }
}

// MARK: - HSL

extension Color.HSL {
    
    /// HSL equivalent of `.accentColor`.
    static var accent: Color.HSL { .serenityGreen }
    
    /// The default Serenity green color.
    static var serenityGreen: Color.HSL {
        Color.HSL(hue: .degrees(146), saturation: 0.88, lightness: 0.42)
    }
    
    /// The action Serenity blue color.
    static var serenityBlue: Color.HSL {
        Color.HSL(hue: .degrees(210), saturation: 0.88, lightness: 0.53)
    }
    
    /// The destructive Serenity red color.
    static var serenityRed: Color.HSL {
        Color.HSL(hue: .degrees(356), saturation: 0.88, lightness: 0.64)
    }
}
