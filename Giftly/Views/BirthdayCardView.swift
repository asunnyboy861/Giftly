import SwiftUI

struct BirthdayCardView: View {
    let person: Person
    let isToday: Bool

    var body: some View {
        HStack(spacing: 14) {
            AvatarView(photoData: person.photoData, name: person.name, size: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let relationship = person.relationship, !relationship.isEmpty {
                    Text(relationship)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 4) {
                    Image(systemName: "cake")
                        .font(.caption)
                    Text(isToday ? "Birthday today!" : "Turning \(person.upcomingAge) in \(person.daysUntilBirthday) days")
                        .font(.subheadline)
                }
                .foregroundStyle(isToday ? Color("GiftlyCoral") : Color("GiftlyPurple"))
            }

            Spacer()

            VStack(spacing: 2) {
                Text(CountdownText)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(isToday ? Color("GiftlyCoral") : Color("GiftlyPurple"))
                if !isToday {
                    Text("days")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isToday ? Color("GiftlyCoral").opacity(0.4) : Color.clear, lineWidth: 1.5)
                )
        )
    }

    private var CountdownText: String {
        if isToday {
            return "🎉"
        }
        return "\(person.daysUntilBirthday)"
    }
}

struct AvatarView: View {
    let photoData: Data?
    let name: String
    var size: CGFloat = 48

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        return parts.compactMap { $0.first.map(String.init) }.joined().uppercased()
    }

    var body: some View {
        if let data = photoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color("GiftlyPurple").opacity(0.15))
                .frame(width: size, height: size)
                .overlay(
                    Text(initials.isEmpty ? "🎁" : initials)
                        .font(.system(size: size * 0.4, weight: .semibold))
                        .foregroundStyle(Color("GiftlyPurple"))
                )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        BirthdayCardView(
            person: Person(name: "Sarah Johnson", birthday: Date()),
            isToday: false
        )
        BirthdayCardView(
            person: Person(name: "Mike Smith", birthday: Date().addingTimeInterval(86400 * 5)),
            isToday: true
        )
    }
    .padding()
}

