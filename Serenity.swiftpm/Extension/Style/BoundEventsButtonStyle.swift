import SwiftUI

// MARK: - Bounds Events Style

struct BoundEventsButtonStyle: ButtonStyle {
    
    /// Boolean indicating whether the button is pressed.
    @Binding var isPressed: Bool
    
    // MARK: Protocol
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}

extension ButtonStyle where Self == BoundEventsButtonStyle {
    
    /// Bind the `isPressed` value of a button style to a bound boolean variable.
    /// - Parameter isPressed: The bound boolean variable.
    static func bindEvents(isPressed: Binding<Bool>) -> Self {
        BoundEventsButtonStyle(isPressed: isPressed)
    }
}

// MARK: - View Extension

extension View {
    
    /// Bind the `isPressed` value of a button style to a bound boolean variable.
    /// - Parameter isPressed: The bound boolean variable.
    func bindPress(isPressed: Binding<Bool>) -> some View {
        buttonStyle(.bindEvents(isPressed: isPressed))
    }
}
