# Giftly — App Review Information (Reply to Review Team)

> Paste the content of the "Review Notes (Reply)" section below into the App Review Information → Notes field in App Store Connect. This document directly answers the 3 issues raised in the July 16, 2026 review (Guidelines 5.1.1(iv), 2.3, and 2.1), plus the 7 items from the original review template.

---

## App Overview

- **App Name**: Giftly
- **Bundle ID**: com.zzoutuo.Giftly
- **Version**: 1.0 (Build 7)
- **Category**: Lifestyle / Productivity
- **Pricing**: Free with In-App Purchases (one-time, non-consumable — NO subscriptions)
- **Demo Account**: Not required. Giftly is fully offline and accountless. All features are accessible immediately after download.

---

## Response to Guideline 5.1.1(iv) (July 16, 2026) — Permission Request UI

The review team identified two issues with the pre-permission message before the Contacts permission request. Both have been fixed in Build 7.

### Issue 1: Button text "Import from Contacts" → renamed to "Continue"

**Fixed.** The button on the onboarding import page (the custom message before the permission request) now says **"Continue"** instead of "Import from Contacts". Tapping "Continue" proceeds directly to the system Contacts permission dialog.

**File**: `Giftly/Views/OnboardingView.swift` — the button label on the final onboarding page (ImportPage) was changed from `"Import from Contacts"` to `"Continue"`.

### Issue 2: "Skip for now" button removed

**Fixed.** The "Skip for now" button that allowed users to close the pre-permission message and delay the permission request has been **completely removed**. Users now always proceed to the system Contacts permission request after the pre-permission message.

**File**: `Giftly/Views/OnboardingView.swift` — the secondary button (`Text(people.isEmpty ? "Skip for now" : "Done")`) was removed from the `currentPage == pages.count` branch.

### How the fixed flow works

1. User swipes through 3 onboarding pages (welcome → AI → reminders)
2. On the final "Import in One Tap" page, a single **"Continue"** button is shown
3. Tapping "Continue" triggers `CNContactStore.requestAccess(for: .contacts)` — the system permission dialog appears
4. User grants or denies in the **system** dialog (this is where the user has control)
5. If granted: contacts with birthdays are imported; a success alert appears; user taps "Let's Go!" to finish onboarding
6. If denied: a post-permission alert offers "Open Settings" (to grant later) or "Cancel" (to continue without contacts). This alert appears AFTER the system permission dialog, which is compliant.

**Note**: The pre-permission message only explains WHY contacts are needed ("Giftly reads ONLY names, birthdays, and photos from your contacts. No phone numbers, emails, or addresses.") and does not block or delay the permission request.

---

## Response to Guideline 2.3 (July 16, 2026) — AI Configuration Metadata

The review team was unable to locate "AI configuration" described in the metadata. The AI feature IS fully implemented in the app. Below is exactly where to find it.

### Where AI features are located

AI gift suggestions are **not** a separate settings/configuration screen. They are accessed **per-person** from the Person Detail View:

1. **Add a person**: Tap the **"+"** button (top-right) on the Home tab → enter name + birthday → Save
2. **Open Person Detail**: Tap the person's birthday card on the Home tab
3. **Tap "AI Ideas"**: In the "Gift Ideas" section of Person Detail, tap the **"AI Ideas"** button (wand.and.stars icon, coral tint)
4. **AI Suggestions screen opens**: Shows budget sliders, a "Generate Ideas" button, and a usage banner ("3 of 3 free suggestions remaining this month")

**File references**:
- `Giftly/Views/PersonDetailView.swift` — the "AI Ideas" button is in `GiftIdeasSection` (around line 231)
- `Giftly/Views/GiftSuggestionView.swift` — the AI suggestions screen with budget sliders and generation
- `Giftly/Services/AppleIntelligenceService.swift` — the on-device AI service (FoundationModels framework, iOS 26+)

### Settings → AI Provider section

The Settings tab has an **"AI Provider"** section that shows the **status** of Apple Intelligence:
- If Apple Intelligence is available (iOS 26+ on supported device with AI enabled): shows "Apple Intelligence — Active"
- If unavailable: shows "Apple Intelligence — Unavailable"
- The section footer now includes navigation guidance: *"To use AI suggestions: open any person's detail and tap 'AI Ideas'. Giftly uses Apple Intelligence on-device — no setup needed. Your data never leaves your device. AI requires iOS 26+ with Apple Intelligence enabled."*

**File**: `Giftly/Views/SettingsView.swift` — `AIProviderSection` (around line 80)

### Why AI may appear unavailable on the review device

The review was conducted on **iPad Air 11-inch (M3)**. Apple Intelligence requires:
- iOS 26 or later
- Apple Intelligence enabled in iOS Settings → Apple Intelligence & Siri

