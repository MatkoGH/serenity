import SwiftUI

// MARK: - HSL Init

extension Color {
    
    /// Creates a color using `HSLA` components, including **hue**, **saturation**, **lightness**, and **alpha**.
    /// - This function converts the `HSL` properties into `HSB` (`HSV`), then initializes the `Color` using the built-in `.init(hue:saturation:brightness:alpha:)` initializer.
    /// - Parameters:
    ///   - hue: The angle of the hue.
    ///   - saturation: The saturation value of the color between [0, 1].
    ///   - lightness: The lightness value of the color between [0, 1].
    ///   - opacity: The opacity (alpha) value of this color between [0, 1]. Defaults to `1.0`.
    init(hue: Angle, saturation: CGFloat, lightness: CGFloat, opacity: CGFloat = 1.0) {
        var hue = CGFloat(hue.degrees)
        var saturation = saturation
        var lightness = lightness
        var opacity = opacity
        
        // Adjust each of the HSLA values
        Color.adjustHue(&hue, saturation: &saturation, lightness: &lightness, alpha: &opacity)
        
        // Convert the bounds of the hue value from [0-360] to [0.0-1.0]
        let hueB = hue / 360
        
        // Calculate the HSB brightness value
        let brightness = lightness + saturation * min(lightness, 1 - lightness)
        
        // Calculate the HSB saturation value
        let saturationB: CGFloat
        if brightness == 0 {
            saturationB = 0
        } else {
            saturationB = 2 * (1 - lightness / brightness)
        }
        
        // Initialize using the built-in HSB initializer
        self.init(hue: hueB, saturation: saturationB, brightness: brightness, opacity: opacity)
    }
    
    
    /// Creates a color using an existing `HSL` color structure.
    /// - Parameters:
    ///   - hslColor: The `HSL` color structure.
    ///   - opacity: The opacity (alpha) value of this color between [0, 1]. Defaults to `1.0`.
    init(_ hslColor: HSL, opacity: CGFloat = 1.0) {
        self.init(hue: hslColor.hue, saturation: hslColor.saturation, lightness: hslColor.lightness, opacity: opacity)
    }
    
    // MARK: Function
    
    /// Adjust each of the `HSLA` components to fit within their respective bounds.
    /// - Parameters:
    ///   - hue: A pointer to the `hue` value.
    ///   - saturation: A pointer to the `saturation` value.
    ///   - lightness: A pointer to the `lightness` value.
    ///   - alpha: A pointer to the `alpha` value.
    fileprivate static func adjustHue(_ hue: inout CGFloat, saturation: inout CGFloat, lightness: inout CGFloat, alpha: inout CGFloat) {
        hue = clamp(hue, maxValue: 360)
        saturation = clamp(saturation)
        lightness = clamp(lightness)
        alpha = clamp(alpha)
    }
    
    /// Clamps the given value to the bounds using addition or subtraction of bounds.
    /// - Parameters:
    ///   - value: The value to clamp.
    ///   - maxValue: The maximum possible value.
    ///   - minValue: The minimum possible value.
    /// - Returns: The value clamped to the provided bounds.
    fileprivate static func clamp(_ value: CGFloat, maxValue: CGFloat = 1.0, minValue: CGFloat = 0.0) -> CGFloat {
        // If the value is greater than the maximum value, subtract by maximum bounds and clamp again
        (value > maxValue) ? clamp(value - maxValue) :
        // If the value is less than the minimum value, add the maximum bound value and clamp again
        (value < minValue) ? clamp(value + maxValue) :
        // If the value is within the bounds, return it
        value
    }
}

// MARK: - HSL Structure

extension Color {
    
    struct HSL {
        
        /// The angle of the hue.
        var hue: Angle
        
        /// The saturation property of the color.
        var saturation: CGFloat
        
        /// The lightness property of the color.
        var lightness: CGFloat
    }
}

// MARK: - HSL Structure Extension

extension Color.HSL {
    
    /// Create a color by adjusting the saturation value of this color.
    /// - Parameter value: The value to adjust the saturation by.
    /// - Returns: A new color with the adjusted saturation.
    func adjustingSaturation(by value: CGFloat) -> Color.HSL {
        Color.HSL(
            hue: hue,
            saturation: Color.clamp(saturation + value),
            lightness: lightness
        )
    }
    
    /// Create a color by adjusting the lightness value of this color.
    /// - Parameter value: The value to adjust the lightness by.
    /// - Returns: A new color with the adjusted lightness.
    func adjustingLightness(by value: CGFloat) -> Color.HSL {
        Color.HSL(
            hue: hue,
            saturation: saturation,
            lightness: Color.clamp(lightness + value)
        )
    }
}
