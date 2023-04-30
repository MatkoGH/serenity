import SwiftUI

extension Axis {
    
    /// The axis perpendicular to this one.
    var perpendicular: Axis {
        self == .horizontal ? .vertical : .horizontal
    }
}
