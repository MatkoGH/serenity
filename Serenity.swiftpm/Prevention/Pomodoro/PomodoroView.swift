import SwiftUI

// MARK: - Pomodoro View

struct PomodoroView: View {
    
    @EnvironmentObject var model: SerenityModel
    
    /// The Pomodoro timer model.
    @StateObject var pomodoro = PomodoroModel()
    
    // MARK: Content
    
    var body: some View {
        PreventionContainer(for: .pomodoro) {
            switch pomodoro.state {
            case .idle:
                introductoryView
                    .transition(.scaling)
            case let .timer(period):
                PomodoroTimer(for: period)
                    .transition(.scaling)
            }
        }
        .environmentObject(pomodoro)
    }
    
    var introductoryView: some View {
        VStack(alignment: .trailing, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("The Pomodoro Technique")
                    .preventionTitle()
                
                Text("Choose a time preset")
                    .font(._title)
                
                Text("You can set your work and break durations by selecting a preset from the wheel below.")
                    .foregroundColor(.secondary)
                
                Picker("Timer configuration", selection: $pomodoro.preset) {
                    ForEach(PomodoroModel.Preset.allCases) { preset in
                        Text(preset.description)
                            .tag(preset)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
            
            SerenityButton("Start timer", icon: "timer") {
                withAnimation(.screen) {
                    pomodoro.start()
                }
            }
        }
    }
}
