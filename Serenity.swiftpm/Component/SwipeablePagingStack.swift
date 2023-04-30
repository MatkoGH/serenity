import SwiftUI

// MARK: - Swipable Paging Stack

struct SwipeablePagingStack<Content>: View where Content: View {
    
    @Environment(\.isScrollEnabled) var isScrollEnabled
    
    /// The active view's index.
    @Binding var index: Int
    
    /// The maximum index value.
    var maxIndex: Int
    
    /// The axis to place the views on.
    var axis: Axis
    
    /// The spacing between each view.
    var spacing: CGFloat
    
    /// The stack's body content.
    var content: (Bool) -> Content
    
    // MARK: Properties
    
    /// The size of the current view.
    @State private var size: CGSize = .zero
    
    /// The translation state of the drag gesture.
    @GestureState private var translation: CGFloat = .zero
    
    /// Boolean indicating whether the stack is being dragged.
    private var isDragging: Bool {
        translation != .zero
    }
    
    // MARK: Init
    
    init(index: Binding<Int>, maxIndex: Int, axis: Axis = .vertical, spacing: CGFloat = 16, @ViewBuilder content: @escaping (Bool) -> Content) {
        self._index = index
        self.maxIndex = maxIndex
        
        self.axis = axis
        self.spacing = spacing
        
        self.content = content
    }
    
    // MARK: Computed
    
    /// The offset size based on the translation of the drag gesture.
    var offset: CGSize {
        CGSize(parallel: translation, perpendicular: 0, axis: axis)
    }
    
    // MARK: Content
    
    var body: some View {
        PagingStack(index: index, axis: axis, spacing: spacing) {
            content(isDragging)
        }
        .gesture(dragGesture)
        .offset(offset)
        .animation(.interactivePagingStack, value: translation)
        .captureSize(to: $size)
    }
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .updating($translation) { drag, state, transaction in
                // Ensure scrolling is enabled
                guard isScrollEnabled else { return }
                
                let translation = drag.translation.correspondingTo(axis: axis)
                
                let newIndex = translation <= 0 ? index + 1 : index - 1
                let isOutOfBounds = newIndex < 0 || newIndex > maxIndex
                
                // Set the offset value, making it smaller if dragging out of bounds
                state = isOutOfBounds ? translation / 8 : translation
            }
            .onEnded { drag in
                // Ensure scrolling is enabled
                guard isScrollEnabled else { return }
                
                let translationMagnitude = abs(drag.predictedEndTranslation.correspondingTo(axis: axis))
                
                // Ensure the magnitude of the translation is greater than the threshold to change the index
                let minimumTranslationMagnitude = size.correspondingTo(axis: axis) / 3 + K.walkthroughSectionSpacing / 2
                guard translationMagnitude >= minimumTranslationMagnitude else {
                    return
                }
                
                let startLocation = drag.startLocation.correspondingTo(axis: axis)
                let endLocation = drag.predictedEndLocation.correspondingTo(axis: axis)
                
                let newIndex = endLocation < startLocation ? index + 1 : index - 1
                
                // Ensure that the index does not exceed its allowed range
                guard newIndex >= 0, newIndex <= maxIndex else {
                    return
                }
                
                withAnimation(.pagingStack) {
                    index = newIndex
                }
            }
    }
}

// MARK: - Extensions

extension Animation {
    
    /// The animation to use for animating the interactiveness within the swipable paging stack.
    static var interactivePagingStack: Animation {
        .interactiveSpring(response: 0.4, dampingFraction: 0.9, blendDuration: 0.1)
    }
}
