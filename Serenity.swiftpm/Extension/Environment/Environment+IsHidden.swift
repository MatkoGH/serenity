import SwiftUI

private struct HiddenEnvironmentKey: EnvironmentKey {
    
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    
    /// Boolean allowing you to define whether a view as hidden.
    var hidden: Bool {
        get { self[HiddenEnvironmentKey.self] }
        set { self[HiddenEnvironmentKey.self] = newValue }
    }
}

extension View {
    
    /// Allows you to define whether the view is hidden.
    /// - Parameter condition: The condition that must be met to hide the view.
    func hidden(_ condition: Bool = true) -> some View {
        environment(\.hidden, condition)
    }
}
