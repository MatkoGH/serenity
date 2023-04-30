import SwiftUI

// MARK: - Gradient

extension Gradient {
    
    /// The default Serenity green gradient.
    static var serenityGreen: Gradient {
        Gradient(colors: [
            Color(.serenityGreen.adjustingLightness(by: -0.08)),
            Color(.serenityGreen.adjustingLightness(by: 0)),
        ])
    }
    
    /// The background Serenity green gradient.
    static var backgroundSerenityGreen: Gradient {
        Gradient(colors: [
            .serenityGreen.opacity(1),
            .serenityGreen.opacity(0.8),
            .serenityGreen.opacity(0),
        ])
    }
    
    /// The grey fading gradient for the home view.
    static var greyFade: Gradient {
        Gradient(colors: [
            .primary.opacity(1),
            .primary.opacity(0.8),
            .primary.opacity(0.4),
            .primary.opacity(0),
        ])
    }
}
