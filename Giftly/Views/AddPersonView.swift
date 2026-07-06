import SwiftUI
import SwiftData
import PhotosUI

struct AddPersonView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(PersonViewModel.self) private var personViewModel

    var person: Person?

    @State private var name: String = ""
    @State private var birthday: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var relationship: String = ""
    @State private var newInterest: String = ""
    @State private var interests: [String] = []
    @State private var notes: String = ""

    private let relationships = [
        "Family", "Friend", "Partner", "Colleague", "Other"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        VStack {
                            PhotosPicker(selection: $photoItem, matching: .images) {
                                if let data = photoData, let image = UIImage(data: data) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color("GiftlyPurple").opacity(0.15))
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.title2)
                                                .foregroundStyle(Color("GiftlyPurple"))
                                        )
                                }
                            }
                            .onChange(of: photoItem) { _, newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                        photoData = data
                                    }
                                }
                            }
                        }

                        TextField("Full name", text: $name)
                            .font(.title3)
                            .submitLabel(.next)
                    }
                }

                Section {
                    DatePicker(
                        "Birthday",
                        selection: $birthday,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                } header: {
                    Text("Birthday")
                }

                Section {
                    Picker("Relationship", selection: $relationship) {
                        Text("None").tag("")
                        ForEach(relationships, id: \.self) { rel in
                            Text(rel).tag(rel)
                        }
                    }
                } header: {
                    Text("Relationship")
                }

                Section {
                    HStack {
                        TextField("Add interest", text: $newInterest)
                            .onSubmit(addInterest)
                        Button(action: addInterest) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(newInterest.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    if !interests.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(interests, id: \.self) { interest in
                                Chip(text: interest) {
                                    interests.removeAll { $0 == interest }
                                }
                            }
                        }
                    }
                } header: {
                    Text("Interests")
                } footer: {
                    Text("Helps AI suggest better gifts.")
                }

                Section {
                    TextEditor(text: $notes)
                        .frame(minHeight: 80)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle(person == nil ? "New Person" : "Edit Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { savePerson() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .fontWeight(.semibold)
                }
            }
            .onAppear { loadPerson() }
        }
    }

    private func loadPerson() {
        guard let person = person else { return }
        name = person.name
        birthday = person.birthday
        photoData = person.photoData
        relationship = person.relationship ?? ""
        interests = person.interests
        notes = person.notes ?? ""
    }

    private func addInterest() {
        let trimmed = newInterest.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty && !interests.contains(trimmed) else { return }
        interests.append(trimmed)
        newInterest = ""
    }

    private func savePerson() {
        if let person = person {
            person.name = name.trimmingCharacters(in: .whitespaces)
            person.birthday = birthday
            person.photoData = photoData
            person.relationship = relationship.isEmpty ? nil : relationship
            person.interests = interests
            person.notes = notes.isEmpty ? nil : notes
            personViewModel.updatePerson(person)
        } else {
            _ = personViewModel.createPerson(
                name: name,
                birthday: birthday,
                photoData: photoData,
                relationship: relationship,
                interests: interests,
                notes: notes
            )
        }
        dismiss()
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rows: [CGFloat] = [0]
        var currentRowWidth: CGFloat = 0
        var currentRowMaxHeight: CGFloat = 0
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentRowWidth + size.width > maxWidth && currentRowWidth > 0 {
                rows.append(0)
                maxHeight += currentRowMaxHeight + spacing
                currentRowWidth = size.width + spacing
                currentRowMaxHeight = size.height
            } else {
                currentRowWidth += size.width + spacing
                currentRowMaxHeight = max(currentRowMaxHeight, size.height)
            }
            rows[rows.count - 1] = currentRowMaxHeight
        }
        maxHeight += currentRowMaxHeight
        return CGSize(width: maxWidth, height: maxHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.minX + maxWidth {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

struct Chip: View {
    let text: String
    var onRemove: (() -> Void)?

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(Color("GiftlyPurple").opacity(0.15))
        )
        .foregroundStyle(Color("GiftlyPurple"))
    }
}

#Preview {
    AddPersonView()
        .environment(AppViewModel())
        .environment(PersonViewModel())
        .modelContainer(for: Person.self, inMemory: true)
}
