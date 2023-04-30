import SwiftUI

// MARK: - Paging Stack

struct PagingStack: Layout {
    
    /// The active view's index.
    var index: Int
    
    /// The axis to place the views on.
    var axis: Axis
    
    /// The spacing between each view.
    var spacing: CGFloat
    
    // MARK: Init
    
    init(index: Int, axis: Axis = .vertical, spacing: CGFloat = 16.0) {
        self.index = index
        
        self.axis = axis
        self.spacing = spacing
    }
    
    // MARK: Layout
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // The size of the view corresponding to provided axis.
        let parallelSize = subviews[index]
            .sizeThatFits(proposal)
            .correspondingTo(axis: axis)
        
        // The size of the current view corresponding to an axis perpendicular to the provided one.
        let perpendicularSize = subviews[index]
            .sizeThatFits(proposal)
            .correspondingTo(axis: axis.perpendicular)
        
        return CGSize(parallel: parallelSize, perpendicular: perpendicularSize, axis: axis)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let proposal = axis == .vertical ? modifiedProposal(for: subviews, in: proposal) : proposal
        
        let (minPosition, anchor) = minValues(in: bounds)
        
        let offset = offset(for: subviews, in: proposal)
        var position = minPosition - offset
        
        // Loop through all the subviews and place them
        for index in subviews.indices {
            let subview = subviews[index]
            
            // Get the position and size of the subview
            let point = point(at: position, in: bounds)
            let size = subview.sizeThatFits(proposal)
            let sizeProposal = ProposedViewSize(size)
            
            // Place the subview at the calculated point
            subview.place(at: point, anchor: anchor, proposal: sizeProposal)
            
            // Increment the position for the next subview
            position += (size.correspondingTo(axis: axis) + spacing)
        }
    }
    
    // MARK: Function
    
    /// Creates a modified view size proposal for when the stack's axis is vertical based on the maximum size of all the subviews.
    func modifiedProposal(for subviews: Subviews, in originalProposal: ProposedViewSize) -> ProposedViewSize {
        // Create a proposal using only the width of the original
        let horizontalOnlyProposal = ProposedViewSize(width: originalProposal.width, height: .infinity)
        
        // Calculate the maximum subview height
        let maxHeight = subviews.reduce(.zero) { partial, subview in
            max(partial, subview.sizeThatFits(horizontalOnlyProposal).height)
        }
        
        // Return a value based on the stack's axis
        return ProposedViewSize(width: originalProposal.width, height: maxHeight)
    }
    
    /// Get the total offset of the stack based on the current index.
    func offset(for subviews: Subviews, in proposal: ProposedViewSize) -> CGFloat {
        subviews.indices
            .filter { $0 < index }
            .reduce(0) { partial, index in
                partial + subviews[index].sizeThatFits(proposal).correspondingTo(axis: axis) + spacing
            }
    }
    
    /// Get the point at which a subview should be placed based on the stack axis.
    /// - Parameters:
    ///   - position: The current position of a subview.
    ///   - bounds: The bounds of the parent view.
    /// - Returns: The point to place the subview at.
    func point(at position: CGFloat, in bounds: CGRect) -> CGPoint {
        switch axis {
        case .horizontal:
            return CGPoint(x: position, y: bounds.midY)
        case .vertical:
            return CGPoint(x: bounds.midX, y: position)
        }
    }
    
    /// Get the middle position of the view based on the stack axis.
    /// - Parameter bounds: The bounds of the parent view.
    /// - Returns: The middle position's `x` or `y` value, based on the axis.
    func minValues(in bounds: CGRect) -> (position: CGFloat, anchor: UnitPoint) {
        switch axis {
        case .horizontal:
            return (bounds.minX, .leading)
        case .vertical:
            return (bounds.minY, .top)
        }
    }
}

// MARK: - Extensions

extension Animation {
    
    /// The animation to use for animating index changes within the paging stack.
    static var pagingStack: Animation {
        .spring(response: 0.5, dampingFraction: 0.86, blendDuration: 0.25)
    }
}
