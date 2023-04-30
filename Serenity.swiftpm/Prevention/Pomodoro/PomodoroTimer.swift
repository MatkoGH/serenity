import SwiftUI
import Combine

// MARK: - Pomodoro Timer

struct PomodoroTimer: View {
    
    @EnvironmentObject var pomodoro: PomodoroModel
    
    /// The active Pomodoro period.
    var period: PomodoroPeriod
    
    // MARK: Properties
    
    /// The remaining time for the period.
    @State private var remainingTime: TimeInterval = .zero
    
    /// Boolean indicating whether the timer is paused.
    @State private var isPaused: Bool = false
    
    /// Randomly chosen encouraging caption based on the period.
    @State private var caption: String?
    
    /// Boolean indicating whether the timer has started.
    @State private var hasStarted: Bool = false
    
    // MARK: Computed
    
    /// The total amount of time for the period.
    private var totalTime: TimeInterval {
        pomodoro.time(for: period)
    }
    
    /// The timer publisher object.
    private var timer: Timer.TimerPublisher {
        Timer.publish(every: 1.0, on: .main, in: .common)
    }
    
    // MARK: Init
    
    init(for period: PomodoroPeriod) {
        self.period = period
    }
    
    // MARK: Content
    
    var body: some View {
        ZStack {
            Group {
                // Ensure the transition happens
                switch period {
                case .working:
                    PomodoroTimerPrimary(period: .working, remainingTime: remainingTime, caption: caption)
                case .break:
                    PomodoroTimerPrimary(period: .break, remainingTime: remainingTime, caption: caption)
                }
            }
            .onReceive(timer.autoconnect(), perform: timerTicked(_:))
            .transition(.horizontalMove)
        }
        .frame(maxWidth: K.textContentMaxWidth, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            Group {
                if hasStarted {
                    PomodoroTimerControls(isPaused: $isPaused, resetCaption: resetCaption)
                        .padding(.horizontal, 24)
                        .padding(.vertical)
                        .background {
                            Capsule(style: .continuous)
                                .fill(.ultraThinMaterial)
                                .opacity(isPaused ? 1 : 0.5)
                        }
                } else {
                    let title = period == .break ? "Take a break" : "Start"
                    let icon = period == .break ? "sparkles" : "timer"
                    
                    SerenityButton(title, icon: icon) {
                        withAnimation(.screen) {
                            hasStarted = true
                        }
                    }
                    .transition(.button)
                }
            }
            .padding(.bottom, 24)
        }
        .persistentSystemOverlays(hasStarted && !isPaused ? .hidden : .visible)
        .preventionTitleVisibility(.minimized)
        .onAppear {
            // Set the remaining time
            remainingTime = totalTime
            caption = period.caption
        }
    }
    
    // MARK: Function
    
    /// Function to run when the timer ticks.
    func timerTicked(_ timer: Timer.TimerPublisher.Output) {
        if isPaused || !hasStarted {
            return
        }
        
        // Tell the model that this timer has finished
        if remainingTime == 0 {
            withAnimation(.buttonAppear) {
                pomodoro.next()
                
                hasStarted = false
                remainingTime = totalTime
            }
            
            return
        }
        
        // Randomize the caption
        if floor(remainingTime).truncatingRemainder(dividingBy: K.pomodoroCaptionRandomizeTime) == 0 {
            resetCaption()
        }
        
        // Subtract the time.
        remainingTime -= 1
    }
    
    /// Reset the caption.
    func resetCaption() {
        let newCaption = period.caption
        if caption == newCaption {
            return resetCaption()
        }
        
        caption = newCaption
    }
}

// MARK: - Primary Content

struct PomodoroTimerPrimary: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var pomodoro: PomodoroModel
    
    /// The Pomodoro period.
    var period: PomodoroPeriod
    
    /// The time to display.
    var time: TimeInterval
    
    /// A random encouraging caption.
    var caption: String?
    
    // MARK: Computed
    
    /// The displayable string version of the remaining time.
    var timeString: String {
        time.displayStringFromComponents(
            K.pomodoroTimePlaces,
            minimumPlaceCount: 2
        )
    }
    
    // MARK: Styles
    
    /// The gradient for the title.
    private var titleStyle: some ShapeStyle {
        LinearGradient(
            gradient: .serenityGreen,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: Init
    
    init(period: PomodoroPeriod, remainingTime time: TimeInterval, caption: String? = nil) {
        self.period = period
        self.time = time
        self.caption = caption
    }
    
    // MARK: Content
    
    var body: some View {
        VStack(spacing: 8) {
            Text(period.title)
                .font(.pomodoroTitle)
                .foregroundStyle(titleStyle)
            
            Text(timeString)
                .font(.pomodoroTime)
            
            if let caption {
                Text(caption)
                    .font(.pomodoroCaption)
                    .foregroundColor(.secondary)
                    .transition(.pomodoroControl)
            }
        }
    }
}

// MARK: - Controls

struct PomodoroTimerControls: View {
    
    @EnvironmentObject var pomodoro: PomodoroModel
    
    /// Boolean indicating whether the timer is paused.
    @Binding var isPaused: Bool
    
    /// Reset the caption.
    var resetCaption: (() -> Void)?
    
    // MARK: Properties
    
    /// The tallest control button's height.
    @State private var maxControlHeight: CGFloat = .zero
    
    // MARK: Init
    
    init(isPaused: Binding<Bool>, resetCaption: (() -> Void)? = nil) {
        self._isPaused = isPaused
        self.resetCaption = resetCaption
    }
    
    // MARK: Content
    
    var body: some View {
        HStack(spacing: 16) {
            if isPaused {
                resetButton
            }
            
            playPauseButton
            
            if isPaused, resetCaption != nil {
                resetCaptionButton
            }
        }
        .frame(height: maxControlHeight)
    }
    
    var resetButton: some View {
        Button {
            withAnimation(.screen) {
                pomodoro.reset()
            }
        } label: {
            Image(systemName: "arrow.uturn.backward")
                .font(.pomodoroSecondaryControl)
                .transition(.pomodoroControl)
        }
        .buttonStyle(.scaling)
        .foregroundColor(.secondary)
    }
    
    var playPauseButton: some View {
        Button {
            withAnimation(.pomodoroControl) {
                isPaused.toggle()
            }
        } label: {
            Group {
                switch isPaused {
                case true:
                    Image(systemName: "play.fill")
                        .instantGeometryCapture { geometry in
                            maxControlHeight = max(geometry.size.height, maxControlHeight)
                        }
                case false:
                    Image(systemName: "pause.fill")
                        .instantGeometryCapture { geometry in
                            maxControlHeight = max(geometry.size.height, maxControlHeight)
                        }
                }
            }
            .font(.pomodoroPrimaryControl)
            .transition(.pomodoroControl)
        }
        .buttonStyle(.scaling)
        .foregroundColor(.primary)
    }
    
    var resetCaptionButton: some View {
        Button {
            withAnimation(.pomodoroControl) {
                resetCaption?()
            }
        } label: {
            Image(systemName: "captions.bubble")
                .font(.pomodoroSecondaryControl)
                .transition(.pomodoroControl)
        }
        .buttonStyle(.scaling)
        .foregroundColor(.secondary)
    }
}
