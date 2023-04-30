import SwiftUI

// MARK: - Breathing View

struct BreathingView: View {
    
    @EnvironmentObject var model: SerenityModel
    
    @StateObject var breathing = BreathingModel()
    
    // MARK: Computed
    
    /// Alias to use instead of `.allCases`.
    var breathingExercises: [BreathingExercise] {
        BreathingExercise.allCases
    }
    
    // MARK: Content
    
    var body: some View {
        PreventionContainer(for: .breathing) {
            switch breathing.state {
            case .idle:
                introductoryView
                    .transition(.prevention)
            case let .exercise(exercise):
                BreathingExerciseView(for: exercise)
                    .transition(.prevention)
            case let .activity(exercise: exercise):
                if exercise == .box {
                    BoxBreathingActivity()
                }
            }
        }
        .environmentObject(breathing)
    }
    
    var introductoryView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Breathing Exercises")
                .preventionTitle()
            
            VStack(spacing: 16) {
                ForEach(breathingExercises) { exercise in
                    exerciseButton(for: exercise)
                }
            }
        }
    }
    
    @ViewBuilder
    func exerciseButton(for exercise: BreathingExercise) -> some View {
        Button {
            withAnimation(.screen) {
                breathing.state = .exercise(exercise: exercise)
            }
        } label: {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.quotes.title)
                        .font(.breathingExerciseTitle)
                        .textCase(.uppercase)
                    
                    BreathingExerciseInfoRow(for: exercise)
                    
                    Text(exercise.quotes.body)
                        .font(._caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .primary.opacity(0.1), radius: 4, x: 1, y: 2)
            }
        }
        .buttonStyle(.exercise)
    }
}

// MARK: - Exercise Button Style

struct ExerciseButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        configuration.label
            .scaleEffect(isPressed ? 0.96 : 1)
            .opacity(isPressed ? 0.5 : 1)
            .animation(.button, value: isPressed)
    }
}

fileprivate extension ButtonStyle where Self == ExerciseButtonStyle {
    
    static var exercise: ExerciseButtonStyle {
        ExerciseButtonStyle()
    }
}
