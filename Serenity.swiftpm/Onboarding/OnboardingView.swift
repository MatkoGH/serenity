import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {
    
    @EnvironmentObject var model: SerenityModel
    
    @StateObject var onboarding = OnboardingModel()
    
    // MARK: Content
    
    var body: some View {
        ZStack {
            switch onboarding.step {
            case .hero:
                heroView
                    .transition(.scaling)
            case .walkthrough:
                Walkthrough(sections: Quotes.shared.onboarding.walkthrough) {
                    withAnimation(.screen) {
                        model.isOnboarding = false
                    }
                }
                .transition(.scaling)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(onboarding)
    }
    
    var heroView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ZStack {
                    Image("SloganBanner")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(idealHeight: 158, maxHeight: 158)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                SerenityButton("Let's go", icon: "arrow.down") {
                    withAnimation(.onboardingStep) {
                        onboarding.step = onboarding.step(after: .hero)
                    }
                }
            }
            .padding(24)
            .background {
                RadialGradient(gradient: .backgroundSerenityGreen, center: .top, startRadius: 0, endRadius: geometry.size.height)
                    .ignoresSafeArea()
                    .opacity(0.3)
            }
        }
    }
}