If Apple Intelligence is not enabled (or the review environment is a simulator where Apple Intelligence is not available), the AI Suggestions screen shows an **"Apple Intelligence Required"** guidance state with instructions to enable it in Settings. **This is the feature working as designed** — it is not a missing feature or an error. The app does not use any external AI provider or API key; Apple Intelligence is the only AI provider.

### Metadata accuracy

The app description and What's New mention "AI Gift Suggestions" and "Powered by Apple Intelligence on-device". These are accurate — the feature is implemented and accessible as described above. There is no reference to "AI configuration" as a separate screen in the metadata; the term "AI configuration" in the review feedback likely refers to the AI feature in general, which is located in Person Detail → "AI Ideas".

---

## Response to Guideline 2.1 (July 16, 2026) — Contacts Upload Question

### Q: Do you upload the user's contacts to the server?

**No.** Giftly does **NOT** upload user contacts to any server.

**Technical evidence:**
- Contacts are read locally on the device using Apple's `CNContactStore` framework (in `Giftly/Services/ContactImportService.swift`).
- The fetch request only requests these keys: `CNContactGivenNameKey`, `CNContactFamilyNameKey`, `CNContactBirthdayKey`, `CNContactImageDataKey`, `CNContactThumbnailImageDataKey`. It does **not** request phone numbers, email addresses, postal addresses, or any other fields.
- The imported data (name, birthday, photo) is written into the app's local on-device SwiftData database. No `URLSession`, `URL(string:)`, or any network API is called in `ContactImportService.swift`.
- A full codebase audit confirms there is no network call anywhere in the app that transmits contact data. AI gift suggestions run entirely on-device via Apple Intelligence — no network call is made for AI suggestions. The only network call in the entire app is the optional "Contact Support" form (sends only user-typed subject/message + app version/iOS/device diagnostics — never contact data).
- `PrivacyInfo.xcprivacy` declares `NSPrivacyTracking: false` and an empty `NSPrivacyCollectedDataTypes` array.

**Files referenced for verification:**
- `Giftly/Services/ContactImportService.swift` — local-only contact read (no network calls)
- `Giftly/Views/ContactSupportView.swift` — support form payload (no contact data)
- `Giftly/Services/AppleIntelligenceService.swift` — on-device AI (iOS 26+, no network)
- `Giftly/PrivacyInfo.xcprivacy` — privacy manifest
- Updated Privacy Policy: https://asunnyboy861.github.io/Giftly/privacy.html (see "Contacts Privacy — Direct Answers" section)

---

## 1. Screen Recording (Physical Device)

A screen recording has been captured on a physical iPhone running the latest iOS and is attached to this submission. The recording demonstrates the full typical user flow:

1. **Launch** the app from the Home screen (cold start)
2. **Onboarding** — 3-page welcome → final "Import in One Tap" page → tap "Continue" → Contacts permission prompt (tap Allow) → birthdays imported
3. **Add a birthday manually** — tap "+" → fill name, birthday, photo, relationship → Save (confetti animation)
4. **Birthday cards** — today's birthday (pink border) + upcoming birthdays with countdown
5. **Person detail** — tap a card → age, zodiac, gift ideas, gift history
6. **AI Ideas** — in Person Detail, tap "AI Ideas" → set budget → Generate Ideas (requires iOS 26+ with Apple Intelligence)
7. **Gift idea tracking** — add a gift idea → advance status Idea → Planned → Purchased → Given
8. **Calendar tab** — all birthdays grouped by month
9. **Settings tab → AI Provider** — shows Apple Intelligence status; footer explains how to access AI Ideas
10. **Settings tab → Upgrade** — Paywall showing both IAP products with prices, Privacy Policy & Terms of Use links
11. **IAP purchase flow** — tap a purchase button → Apple purchase sheet (Sandbox)

**Permission prompts shown in recording**: Notifications, Contacts. No App Tracking Transparency prompt (app does not track). No camera/photo-library prompts (uses PhotosPicker, which requires no permission).

**Note on account flows**: Giftly has NO account registration, login, or account deletion — it is fully accountless and offline. All user data is stored locally on-device using SwiftData. This is confirmed in the Privacy Policy.

---

## 2. Device Models & Operating Systems Tested

The app was tested on the following devices/simulators before submission:

| Device | Type | OS | Tested |
|---|---|---|---|
| iPhone 16 | Simulator | iOS 26.4 | Build, launch, UI, IAP (StoreKit config) |
| iPhone Xs Max | Simulator | iOS 18.4 | Build, launch, full feature flow |
| iPad Pro 13-inch (M5) | Simulator | iOS 26.4 | Build, launch, layout |

