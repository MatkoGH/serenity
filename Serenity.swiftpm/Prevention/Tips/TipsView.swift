import SwiftUI

// MARK: - Tips View

struct TipsView: View {
    
    @EnvironmentObject var model: SerenityModel
    
    @StateObject var tips = TipsModel()
    
    // MARK: Properties
    
    /// The index of the displayed tip.
    @State private var tipIndex: Int = 0
    
    // MARK: Computed
    
    /// An enumerated array of the tips.
    var enumeratedTips: [EnumeratedSequence<[Tip]>.Element] {
        Array(tips.entries.enumerated())
    }
    
    // MARK: Content
    
    var body: some View {
        PreventionContainer(for: .tips) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Stress Relief Tips")
                    .preventionTitle()
                
                SwipeablePagingStack(index: $tipIndex, maxIndex: tips.entries.count - 1, axis: .horizontal, spacing: 48) { isDragging in
                    ForEach(enumeratedTips, id: \.offset) { offset, tip in
                        let isActive = isActive(offset)
                        
                        TipsTipView(for: tip)
                            .blur(radius: isActive || isDragging ? 0 : 4)
                            .opacity(isActive ? 1 : (isDragging ? 0.5 : 0.25))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(24)
                .background {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(.secondary, lineWidth: 2)
                }
                .padding(.horizontal, -24)
            }
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: Function
    
    /// Check if the view at the provided index is active.
    /// - Parameter index: The index of the view.
    /// - Returns: Boolean indicating whether the view is active.
    func isActive(_ offset: Int) -> Bool {
        tipIndex == offset
    }
}
