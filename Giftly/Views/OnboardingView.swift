import SwiftUI

struct OnboardingView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var currentPage = 0
    @State private var isRequestingPermission = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "gift.fill",
            title: "Never Forget a Birthday",
            subtitle: "Giftly helps you remember every important birthday and plan thoughtful gifts for the people you love.",
            accentColor: "GiftlyPurple"
        ),
        OnboardingPage(
            icon: "wand.and.stars",
            title: "Plan Gifts with AI",
            subtitle: "Get smart gift suggestions based on interests, age, and budget. Track ideas from spark to giving.",
            accentColor: "GiftlyCoral"
        ),
        OnboardingPage(
            icon: "bell.badge.fill",
            title: "Smart Reminders",
            subtitle: "Get notified 7 days, 1 day, and on the day of every birthday. Always be prepared.",
            accentColor: "GiftlyMint"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: 12) {
                if currentPage == pages.count - 1 {
                    Button {
                        Task {
                            isRequestingPermission = true
                            _ = await appViewModel.requestNotificationPermission()
                            isRequestingPermission = false
                            appViewModel.completeOnboarding()
                        }
                    } label: {
                        HStack {
                            if isRequestingPermission {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isRequestingPermission ? "Setting up..." : "Get Started")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("GiftlyPurple"))
                    .disabled(isRequestingPermission)
                    .padding(.horizontal)

                    Button {
                        appViewModel.completeOnboarding()
                    } label: {
                        Text("Maybe later")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Button {
                        withAnimation {
                            currentPage += 1
                        }
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("GiftlyPurple"))
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 24)
            .padding(.top, 8)
        }
        .background(Color(.systemBackground))
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 100, weight: .light))
                .foregroundStyle(Color(page.accentColor).gradient)
                .padding(.bottom, 8)

            Text(page.title)
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
        .environment(AppViewModel())
}
