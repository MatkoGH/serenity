import SwiftUI

// MARK: - Tips Model

class TipsModel: ObservableObject {
    
    // MARK: Computed
    
    /// An array of the tip entries.
    var entries: [Tip] {
        Quotes.shared.tips.entries
    }
}

// MARK: - Tip Alias

typealias Tip = Quotes.Tips.Tip
