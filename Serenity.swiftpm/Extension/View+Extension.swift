import SwiftUI

extension View {
    
    /// Apply modifiers to a view if the provided condition is met.
    /// - Parameters:
    ///   - condition: Boolean indicating whether the modifiers should be applied.
    ///   - transform: The modifiers to apply to the view.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
