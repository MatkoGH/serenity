import SwiftUI

// MARK: - Exercise View

struct BreathingExerciseView: View {
    
    @EnvironmentObject var breathing: BreathingModel
    
    /// The exercise to display.
    var exercise: BreathingExercise
    
    // MARK: Computed
    
    /// Short-hand for the title of this exercise.
    var title: String {
        exercise.quotes.title
    }
    
    /// The enumerated steps for this exercise.
    var enumeratedSteps: [EnumeratedSequence<[String]>.Element] {
        Array(exercise.quotes.steps.enumerated())
    }
    
    /// The foreground style to use for section titles.
    var sectionTitleStyle: some ShapeStyle {
        LinearGradient(
            gradient: .serenityGreen,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: Init
    
    init(for exercise: BreathingExercise) {
        self.exercise = exercise
    }
    
    // MARK: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .preventionTitle()
                
                BreathingExerciseInfoRow(for: exercise)
            }
            
            section("About This Exercise") {
                Text(exercise.quotes.body)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
            }
            
            section("Steps to Perform") {
                ForEach(enumeratedSteps, id: \.offset) { offset, step in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(offset + 1).")
                            .font(._subheading)
                            .foregroundColor(.secondary)
                        
                        Text(step)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                }
            }
            
            HStack(spacing: 8) {
                SerenitySecondaryButton("Back", icon: "arrow.left", iconOnly: false) {
                    withAnimation(.screen) {
                        breathing.state = .idle
                    }
                }
                
                Spacer()
                
                SerenityButton("Start activity", icon: "play") {
                    withAnimation(.screen) {
                        breathing.startActivity()
                    }
                }
                .hidden(!exercise.activityAvailable)
            }
        }
        .preventionTitleVisibility(.minimized)
    }
    
    @ViewBuilder
    func section<Content>(_ title: String, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(._heading)
                .foregroundStyle(sectionTitleStyle)
            
            content()
        }
    }
}

// MARK: - Exercise Info Row

struct BreathingExerciseInfoRow: View {
    
    /// The breathing exercise to list information for.
    var exercise: BreathingExercise
    
    // MARK: Computed
    
    /// Short-hand for whether the exercise has an activity available.
    var activityAvailable: Bool {
        exercise.activityAvailable
    }
    
    /// Short-hand for the exercise's difficulty.
    var difficulty: Quotes.Breathing.Exercise.Difficulty {
        exercise.quotes.difficulty
    }
    
    /// Short-hand for the exercise's duration.
    var duration: String {
        exercise.quotes.duration
    }
    
    // MARK: Init
    
    init(for exercise: BreathingExercise) {
        self.exercise = exercise
    }
    
    // MARK: Content
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            label(duration, image: "clock.fill")
                .foregroundColor(.secondary)
            
            dot
            
            label(difficulty.description, image: "chart.bar.fill", variableValue: difficulty.variableValue)
                .foregroundColor(difficulty.color)
            
            if activityAvailable {
                dot
                
                label("Activity available", image: "play.fill")
                    .foregroundColor(.serenityGreen)
            }
        }
        .font(.breathingExerciseInfo)
    }
    
    @ViewBuilder
    private func label(_ text: String, image imageName: String, variableValue: CGFloat = 1.0) -> some View {
        HStack(spacing: 4) {
            Image(systemName: imageName, variableValue: variableValue)
            Text(text)
        }
    }
    
    var dot: some View {
        Circle()
            .fill(.primary)
            .opacity(0.25)
            .frame(width: 4, height: 4)
            .padding(.bottom, 2)
    }
}

// MARK: - Difficulty Extension

extension Quotes.Breathing.Exercise.Difficulty {
    
    /// The description of the difficulty level.
    var description: String {
        switch self {
        case .easy:
            return "Easy"
        case .normal:
            return "Normal"
        case .difficult:
            return "Difficult"
        }
    }
    
    /// The variable value associated with the difficulty.
    var variableValue: CGFloat {
        switch self {
        case .easy:
            return 0.33
        case .normal:
            return 0.67
        case .difficult:
            return 1.00
        }
    }
    
    /// The color associated with the difficulty.
    var color: Color {
        switch self {
        case .easy:
            return .serenityGreen
        case .normal:
            return .serenityBlue
        case .difficult:
            return .serenityRed
        }
    }
}
