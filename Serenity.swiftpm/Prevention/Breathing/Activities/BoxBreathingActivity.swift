import SwiftUI

// MARK: - Model

class BoxBreathingActivityModel: ObservableObject {
    
    /// The amount of box breathing sets to do.
    let sets: Int = 4
    
    /// An array of the parts in each set.
    let set: [BoxBreathingState] = [.inhaling, .holding(willInhale: false), .exhaling, .holding(willInhale: true)]
    
    /// The amount of seconds to use for the box exercise.
    let boxDuration: TimeInterval = 4.0
    
    // MARK: Properties
    
    /// The state of the breathing activity.
    @Published var state: BoxBreathingState = .idle
    
    /// Boolean indicating whether the activity has started.
    @Published var hasStarted: Bool = false
    
    /// The current index of the sets.
    @Published var index: Int = 0
    
    // MARK: Computed
    
    var enumeratedParts: [Part] {
        var parts: [Part] = []
        
        for index in 0 ..< sets {
            let adjustedIndex = index * set.count
            
            // Loop through the parts of one set
            for stateIndex in set.indices {
                let state = set[stateIndex]
                
                // Create the part with its respective offset
                let part: Part = (
                    offset: adjustedIndex + stateIndex + 1,
                    state: state
                )
                
                // Add it to all of the parts
                parts.append(part)
            }
        }
        
        // Add starting and finished parts
        parts.insert((offset: 0, state: .idle), at: 0)
        parts.append((offset: parts.count, state: .finished))
        
        return parts
    }
    
    // MARK: Function
    
    /// Start the breathing activity.
    func start() {
        hasStarted = true
        
        // Go to the first step
        next()
    }
    
    /// Continue to the next part.
    func next() {
        let nextIndex = index + 1
        guard nextIndex < enumeratedParts.count else {
            finish()
            return
        }
        
        index = nextIndex
        state = enumeratedParts[nextIndex].state
        
        DispatchQueue.main.asyncAfter(deadline: .now() + boxDuration) {
            self.next()
        }
    }
    
    func finish() {
        state = .finished
    }
    
    // MARK: Type
    
    typealias Part = (offset: Int, state: BoxBreathingState)
}

// MARK: - State

enum BoxBreathingState: Hashable {
    
    /// The activity has not started.
    case idle
    
    /// The user is inhaling.
    case inhaling
    
    /// The user is holding their breath.
    case holding(willInhale: Bool)
    
    /// The user is exhaling.
    case exhaling
    
    /// The activity has finished.
    case finished
    
    /// The description of this state.
    var description: String {
        switch self {
        case .idle:
            return "Waiting to start"
        case .inhaling:
            return "Inhale"
        case .holding(_):
            return "Hold"
        case .exhaling:
            return "Exhale"
        case .finished:
            return "All done"
        }
    }
    
    /// Boolean indicating whether the activity is active.
    var isActive: Bool {
        switch self {
        case .idle, .finished:
            return false
        default:
            return true
        }
    }
}

// MARK: - Activity

struct BoxBreathingActivity: View {
    
    @EnvironmentObject var breathing: BreathingModel
    
    @StateObject var activity = BoxBreathingActivityModel()
    
    // MARK: Computed
    
    /// The state of the breathing circle.
    private var circleState: BreathingCircleState {
        switch activity.state {
        case .exhaling:
            return .identity()
        case .inhaling:
            return .expanded()
        case let .holding(willInhale):
            return willInhale ? .identity(rotating: true) : .expanded(rotating: true)
        default:
            return .pulsing
        }
    }
    
    /// The animation to use, based on the duration of the box periods.
    private var animation: Animation {
        .breathing(duration: activity.boxDuration)
    }
    
    /// The fill style to use on the primary circle.
    private var circleFillStyle: some ShapeStyle {
        LinearGradient(
            gradient: .serenityGreen,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// The fill style to use on the microbes.
    private var microbeFillStyle: some ShapeStyle {
        Color.primary.opacity(0.25)
    }
    
    // MARK: Content
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 24) {
                let diameter = circleDiameter(in: geometry)
                
                Text(activity.state.description)
                    .font(.breathingActivityTitle)
                    .textCase(.uppercase)
                    .frame(maxWidth: diameter - 32)
                    .transition(.blur(radius: 8))
                    .animation(.breathing(duration: 0.5), value: activity.state)
                
                BreathingCircle(
                    state: circleState,
                    diameter: diameter,
                    circleFillStyle: circleFillStyle,
                    microbes: K.breathingMicrobes,
                    microbeDiameter: K.breathingMicrobeDiameter,
                    microbeSpacing: K.breathingMicrobeSpacing,
                    microbeFillStyle: microbeFillStyle
                )
                .animation(animation, value: activity.state)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                let title = activity.hasStarted ? "Finish" : "Start"
                let icon = activity.hasStarted ? "sparkles" : "play"
                
                SerenityButton(title, icon: icon) {
                    if activity.hasStarted {
                        withAnimation(.screen) {
                            breathing.endActivity()
                        }
                    } else {
                        startActivity()
                    }
                }
                .hidden(activity.hasStarted && activity.state != .finished)
                .padding(.bottom, 24)
            }
        }
    }
    
    // MARK: Function
    
    func startActivity() {
        withAnimation(.buttonAppear) {
            activity.start()
        }
    }
    
    /// Get the diameter of the primary circle of the breathing circle.
    /// - Parameter geometry: The geometry proxy.
    /// - Returns: The diameter of the circle.
    private func circleDiameter(in geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width, geometry.size.height) * 0.75
    }
    
    /// Check whether the view at the provided offset is active.
    /// - Parameter offset: The offset.
    /// - Returns: Boolean indicating whether the view is active.
    func isActive(_ offset: Int) -> Bool {
        activity.index == offset
    }
}

