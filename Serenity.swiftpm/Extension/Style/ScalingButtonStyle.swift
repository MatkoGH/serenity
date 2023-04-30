import SwiftUI

// MARK: - Scaling Style

struct ScalingButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .scaleEffect(isPressed ? 0.86 : 1)
            .opacity(isPressed ? 0.5 : 1)
            .animation(.button, value: isPressed)
    }
}

extension ButtonStyle where Self == ScalingButtonStyle {
    
    static var scaling: ScalingButtonStyle {
        ScalingButtonStyle()
    }
}
