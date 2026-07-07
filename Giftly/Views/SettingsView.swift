import SwiftUI
import SwiftData
import StoreKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppViewModel.self) private var appViewModel
    @EnvironmentObject private var purchaseService: PurchaseService

    @Query private var people: [Person]

    @State private var apiKey: String = ""
    @State private var showingAPIKey: Bool = false
    @State private var customModel: String = ""
    @State private var customBaseURL: String = ""
    @State private var showingExportSheet = false
    @State private var exportFileURL: URL?
    @State private var showingImportPicker = false
    @State private var showingPaywall = false
    @State private var showingSupport = false

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                PurchaseSection
                APIKeySection
                NotificationsSection
                SupportSection
                LegalSection
                AboutSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
            .sheet(isPresented: $showingSupport) {
                ContactSupportView()
            }
            .sheet(isPresented: $showingExportSheet) {
                if let url = exportFileURL {
                    ActivityShareView(items: [url])
                }
            }
            .onAppear {
                apiKey = GiftAIService.shared.getAPIKey() ?? ""
                customModel = GiftAIService.shared.getModel()
                customBaseURL = GiftAIService.shared.getBaseURL()
            }
        }
    }

    private var PurchaseSection: some View {
        Section {
            if purchaseService.isProUnlocked {
                Label("Giftly Pro — Active", systemImage: "checkmark.seal.fill")
                    .foregroundStyle(Color("GiftlyMint"))
            } else {
                Button {
                    showingPaywall = true
                } label: {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(Color("GiftlyPurple"))
                        Text("Upgrade to Giftly Pro")
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if purchaseService.isAIUnlocked {
                Label("AI Add-on — Active", systemImage: "wand.and.stars")
                    .foregroundStyle(Color("GiftlyCoral"))
            }
        } header: {
            Text("Purchases")
        }
    }

    private var APIKeySection: some View {
        Section {
            HStack {
                if showingAPIKey {
                    TextField("API Key", text: $apiKey)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    SecureField("API Key", text: $apiKey)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                Button {
                    showingAPIKey.toggle()
                } label: {
                    Image(systemName: showingAPIKey ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
            }
            TextField("Model name", text: $customModel)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            TextField("Base URL (ChatCompletions-compatible)", text: $customBaseURL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("Save API Settings") {
                GiftAIService.shared.saveAPIKey(apiKey)
                GiftAIService.shared.saveModel(customModel)
                GiftAIService.shared.saveBaseURL(customBaseURL)
            }
            .disabled(apiKey.trimmingCharacters(in: .whitespaces).isEmpty && customModel.trimmingCharacters(in: .whitespaces).isEmpty && customBaseURL.trimmingCharacters(in: .whitespaces).isEmpty)
            if apiKey.isEmpty {
                Text("Bring your own API key. Stored securely in Keychain. We never see or store your key.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Button(role: .destructive) {
                    GiftAIService.shared.deleteAPIKey()
                    apiKey = ""
                } label: {
                    Label("Remove API Key", systemImage: "trash")
                }
            }
        } header: {
            Text("AI Configuration")
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                Text("Bring Your Own Key (BYO Key) model: your AI calls go directly to your provider. Giftly never sees or stores your key.")
                Text("Get an API key from your preferred AI provider (any ChatCompletions-compatible service works).")
                    .font(.caption)
            }
        }
    }

    private var NotificationsSection: some View {
        Section {
            HStack {
                Image(systemName: "bell.badge.fill")
                    .foregroundStyle(Color("GiftlyPurple"))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Birthday Reminders")
                    Text(notificationsEnabled ? "Enabled" : "Disabled")
                        .font(.caption)
                        .foregroundStyle(notificationsEnabled ? Color("GiftlyMint") : .secondary)
                }
                Spacer()
                Button("Manage") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(Color("GiftlyPurple"))
            }
            NavigationLink {
                NotificationSettingsView()
            } label: {
                Label("Notification Settings", systemImage: "gearshape.arrow.2.circle")
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Reminders fire 7 days, 1 day, and on the day at 9 AM. Tap Manage to change permission in iOS Settings.")
        }
    }

    private var notificationsEnabled: Bool {
        UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }

    private var SupportSection: some View {
        Section {
            Button {
                showingSupport = true
            } label: {
                Label("Contact Support", systemImage: "envelope.fill")
            }
            Button {
                exportData()
            } label: {
                Label("Export Backup", systemImage: "square.and.arrow.up")
            }
            Button {
                showingImportPicker = true
            } label: {
                Label("Import Backup", systemImage: "square.and.arrow.down")
            }
        } header: {
            Text("Support & Backup")
        }
        .fileImporter(isPresented: $showingImportPicker, allowedContentTypes: [.json]) { result in
            handleImport(result)
        }
    }

    private var LegalSection: some View {
        Section {
            if let url = appViewModel.privacyPolicyURL() {
                Link(destination: url) {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }
            }
            if let url = appViewModel.termsOfUseURL() {
                Link(destination: url) {
                    Label("Terms of Use", systemImage: "doc.text")
                }
            }
            if let url = appViewModel.supportURL() {
                Link(destination: url) {
                    Label("Support Page", systemImage: "questionmark.circle")
                }
            }
        } header: {
            Text("Legal")
        }
    }

    private var AboutSection: some View {
        Section {
            HStack {
                Label("Giftly", systemImage: "gift.fill")
                    .foregroundStyle(Color("GiftlyPurple"))
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
            if let url = appViewModel.supportURL() {
                Link(destination: url) {
                    HStack {
                        Label("Help & FAQ", systemImage: "questionmark.circle")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        } header: {
            Text("About")
        }
    }

    private func exportData() {
        if let data = DataExportService.shared.exportPeople(people) {
            exportFileURL = DataExportService.shared.saveExportToFile(data)
            showingExportSheet = true
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let accessed = url.startAccessingSecurityScopedResource()
            defer {
                if accessed { url.stopAccessingSecurityScopedResource() }
            }
            let data = try Data(contentsOf: url)
            try DataExportService.shared.importPeople(from: data, into: modelContext)
        } catch {
            print("Import failed: \(error)")
        }
    }
}

struct NotificationSettingsView: View {
    @State private var pendingCount: Int = 0

    var body: some View {
        Form {
            Section {
                Text("Giftly sends 3 reminders for each birthday:")
                    .font(.body)
                VStack(alignment: .leading, spacing: 8) {
                    Label("7 days before at 9 AM", systemImage: "calendar.badge.exclamationmark")
                    Label("1 day before at 9 AM", systemImage: "calendar.badge.clock")
                    Label("On the birthday at 9 AM", systemImage: "party.popper")
                }
                .padding(.vertical, 4)
            } header: {
                Text("How Reminders Work")
            } footer: {
                Text("Reminders repeat yearly. To change notification permission, use iOS Settings.")
            }

            Section {
                HStack {
                    Text("Pending reminders")
                    Spacer()
                    Text("\(pendingCount)")
                        .foregroundStyle(.secondary)
                }
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Open iOS Settings", systemImage: "gear")
                }
            } header: {
                Text("Status")
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            pendingCount = await NotificationService.shared.getPendingNotificationCount()
        }
    }
}

struct ActivityShareView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .environment(AppViewModel())
        .environmentObject(PurchaseService.shared)
        .modelContainer(for: [Person.self, GiftIdea.self, GiftHistory.self], inMemory: true)
}