Testing covered: app launch, onboarding, manual person entry, contact import, birthday notifications scheduling, gift idea CRUD + status transitions, gift history, calendar view, search, favorites, data export/import, both IAP products (StoreKit Configuration file), restore purchases, AI suggestions via Apple Intelligence (iOS 26+), and dark mode.

A physical-device screen recording (item 1) and physical-device testing were also performed.

---

## 3. App Purpose & Target Audience

**Purpose**: Giftly is a privacy-first birthday and gift reminder app. It solves three concrete problems:
1. **Forgetting birthdays** — users get 3-tier reminders (7 days, 1 day, day-of at 9 AM) that repeat yearly, so they never miss an important birthday.
2. **Not knowing what gift to buy** — the app tracks gift ideas per person and offers AI-generated gift suggestions based on interests, age, and budget.
3. **Accidentally giving duplicate gifts** — a built-in gift history log shows every gift previously given to each person, preventing repeats.

**Target audience**: 
- Family-oriented users (35%) who track birthdays of children, spouse, parents, siblings
- Socially active users (25%) with large friend circles
- Professionals (20%) who maintain client/colleague relationships
- Privacy-sensitive users (15%) who want local-only, no-cloud, no-account data storage
- Anti-subscription users (5%) who prefer one-time purchases over recurring subscriptions

**Value provided**: Never forget a birthday, always have a gift planned, and never repeat a gift — all with one-time pricing (no subscriptions) and complete data privacy (all data stays on-device).

---

## 4. Setup & Access Instructions

**No setup required.** Giftly is accountless and works immediately after download.

**To test the app:**
1. Launch Giftly — onboarding appears on first launch (3 welcome pages → final "Import in One Tap" page with a "Continue" button → Contacts permission prompt)
2. Tap **"+"** (top-right) on the Home tab to add a person manually: enter name, birthday, optional photo/relationship/interests/notes → Save
3. Tap the **contacts icon** (top-left) on the Home tab to import birthdays from Contacts (permission required — app reads ONLY name, birthday, photo; never phone/email/address)
4. Tap any birthday card to open **Person Detail** — see age, zodiac, gift ideas, gift history
5. In Person Detail, tap **"AI Ideas"** (in the Gift Ideas section) to open the AI Suggestions screen
6. Tap **"View List"** on a person to add gift ideas and advance their status (Idea → Planned → Purchased → Given)
7. Switch to the **Calendar** tab to see all birthdays by month
8. Switch to the **Settings** tab → **AI Provider** section shows Apple Intelligence status; export/import data; view legal pages; or upgrade

**Login credentials**: None required (no account system).

**Sample files**: None required. Users add their own birthdays manually or import from Contacts.

**AI feature testing**:

*Apple Intelligence (default, on-device, iOS 26+)*
1. On an iOS 26+ device with Apple Intelligence enabled, open any person → tap "AI Ideas" in the Gift Ideas section
2. The provider is Apple Intelligence — 3 free suggestions per month
3. Set a budget range → "Generate Ideas" — suggestions are generated on-device; no data leaves the device
4. After 3 free uses, the "Generate Ideas" button shows the Paywall (not an error)
5. Purchase "AI Add-on" ($5.99) for unlimited on-device suggestions
6. If Apple Intelligence is unavailable (pre-iOS 26, unsupported device, or not enabled in iOS Settings > Apple Intelligence & Siri), the AI screen shows an "Apple Intelligence Required" guidance state (NOT an error — this is the feature working as designed)

---

## 5. External Services, Tools & Platforms

| Service | Purpose | User-Facing? | Data Sent |
|---|---|---|---|
| **Apple StoreKit 2** | In-App Purchases (Pro Unlock $4.99, AI Add-on $5.99) | Yes (purchase flow) | Purchase transactions handled by Apple |
| **Apple Intelligence** (FoundationModels framework, iOS 26+) | AI gift suggestions (on-device) | Yes (3 free/month, unlimited with AI Add-on) | **None** — runs entirely on-device. No data leaves the device. |
| **Cloudflare Workers** (feedback-board.iocompile67692.workers.dev) | In-app "Contact Support" feedback form | Yes (optional) | User-submitted subject, message, and basic app diagnostics (version, iOS, device model) — only when user actively submits. **No contact data.** |
| **SwiftData** (Apple framework) | Local on-device data storage | No (local) | All user data stays on device |
| **Apple UserNotifications** | Local birthday reminders | No (system) | Notification scheduling (local, no server) |
| **Apple Contacts** (CNContactStore) | One-tap birthday import | Yes (permission prompt) | Reads ONLY name, birthday, photo (privacy-minimized — no phone/email/address). Data stays local; never uploaded or shared. |

