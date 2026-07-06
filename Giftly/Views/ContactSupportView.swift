import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appViewModel

    @State private var subject: String = ""
    @State private var message: String = ""
    @State private var includeDiagnostics = true
    @State private var isSending = false
    @State private var sendResult: String?

    private let feedbackBackendURL = "https://feedback-board.iocompile67692.workers.dev"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Subject", text: $subject)
                    TextField("Describe your issue or feedback", text: $message, axis: .vertical)
                        .lineLimit(5...10)
                } header: {
                    Text("Message")
                }

                Section {
                    Toggle("Include app diagnostics", isOn: $includeDiagnostics)
                } footer: {
                    Text("Diagnostics include app version, iOS version, and device model. No personal data.")
                }

                Section {
                    Button {
                        Task { await send() }
                    } label: {
                        HStack {
                            if isSending {
                                ProgressView().tint(.white)
                            }
                            Text(isSending ? "Sending..." : "Send Message")
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("GiftlyPurple"))
                    .disabled(subject.trimmingCharacters(in: .whitespaces).isEmpty
                              || message.trimmingCharacters(in: .whitespaces).isEmpty
                              || isSending)

                    if let result = sendResult {
                        Text(result)
                            .font(.caption)
                            .foregroundStyle(result.contains("success") ? Color("GiftlyMint") : .red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }

                Section {
                    if let url = appViewModel.supportURL() {
                        Link(destination: url) {
                            Label("View Support Page", systemImage: "questionmark.circle")
                        }
                    }
                    Link("Email: \(contactEmail)", destination: URL(string: "mailto:\(contactEmail)?subject=Giftly%20Support")!)
                        .labelStyle(.titleAndIcon)
                } header: {
                    Text("Other ways to reach us")
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var contactEmail: String {
        "iocompile67692@gmail.com"
    }

    private var diagnostics: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        let iosVersion = UIDevice.current.systemVersion
        let device = UIDevice.current.model
        return "App: \(version) (\(build)) | iOS: \(iosVersion) | Device: \(device)"
    }

    private func send() async {
        isSending = true
        sendResult = nil

        let payload: [String: Any] = [
            "subject": subject,
            "message": message + (includeDiagnostics ? "\n\n--- Diagnostics ---\n\(diagnostics)" : ""),
            "app": "Giftly",
            "email": contactEmail
        ]

        guard let url = URL(string: feedbackBackendURL) else {
            isSending = false
            sendResult = "Failed: invalid backend URL."
            return
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) {
                sendResult = "Message sent successfully. We'll reply within 24 hours."
                subject = ""
                message = ""
            } else {
                sendResult = "Failed to send. Please email us directly."
            }
        } catch {
            sendResult = "Network error. Please email us directly."
        }
        isSending = false
    }
}

#Preview {
    ContactSupportView()
        .environment(AppViewModel())
}
