import SwiftUI

// MARK: Multiline Text Layout

struct MultilineTextLayout: Layout {
    
    @Environment(\.multilineTextAlignment) var alignment
    
    /// The ranges of each word. This will ensure that no words are broken across multiple lines.
    var wordRanges: [TextRange]
    
    /// The text alignment.
    var textAlignment: TextAlignment
    
    // MARK: Init
    
    init(ranges wordRanges: [TextRange], textAlignment: TextAlignment = .leading) {
        self.wordRanges = wordRanges
        self.textAlignment = textAlignment
    }
    
    init(text: String, textAlignment: TextAlignment = .leading) {
        self.wordRanges = Self.wordRanges(for: text)
        self.textAlignment = textAlignment
    }
    
    // MARK: Layout
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let lines = lines(proposal: proposal, subviews: subviews)
        
        let width = maxWidth(of: lines, subviews: subviews)
        let height = totalHeight(of: lines, subviews: subviews)
        
        let size = CGSize(width: width, height: height)
        
        return size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let lines = lines(proposal: proposal, subviews: subviews)
        var y: CGFloat = bounds.minY
        
        for line in lines {
            var x: CGFloat = minX(for: line, in: bounds, subviews: subviews)
            
            for index in line {
                let subview = subviews[index]
                let point = CGPoint(x: x, y: y)
                
                let size = subview.sizeThatFits(proposal)
                let proposedSize = ProposedViewSize(size)
                
                subview.place(at: point, proposal: proposedSize)
                
                x += size.width
            }
            
            y += height(of: line, subviews: subviews)
        }
    }
    
    // MARK: Calculation
    
    /// Create lines that fit within the bounds of SwiftUI's proposal.
    func lines(proposal: ProposedViewSize, subviews: Subviews) -> [TextRange] {
        var lines: [TextRange] = []
        
        let proposalWidth: CGFloat = proposal.width ?? .infinity
        
        for wordRange in wordRanges {
            let line = lines.last == nil ? wordRange : lines.removeLast()
            
            let newLine = line.extend(to: wordRange.upperBound)
            let lineFits = width(of: newLine, subviews: subviews) <= proposalWidth
            
            lines.append(lineFits ? newLine : line)
            
            if !lineFits {
                lines.append(wordRange)
            }
        }
        
        return lines
    }
    
    // MARK: Size
    
    /// Get the width of the text within the provided text range.
    /// - Parameter range: The text range.
    func width(of range: TextRange, subviews: Subviews) -> CGFloat {
        return subviews[range].reduce(0) { partial, range in
            partial + range.sizeThatFits(.unspecified).width
        }
    }
    
    /// Get the height of the text within the provided text range.
    /// - Parameter range: The text range.
    func height(of range: TextRange, subviews: Subviews) -> CGFloat {
        subviews[range].reduce(0) { partial, range in
            max(partial, range.sizeThatFits(.unspecified).height)
        }
    }
    
    /// Get the maximum width of the text within the provided text ranges.
    /// - Parameter ranges: The text ranges.
    func maxWidth(of ranges: [TextRange], subviews: Subviews) -> CGFloat {
        ranges.reduce(0) { partial, range in
            max(partial, width(of: range, subviews: subviews))
        }
    }
    
    /// Get the sum of the heights of each text within the provided text ranges.
    /// - Parameter ranges: The text ranges.
    func totalHeight(of ranges: [TextRange], subviews: Subviews) -> CGFloat {
        ranges.reduce(0) { partial, range in
            partial + height(of: range, subviews: subviews)
        }
    }
    
    // MARK: Position
    
    /// Get the minimum `x` position value for the provided line text range.
    /// - Parameter line: The range of the text in a line.
    func minX(for line: TextRange, in bounds: CGRect, subviews: Subviews) -> CGFloat {
        let width = width(of: line, subviews: subviews)
        
        switch textAlignment {
        case .leading:
            return bounds.minX
        case .center:
            return bounds.midX - width / 2
        case .trailing:
            return bounds.maxX - width
        }
    }
}

extension MultilineTextLayout {
    
    /// Get the word ranges within the provided string.
    /// - Parameter string: The string.
    /// - Returns: An array containing the word ranges.
    static func wordRanges(for string: String) -> [TextRange] {
        let regex = try! Regex("([^ ]+[\\s]*)")
        let ranges = string.ranges(of: regex).map { ranges in
            let lowerBound = ranges.lowerBound.utf16Offset(in: string)
            let upperBound = ranges.upperBound.utf16Offset(in: string) - 1
            
            return lowerBound...upperBound
        }
        
        return ranges
    }
}

// MARK: - Text Range

typealias TextRange = ClosedRange<Int>

extension TextRange {
    
    /// Extend the text range to a new upper bound while maintaining its lower bound.
    /// - Parameter upperBound: The new upper bound value.
    /// - Returns: A new text range with the new upper bound value.
    func extend(to upperBound: Int) -> TextRange {
        lowerBound...Swift.max(upperBound, self.upperBound)
    }
}
