import SwiftUI

@main
struct SerenityApp: App {
    
    @StateObject var model = SerenityModel()
    
    // MARK: Content
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .font(._body)
                .environmentObject(model)
        }
    }
}
