import SwiftUI

// MARK: - Tip View

struct TipsTipView: View {
    
    @EnvironmentObject var tips: TipsModel
    
    /// The tip to display.
    var tip: Tip
    
    // MARK: Computed
    
    /// The foreground style to use for section titles.
    private var sectionTitleStyle: some ShapeStyle {
        LinearGradient(
            gradient: .serenityGreen,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: Init
    
    init(for tip: Tip) {
        self.tip = tip
    }
    
    // MARK: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(tip.title)
                    .font(.tipsTipTitle)
                
                TipsTipInformationRow(for: tip)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                section("Goal") {
                    Text(tip.goal)
                        .fontWeight(.bold)
                }
                
                section("About") {
                    Text(tip.description)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                }
                
                section("Benefits") {
                    ForEach(tip.benefits, id: \.self) { benefit in
                        Label(benefit, systemImage: "plus")
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .preventionTitleVisibility(.minimized)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func section<Content>(_ title: String, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(._heading)
                .foregroundStyle(sectionTitleStyle)
            
            content()
        }
    }
}

// MARK: - Tip Info Row

struct TipsTipInformationRow: View {
    
    /// The tip to list information for.
    var tip: Tip
    
    // MARK: Computed
    
    /// The style to use for the background of each label.
    var labelBackgroundStyle: some ShapeStyle {
        LinearGradient(
            gradient: .serenityGreen,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: Init
    
    init(for tip: Tip) {
        self.tip = tip
    }
    
    // MARK: Content
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            ForEach(tip.improvedQualities, id: \.self) { quality in
                label(quality)
                
                // Display a dot if it's not the last quality
                if tip.improvedQualities.last != quality {
                    dot
                }
            }
        }
        .font(.tipsTipInfo)
    }
    
    @ViewBuilder
    private func label(_ text: String) -> some View {
        Text(text)
            .textCase(.uppercase)
    }
    
    var dot: some View {
        Circle()
            .fill(.primary)
            .opacity(0.25)
            .frame(width: 4, height: 4)
            .padding(.bottom, 2)
    }
}
