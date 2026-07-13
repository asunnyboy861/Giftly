# App Store Connect Reply (Paste into the Reply field)

> Copy the text below and paste it into your reply to the reviewer in App Store Connect.

---

Hello Review Team,

Thank you for the follow-up questions regarding Guideline 2.1. Here are direct answers to both questions:

## 1. Do you upload the user's contacts to the server?

**No.** Giftly does NOT upload user contacts to any server.

Contacts are read locally on the device using Apple's CNContactStore framework. The app only requests the following contact fields: given name, family name, birthday, and photo (CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey, CNContactImageDataKey, CNContactThumbnailImageDataKey). It does NOT request phone numbers, email addresses, postal addresses, or any other fields.

The imported data (name, birthday, photo) is written into the app's local on-device SwiftData database. No network call transmits contact data anywhere. The file responsible for contact import (ContactImportService.swift) contains no URLSession, URL(string:), or any network API.

The only two network calls in the entire app are:
- Optional AI gift suggestions — sends only the person's name, age, relationship, interests, and a budget range. Never the full contact record or contacts list.
- Optional "Contact Support" form — sends only the user-typed subject/message and basic app diagnostics (app version, iOS version, device model). Never contact data.

## 2. Do you share the user's contacts to any third-party?

**No.** Giftly does NOT share user contacts with any third-party.

The app contains zero third-party SDKs — no analytics, no advertising, no tracking, and no crash-reporting SDKs (no Firebase, no Google Analytics, no Mixpanel, no AdMob, no Facebook SDK). There is no data broker, advertising network, or third-party API that receives contact information.

The default AI provider (on iOS 26+) is Apple Intelligence, which runs entirely on-device via the FoundationModels framework — no data leaves the device at all. The optional "Bring Your Own Key" AI path sends only a minimal prompt (name, age, relationship, interests, budget) directly from the device to the user's own chosen AI provider — never the full contact record.

The app's privacy manifest (PrivacyInfo.xcprivacy) declares NSPrivacyTracking: false, NSPrivacyTrackingDomains: [] (empty), and NSPrivacyCollectedDataTypes: [] (empty).

## Supporting Documentation

- Updated Privacy Policy with a dedicated "Contacts Privacy — Direct Answers" section: https://asunnyboy861.github.io/Giftly/privacy.html
- Privacy manifest (PrivacyInfo.xcprivacy) is included in the app bundle
- Detailed review notes with testing instructions are included in the App Review Information → Notes field

We are happy to provide any additional information or code excerpts upon request. Please let us know if anything else is needed to complete the review.

Thank you for your time.

Best regards,
Giftly Developer
iocompile67692@gmail.com
