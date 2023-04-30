import SwiftUI

// MARK: - Onboarding Model

class OnboardingModel: ObservableObject {
    
    /// The amount of sections in the stress walkthrough.
    let sectionCount: Int = Quotes.shared.onboarding.walkthrough.count
    
    /// The current step of the onboarding process.
    @Published var step: OnboardingStep = .hero
    
    /// Checks whether the given page is the last.
    /// - Parameter page: The index of the page to check.
    /// - Returns: A boolean indicating whether it is the last of the pages.
    func isLast(section sectionIndex: Int) -> Bool {
        sectionIndex == sectionCount - 1
    }
    
    /// Gets the step after the provided one in the onboarding process.
    /// - Parameter step: The current step.
    /// - Returns: The step after the provided one.
    func step(after step: OnboardingStep) -> OnboardingStep {
        switch step {
        case .hero:
            return .walkthrough
        default:
            return .hero
        }
    }
}

// MARK: - Onboarding Step

enum OnboardingStep {
    
    /// The hero onboarding step.
    case hero
    
    /// The walkthrough onboarding step.
    case walkthrough
}