**Third-party SDKs**: NONE. The app contains no analytics SDKs, no advertising SDKs, no tracking SDKs, and no crash-reporting SDKs. All frameworks used are Apple-native (SwiftUI, SwiftData, StoreKit, UserNotifications, Contacts, FoundationModels, WidgetKit-ready).

**No intermediary server for AI**: AI suggestions run entirely on-device via Apple Intelligence. Giftly does not operate a proxy or backend for AI calls.

**Contacts are never uploaded or shared**: Contact data is read locally via `CNContactStore`, stored in the on-device SwiftData database, and never transmitted over any network call.

---

## 6. Regional Differences

**The app functions consistently across all regions.** There are no region-specific features, content restrictions, or behavior differences.

Specifically:
- All app content (UI text, descriptions) is in English and identical worldwide
- Both In-App Purchases are available in all App Store regions (prices adjust to local currency via Apple's price tiers)
- The AI feature uses Apple Intelligence on-device; no third-party AI provider is referenced or required
- No content is geo-restricted
- The app does not reference, promote, or bundle any specific AI provider, brand, or retailer in the user-facing UI or metadata
- Privacy Policy, Terms of Use, and Support Page are accessible globally via GitHub Pages

---

## 7. Regulated Industry / Protected Material

**Not applicable.** Giftly does not operate in a regulated industry and does not include protected third-party material.

- The app is a personal productivity/lifestyle tool (birthday reminders and gift planning)
- No medical, financial, legal, or gambling functionality
- No third-party copyrighted content (all UI, icons, and text are original or Apple system-provided)
- AI gift suggestions are generated on-device by Apple Intelligence — Giftly does not provide, curate, or transmit AI content
- No licenses or credentials are required to operate this app

---

## IAP Compliance (Guideline 3.1.2)

Giftly uses **one-time non-consumable purchases only** — there are NO auto-renewable subscriptions, NO trials, and NO recurring billing.

| Product ID | Type | Price | Display Name |
|---|---|---|---|
| com.zzoutuo.Giftly.prounlock | Non-Consumable | $4.99 | Giftly Pro |
| com.zzoutuo.Giftly.aiunlock | Non-Consumable | $5.99 | AI Add-on |

- The Paywall clearly displays each product's **title, price, and description**
- Links to **Terms of Use** and **Privacy Policy** are visible in the Paywall (below purchase buttons) and in Settings → Legal
- **"Restore Purchases"** button is available in both the Paywall and Settings
- Purchase status is reactive — features unlock immediately after purchase using `Transaction.currentEntitlement(for:)`
- A StoreKit Configuration file (`Giftly.storekit`) is included in the project for local/simulator IAP testing (Edit Scheme → Run → Options → StoreKit Configuration)

---

## Purpose Strings (Guideline 5.1.1)

Each permission request includes a clear, specific purpose string:

| Permission | Purpose String | Why It's Needed |
|---|---|---|
| **Contacts** (NSContactsUsageDescription) | "Giftly needs access to your contacts to import birthdays. We only read names, birthdays, and photos — never phone numbers, emails, or addresses." | One-tap birthday import. Privacy-minimized: reads only name, birthday, photo. |
| **Notifications** (runtime prompt) | Onboarding explains: "Get notified 7 days, 1 day, and on the day of every birthday." | Local birthday reminders (no push server). |

**No other permissions are requested**: No camera, no photo library (uses PhotosPicker which requires no permission), no location, no microphone, no App Tracking Transparency (app does not track), no HealthKit, no Bluetooth.

---

## Privacy

- **All user data is stored locally on-device** using SwiftData (no cloud, no server, no account)
- **No analytics, no advertising, no tracking** — zero third-party data-collecting SDKs
- **AI suggestions** run on-device via Apple Intelligence — no network call is made and no data leaves the device
- **Contacts import** reads only name, birthday, photo (privacy-minimized — no phone/email/address)
- **PrivacyInfo.xcprivacy** included in the app bundle declaring UserDefaults and FileTimestamp API usage
- Policy pages: Privacy Policy, Terms of Use, Support Page — all deployed and accessible in-app

| Page | URL |
|---|---|
| Privacy Policy | https://asunnyboy861.github.io/Giftly/privacy.html |
| Terms of Use | https://asunnyboy861.github.io/Giftly/terms.html |
| Support Page | https://asunnyboy861.github.io/Giftly/support.html |

---

## Contact

If you have any questions during review, please contact: **iocompile67692@gmail.com**

AI feature testing requires an iOS 26+ device or simulator with Apple Intelligence enabled. If Apple Intelligence is unavailable, the AI screen shows a clear guidance state (not an error) and all other features are fully functional.
