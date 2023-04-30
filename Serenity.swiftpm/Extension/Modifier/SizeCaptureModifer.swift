import SwiftUI

// MARK: - Size Capture

struct SizeCapturePreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct SizeCaptureModifier: ViewModifier {
    
    /// Bound captured size of the view.
    @Binding var size: CGSize
    
    // MARK: Protocol
    
    func body(content: Content) -> some View {
        content.background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear { size = geometry.size }
                    .onChange(of: geometry.size) { size = $0 }
            }
        }
    }
}

// MARK: - Instant Size Capture

struct InstantSizeCaptureModifier: ViewModifier {
    
    /// The function to call once the geometry has been captured.
    var callback: (GeometryProxy) -> Void
    
    // MARK: Protocol
    
    func body(content: Content) -> some View {
        content.background {
            GeometryReader { geometry in
                Color.clear
                    .onAppear { callback(geometry) }
            }
        }
    }
}

// MARK: - View Extension

extension View {
    
    /// Capture the size of the view and assign it to a bound size variable.
    /// - Parameter value: The bound size variable.
    func captureSize(to value: Binding<CGSize>) -> some View {
        ModifiedContent(content: self, modifier: SizeCaptureModifier(size: value))
    }
    
    /// Capture the geometry of the view and run a callback function.
    /// - Parameter callback: The callback function.
    func instantGeometryCapture(callback: @escaping (GeometryProxy) -> Void) -> some View {
        ModifiedContent(content: self, modifier: InstantSizeCaptureModifier(callback: callback))
    }
}