// MARK: - Circle

struct BreathingCircle<C, M>: View where C: ShapeStyle, M: ShapeStyle {
    
    /// The state of the breathing circle.
    var state: BreathingCircleState
    
    /// The diameter of the breathing circle.
    var diameter: CGFloat
    
    /// The fill style of the primary circle.
    var circleFillStyle: C
    
    /// The number of microbes to include around the circle.
    var microbes: Int
    
    /// The diameter of each microbe.
    var microbeDiameter: CGFloat
    
    /// The spacing between each microbe and the primary circle.
    var microbeSpacing: CGFloat
    
    /// The fill style of each microbe.
    var microbeFillStyle: M
    
    // MARK: Properties
    
    /// Boolean indicating whether the circle is animating its pulse.
    @State private var isAnimatingPulse: Bool = false
    
    /// The angle of rotation of the microbes.
    @State private var rotation: Angle = .zero
    
    // MARK: Computed
    
    /// The diameter of the primary circle.
    var circleDiameter: CGFloat {
        let microbeSpace: CGFloat = 2 * (microbeDiameter + microbeSpacing)
        
        switch state {
        case .identity:
            return diameter * 0.7 - microbeSpace
        case .expanded:
            return diameter - microbeSpace
        case .pulsing:
            let pulsedSize = diameter * 0.8 - microbeSpace
            let identitySize = diameter * 0.7 - microbeSpace
            
            return isAnimatingPulse ? pulsedSize : identitySize
        }
    }
    
    /// An array of the indices from zero to the maximum microbe index.
    var microbeIndices: [Int] {
        Array(0 ..< microbes)
    }
    
    /// The base rotation angle based on the number of microbes.
    var baseRotationDegrees: CGFloat {
        360 / CGFloat(microbes)
    }
    
    /// Boolean indicating whether the microbes are rotating.
    var areMicrobesRotating: Bool {
        switch state {
        case let .identity(rotating), let .expanded(rotating):
            return rotating
        case .pulsing:
            return true
        }
    }
    
    // MARK: Content
    
    var body: some View {
        ZStack {
            Circle()
                .fill(circleFillStyle)
                .frame(width: circleDiameter, height: circleDiameter)
            
            ForEach(microbeIndices, id: \.self) { index in
                let rotationAngle: Angle = .degrees(baseRotationDegrees * Double(index))
                
                Circle()
                    .fill(microbeFillStyle)
                    .frame(width: microbeDiameter, height: microbeDiameter)
                    .offset(y: circleDiameter / 2 + microbeSpacing + microbeDiameter / 2)
                    .rotationEffect(rotationAngle)
                    .rotationEffect(rotation)
            }
        }
        .frame(width: diameter, height: diameter)
        .onChange(of: areMicrobesRotating) { newValue in
            if newValue {
                let rotationFactor = CGFloat(microbes / 6)
                rotation = .degrees(rotation.degrees + baseRotationDegrees * rotationFactor)
            }
        }
        .onChange(of: state) { newState in
            pulseIfNecessary(newState)
        }
        .onAppear {
            pulseIfNecessary(state)
        }
    }
    
    // MARK: Function
    
    /// Pulse the circle, if necessary.
    func pulseIfNecessary(_ state: BreathingCircleState) {
        if case .pulsing = state {
            let rotationFactor = CGFloat(microbes / 6)
            let duration: TimeInterval = 3.0
            
            withAnimation(.breathing(duration: duration).repeatForever()) {
                isAnimatingPulse = true
            }
            
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                rotation = .degrees(rotation.degrees + baseRotationDegrees * rotationFactor)
            }
        } else if isAnimatingPulse {
            withAnimation(.breathing(duration: 1)) {
                isAnimatingPulse = false
                rotation = .zero
            }
        }
    }
}

// MARK: - Circle State

enum BreathingCircleState: Hashable {
    
    /// The identity state of the breathing circle.
    case identity(rotating: Bool = false)
    
    /// The expanded state of the breathing circle.
    case expanded(rotating: Bool = false)
    
    /// The pulsing state of the breathing circle.
    case pulsing
}
