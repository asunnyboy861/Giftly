import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var currentPage = 0
    @State private var isRequestingPermission = false
    @State private var isImporting = false
    @State private var importResult: PersonViewModel.ContactImportResult?
    @State private var showImportAlert = false
    @State private var personViewModel = PersonViewModel()
    @StateObject private var purchaseService = PurchaseService.shared

    @Query private var people: [Person]

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
            subtitle: "Get 3 free AI gift suggestions every month. Track ideas from spark to giving.",
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
                ImportPage
                    .tag(pages.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: 12) {
                if currentPage == pages.count {
                    Button {
                        Task {
                            isImporting = true
                            let result = await personViewModel.importFromContacts(
                                existingPeople: people,
                                isProUnlocked: purchaseService.isProUnlocked
                            )
                            isImporting = false
                            importResult = result
                            showImportAlert = true
                        }
                    } label: {
                        HStack {
                            if isImporting {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isImporting ? "Importing..." : "Continue")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("GiftlyPurple"))
                    .disabled(isImporting)
                    .padding(.horizontal)
                } else if currentPage == pages.count - 1 {
                    Button {
                        withAnimation {
                            currentPage += 1
                        }
                    } label: {
                        HStack {
                            Text("Import Birthdays")
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("GiftlyPurple"))
                    .padding(.horizontal)

                    Button {
                        finishOnboarding()
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
        .onAppear {
            personViewModel.attach(context: modelContext)
        }
        .alert(
            importResult?.denied == true ? "Contact Access Denied"
            : (importResult?.importedCount ?? 0) > 0 ? "Birthdays Imported!"
            : "No New Birthdays Found",
            isPresented: $showImportAlert
        ) {
            if importResult?.denied == true {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    importResult = nil
                    finishOnboarding()
                }
                Button("Skip", role: .cancel) {
                    importResult = nil
                    finishOnboarding()
                }
            } else {
                Button("Let's Go!") {
                    importResult = nil
                    finishOnboarding()
                }
            }
        } message: {
            if let result = importResult {
                if result.denied {
                    Text("Giftly needs access to your contacts to import birthdays. Please enable Contacts access in Settings, or add them manually later.")
                } else if result.importedCount > 0 {
                    Text("Successfully imported \(result.importedCount) birthday\(result.importedCount == 1 ? "" : "s") from your contacts. We'll remind you before each one!")
                } else {
                    Text("No new birthdays found in your contacts. You can add them manually in the app.")
                }
            }
        }
    }

    private var ImportPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.2.badge.gearshape")
                .font(.system(size: 100, weight: .light))
                .foregroundStyle(Color("GiftlyMint").gradient)
                .padding(.bottom, 8)

            Text("Import in One Tap")
                .font(.largeTitle.weight(.bold))
                .multilineTextAlignment(.center)

            Text("Giftly reads ONLY names, birthdays, and photos from your contacts. No phone numbers, emails, or addresses.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.caption)
                Text("Privacy-first: Your data stays on your device")
                    .font(.caption)
            }
            .foregroundStyle(Color("GiftlyMint"))
            .padding(.bottom, 8)

            Spacer()
            Spacer()
        }
        .padding()
    }

    private func finishOnboarding() {
        Task {
            isRequestingPermission = true
            _ = await appViewModel.requestNotificationPermission()
            isRequestingPermission = false
            appViewModel.completeOnboarding()
        }
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
        .modelContainer(for: [Person.self, GiftIdea.self, GiftHistory.self], inMemory: true)
}
