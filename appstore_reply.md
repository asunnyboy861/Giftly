# App Store Connect Reply (Paste into the Reply field)

> Copy the text below and paste it into your reply to the reviewer in App Store Connect for the July 14, 2026 rejection of Giftly Pro 1.0 (5).

---

Hello Review Team,

Thank you for the detailed feedback. We have thoroughly addressed all three issues raised in the July 14, 2026 review. Below are our direct responses and the changes made.

---

## Guideline 2.1 — Information Needed (Contacts Privacy)

### Q1: Do you upload the user's contacts to the server?

**No.** Giftly does NOT upload user contacts to any server.

- Contacts are read locally on the device using Apple's `CNContactStore` framework (`Giftly/Services/ContactImportService.swift`).
- The app requests only these contact keys: `CNContactGivenNameKey`, `CNContactFamilyNameKey`, `CNContactBirthdayKey`, `CNContactImageDataKey`, `CNContactThumbnailImageDataKey`.
- It does NOT request phone numbers, email addresses, postal addresses, or any other contact fields.
- Imported data (name, birthday, photo) is stored in the app's local on-device SwiftData database.
- No network call in the app transmits contact data. The only network call is the optional "Contact Support" form, which sends only the user-typed subject/message and basic app diagnostics (app version, iOS version, device model) — never contact data.

### Q2: Do you share the user's contacts to any third-party?

**No.** Giftly does NOT share user contacts with any third-party.

- The app contains zero third-party SDKs: no analytics, no advertising, no tracking, no crash-reporting SDKs.
- No data broker, advertising network, or third-party API receives contact information.
- AI suggestions now run entirely on-device via Apple Intelligence (FoundationModels framework, iOS 26+) — no data leaves the device.
- `PrivacyInfo.xcprivacy` declares `NSPrivacyTracking: false`, `NSPrivacyTrackingDomains: []`, and `NSPrivacyCollectedDataTypes: []`.

---

## Guideline 5 — Legal (China App Store Compliance)

We have completely removed all references to ChatGPT, OpenAI, GPT, and any third-party AI provider from the app and its metadata.

### Code changes
- Deleted `Giftly/Services/GiftAIService.swift` (the previous BYO/third-party API path).
- AI suggestions now use **only** Apple Intelligence (`FoundationModels` framework, iOS 26+), running entirely on-device.
- Removed all user-facing strings referring to API keys or external AI providers.

### Metadata and policy changes
- App Store metadata (`keytext.md`): no references to ChatGPT, OpenAI, GPT, API keys, or BYO.
- Privacy Policy (`docs/privacy.html`): updated AI section to describe Apple Intelligence on-device processing only.
- Terms of Use (`docs/terms.html`): replaced the "Bring Your Own Key" section with an "AI Feature — Apple Intelligence" section.
- Support Page (`docs/support.html`): updated AI FAQ to describe Apple Intelligence only.
- Landing Page (`docs/index.html`): removed all API-key and third-party-AI references.
- App Review Information (`app_review_info.md`): removed the BYO Key testing path and all third-party AI provider references.

The app is now compliant for distribution in all regions, including China mainland.

---

## Guideline 3.1.1 — Business / Payments / In-App Purchase

We have removed the BYO (Bring Your Own) API Key model entirely. Users can no longer unlock or enable any functionality with an external API key.

### What changed
- There are only two In-App Purchase products, both one-time non-consumable purchases processed by Apple StoreKit 2:
  - **Giftly Pro** ($4.99) — removes the 5-contact limit, enables contact import, gift tracking, gift history, and data export.
  - **AI Add-on** ($5.99) — unlocks unlimited AI gift suggestions.
- The AI Add-on unlocks unlimited on-device suggestions via Apple Intelligence. No API key, no external service, and no outside mechanism is involved.
- The free tier still includes 3 AI suggestions per month without any purchase.
- All feature unlocking is handled through StoreKit 2 `Transaction.currentEntitlement(for:)`; no external keys or codes are accepted.

---

## Supporting Documentation

- Updated Privacy Policy: https://asunnyboy861.github.io/Giftly/privacy.html
- Updated Terms of Use: https://asunnyboy861.github.io/Giftly/terms.html
- Updated Support Page: https://asunnyboy861.github.io/Giftly/support.html
- Privacy manifest (`PrivacyInfo.xcprivacy`) is included in the app bundle.
- Detailed review notes with testing instructions are in the App Review Information → Notes field.

Please let us know if any additional information is needed. We appreciate your time and guidance.

Best regards,
Giftly Developer
iocompile67692@gmail.com
