import SwiftUI

// MARK: - CGSize

extension CGSize {
    
    /// Gets the width or height corresponding to the axis provided.
    /// For example, `.horizontal` would correspond to width.
    /// - Parameter axis: The axis to use.
    /// - Returns: A `CGFloat` width or height value.
    func correspondingTo(axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal:
            return width
        case .vertical:
            return height
        }
    }
    
    
    /// Create a new size based on sizes parallel and perpencicular to an axis.
    /// - Parameters:
    ///   - parallelSize: The magnitude of the size parallel to an axis.
    ///   - perpendicularSize: The magnitude of the size perpendicular to an axis.
    ///   - axis: The axis to align the sizes with.
    init(parallel parallelSize: CGFloat, perpendicular perpendicularSize: CGFloat, axis: Axis) {
        switch axis {
        case .horizontal:
            self.init(width: parallelSize, height: perpendicularSize)
        case .vertical:
            self.init(width: perpendicularSize, height: parallelSize)
        }
    }
}

// MARK: - CGPoint

extension CGPoint {
    
    /// Gets the x or y value corresponding to the axis provided.
    /// For example, `.horizontal` would correspond to x.
    /// - Parameter axis: The axis to use.
    /// - Returns: A `CGFloat` width or height value.
    func correspondingTo(axis: Axis) -> CGFloat {
        switch axis {
        case .horizontal:
            return x
        case .vertical:
            return y
        }
    }
}
