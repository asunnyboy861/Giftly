# App Store Connect Reply (Paste into the Reply field)

> Copy the text below and paste it into your reply to the reviewer in App Store Connect for the July 16, 2026 rejection of Giftly Pro 1.0 (6).

---

Hello Review Team,

Thank you for the detailed feedback. We have addressed all three issues raised in the July 16, 2026 review (Guideline 5.1.1(iv), Guideline 2.3, and Guideline 2.1). Below are our direct responses and the changes made in Build 7.

---

## Guideline 5.1.1(iv) — Permission Request UI (FIXED)

We revised the pre-permission message before the Contacts permission request. Two changes were made:

**1. Button text changed to "Continue"**
The button on the onboarding import page previously said "Import from Contacts". It now says **"Continue"**, which proceeds directly to the system Contacts permission dialog.

**2. "Skip for now" button removed**
The "Skip for now" button that allowed users to close the pre-permission message and delay the permission request has been **completely removed**. Users now always proceed to the system Contacts permission request after the message.

**Fixed flow**: 3 onboarding pages → "Import in One Tap" page with a single "Continue" button → system Contacts permission dialog → user grants or denies in the system dialog → app proceeds accordingly.

The pre-permission message only explains why contacts are needed ("Giftly reads ONLY names, birthdays, and photos from your contacts. No phone numbers, emails, or addresses.") and does not block or delay the permission request.

**File changed**: `Giftly/Views/OnboardingView.swift`

---

## Guideline 2.3 — AI Configuration (FEATURE IS IMPLEMENTED)

The AI feature is fully implemented in the app. It is not a separate "AI configuration" screen — AI gift suggestions are accessed per-person from the Person Detail View.

**How to locate AI features:**
1. Tap the **"+"** button (top-right) on the Home tab to add a person (name + birthday)
2. Tap that person's birthday card to open **Person Detail**
3. In the **"Gift Ideas"** section, tap the **"AI Ideas"** button (wand.and.stars icon)
4. The **AI Suggestions** screen opens with budget sliders and a "Generate Ideas" button

**Settings → AI Provider section**: Shows the status of Apple Intelligence (Active/Unavailable) with a footer explaining how to access AI Ideas: *"To use AI suggestions: open any person's detail and tap 'AI Ideas'."*

**Why AI may appear unavailable on the review device (iPad Air 11-inch M3):**
Apple Intelligence requires iOS 26+ with Apple Intelligence enabled in iOS Settings → Apple Intelligence & Siri. If it is not available (e.g., simulator environment or AI not enabled), the AI Suggestions screen shows an **"Apple Intelligence Required"** guidance state. This is the feature working as designed — it is not a missing feature or an error. The app uses Apple Intelligence (on-device) as the only AI provider; no external API key or third-party AI provider is involved.

**Files**: `Giftly/Views/PersonDetailView.swift` (AI Ideas button), `Giftly/Views/GiftSuggestionView.swift` (AI screen), `Giftly/Services/AppleIntelligenceService.swift` (on-device AI), `Giftly/Views/SettingsView.swift` (AI Provider section)

---

## Guideline 2.1 — Contacts Upload Question

**Q: Do you upload the user's contacts to the server?**

**No.** Giftly does NOT upload user contacts to any server.

- Contacts are read locally on the device using Apple's `CNContactStore` framework (`Giftly/Services/ContactImportService.swift`).
- The app requests only these contact keys: `CNContactGivenNameKey`, `CNContactFamilyNameKey`, `CNContactBirthdayKey`, `CNContactImageDataKey`, `CNContactThumbnailImageDataKey` — no phone numbers, emails, or addresses.
- Imported data (name, birthday, photo) is stored in the app's local on-device SwiftData database.
- No network call in the app transmits contact data. The only network call is the optional "Contact Support" form, which sends only the user-typed subject/message and basic app diagnostics (app version, iOS version, device model) — never contact data.
- AI gift suggestions run entirely on-device via Apple Intelligence — no network call is made for AI suggestions.
- `PrivacyInfo.xcprivacy` declares `NSPrivacyTracking: false` and an empty `NSPrivacyCollectedDataTypes` array.

---

## Supporting Documentation

- Updated Privacy Policy: https://asunnyboy861.github.io/Giftly/privacy.html
- Updated Terms of Use: https://asunnyboy861.github.io/Giftly/terms.html
- Updated Support Page: https://asunnyboy861.github.io/Giftly/support.html
- Privacy manifest (`PrivacyInfo.xcprivacy`) is included in the app bundle.
- Detailed review notes with step-by-step AI navigation are in the App Review Information → Notes field.

Please let us know if any additional information is needed. We appreciate your time and guidance.

Best regards,
Giftly Developer
iocompile67692@gmail.com
