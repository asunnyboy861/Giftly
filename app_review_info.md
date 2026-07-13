# Giftly — App Review Information (Reply to Review Team)

> Paste the content of the "Review Notes (Reply)" section below into the App Review Information → Notes field in App Store Connect. This document directly answers the 7 items requested in the review feedback, plus the two contacts-privacy questions raised in the July 13, 2026 review (Guideline 2.1).

---

## App Overview

- **App Name**: Giftly
- **Bundle ID**: com.zzoutuo.Giftly
- **Version**: 1.0 (Build 4)
- **Category**: Lifestyle / Productivity
- **Pricing**: Free with In-App Purchases (one-time, non-consumable — NO subscriptions)
- **Demo Account**: Not required. Giftly is fully offline and accountless. All features are accessible immediately after download.

---

## Response to Guideline 2.1 (July 13, 2026) — Contacts Privacy Questions

The review team asked two specific questions. Direct answers and technical evidence follow.

### Q1: Do you upload the user's contacts to the server?

**No.** Giftly does **NOT** upload user contacts to any server.

**Technical evidence:**
- Contacts are read locally on the device using Apple's `CNContactStore` framework (in `Giftly/Services/ContactImportService.swift`).
- The fetch request only requests these keys: `CNContactGivenNameKey`, `CNContactFamilyNameKey`, `CNContactBirthdayKey`, `CNContactImageDataKey`, `CNContactThumbnailImageDataKey`. It does **not** request phone numbers, email addresses, postal addresses, or any other fields.
- The imported data (name, birthday, photo) is written into the app's local on-device SwiftData database. No `URLSession`, `URL(string:)`, or any network API is called in `ContactImportService.swift`.
- A full codebase audit confirms there is no network call anywhere in the app that transmits contact data. The only two network calls in the entire app are:
  1. Optional AI gift suggestions (sends only the person's name, age, relationship, interests, and budget range — never the full contact record, never the contacts list)
  2. Optional "Contact Support" form (sends only user-typed subject/message + app version/iOS/device diagnostics — never contact data)
- `PrivacyInfo.xcprivacy` declares `NSPrivacyTracking: false` and an empty `NSPrivacyCollectedDataTypes` array.

### Q2: Do you share the user's contacts to any third-party?

**No.** Giftly does **NOT** share user contacts with any third-party.

**Technical evidence:**
- The app contains **zero third-party SDKs** — no analytics, no advertising, no tracking, no crash-reporting SDKs (no Firebase, no Google Analytics, no Mixpanel, no AdMob, no Facebook SDK).
- There is no data broker, no advertising network, and no third-party API that receives contact information.
- The AI suggestion feature (when the optional BYO Key path is used) sends only a minimal prompt containing the person's name, age, relationship, interests, and a budget range — directly from the device to the user's own chosen AI provider. The full contact record, the contacts list, and any other person's data are never sent.
- The default AI provider (iOS 26+) is Apple Intelligence, which runs **on-device** via the FoundationModels framework — no data leaves the device at all.
- The "Contact Support" form posts only the user-typed message and basic app diagnostics to a Cloudflare Worker endpoint (`feedback-board.iocompile67692.workers.dev`). No contact data is included in that payload.
- `PrivacyInfo.xcprivacy` declares `NSPrivacyTrackingDomains: []` (empty).

**Files referenced for verification:**
- `Giftly/Services/ContactImportService.swift` — local-only contact read
- `Giftly/Views/ContactSupportView.swift` — support form payload (no contact data)
- `Giftly/Services/AppleIntelligenceService.swift` — on-device AI (iOS 26+)
- `Giftly/Services/GiftAIService.swift` — BYO Key AI (minimal prompt only)
- `Giftly/PrivacyInfo.xcprivacy` — privacy manifest
- Updated Privacy Policy: https://asunnyboy861.github.io/Giftly/privacy.html (see "Contacts Privacy — Direct Answers" section)

---

## 1. Screen Recording (Physical Device)

A screen recording has been captured on a physical iPhone running the latest iOS and is attached to this submission. The recording demonstrates the full typical user flow:

1. **Launch** the app from the Home screen (cold start)
2. **Onboarding** — 3-page welcome → notification permission prompt (tap Allow)
3. **Add a birthday manually** — tap "+" → fill name, birthday, photo, relationship → Save (confetti animation)
4. **Contact import** — tap the contacts icon → Contacts permission prompt (tap Allow) → birthdays imported
5. **Birthday cards** — today's birthday (pink border) + upcoming birthdays with countdown
6. **Person detail** — tap a card → age, zodiac, gift ideas, gift history
7. **Gift idea tracking** — add a gift idea → advance status Idea → Planned → Purchased → Given
8. **Calendar tab** — all birthdays grouped by month
9. **Settings tab → Upgrade** — Paywall showing both IAP products with prices, Privacy Policy & Terms of Use links
10. **IAP purchase flow** — tap a purchase button → Apple purchase sheet (Sandbox)
11. **AI suggestions** (optional) — Settings → enter API key → person detail → AI Ideas → Generate

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

Testing covered: app launch, onboarding, manual person entry, contact import, birthday notifications scheduling, gift idea CRUD + status transitions, gift history, calendar view, search, favorites, data export/import, both IAP products (StoreKit Configuration file), restore purchases, AI flow with API key, and dark mode.

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
1. Launch Giftly — onboarding appears on first launch (3 welcome pages + notification permission request)
2. Tap **"+"** (top-right) to add a person manually: enter name, birthday, optional photo/relationship/interests/notes → Save
3. Tap the **contacts icon** (top-left) to import birthdays from Contacts (permission required — app reads ONLY name, birthday, photo; never phone/email/address)
4. Tap any birthday card to open **Person Detail** — see age, zodiac, gift ideas, gift history
5. Tap **"View List"** on a person to add gift ideas and advance their status (Idea → Planned → Purchased → Given)
6. Switch to the **Calendar** tab to see all birthdays by month
7. Switch to the **Settings** tab to configure AI, export/import data, view legal pages, or upgrade

**Login credentials**: None required (no account system).

**Sample files**: None required. Users add their own birthdays manually or import from Contacts.

**AI feature testing** (two paths):

*Path A — Apple Intelligence (default, on-device, iOS 26+)*
1. On an iOS 26+ device with Apple Intelligence enabled, open any person → "AI Ideas"
2. The default provider is Apple Intelligence — 3 free suggestions per month, no API key needed
3. Set a budget range → "Generate Ideas" — suggestions appear on-device, no data leaves the device
4. After 3 free uses, the button shows the Paywall (not an error)
5. Purchase "AI Add-on" ($5.99) for unlimited on-device suggestions

*Path B — Bring Your Own Key (optional, advanced)*
1. Settings → Purchases → "Upgrade to Giftly Pro" or purchase "AI Add-on" ($5.99)
2. Settings → Advanced — BYO Key → enter any ChatCompletions-compatible API key → Save (stored in Keychain)
3. Open any person → "AI Ideas" → set budget → "Generate Ideas"
4. If no API key is set and Apple Intelligence is unavailable, the AI screen shows guidance (NOT an error)
5. If AI Add-on is not purchased and the free tier is exhausted, the "AI Ideas" button shows the Paywall (NOT an error)

---

## 5. External Services, Tools & Platforms

| Service | Purpose | User-Facing? | Data Sent |
|---|---|---|---|
| **Apple StoreKit 2** | In-App Purchases (Pro Unlock $4.99, AI Add-on $5.99) | Yes (purchase flow) | Purchase transactions handled by Apple |
| **Apple Intelligence** (FoundationModels framework, iOS 26+) | Default AI gift suggestions (on-device) | Yes (3 free/month, unlimited with AI Add-on) | **None** — runs entirely on-device. No data leaves the device. |
| **OpenAI-compatible ChatCompletions API** (user-configured, optional advanced) | AI gift suggestions via BYO key | Yes (optional) | Minimal prompt only (person's name, age, relationship, interests, budget range) sent directly from device to user's chosen API endpoint. Never the full contact record or contacts list. API key stored in iOS Keychain, never transmitted to Giftly's servers. |
| **Cloudflare Workers** (feedback-board.iocompile67692.workers.dev) | In-app "Contact Support" feedback form | Yes (optional) | User-submitted subject, message, and basic app diagnostics (version, iOS, device model) — only when user actively submits. **No contact data.** |
| **SwiftData** (Apple framework) | Local on-device data storage | No (local) | All user data stays on device |
| **Apple UserNotifications** | Local birthday reminders | No (system) | Notification scheduling (local, no server) |
| **Apple Contacts** (CNContactStore) | One-tap birthday import | Yes (permission prompt) | Reads ONLY name, birthday, photo (privacy-minimized — no phone/email/address). Data stays local; never uploaded or shared. |

**Third-party SDKs**: NONE. The app contains no analytics SDKs, no advertising SDKs, no tracking SDKs, and no crash-reporting SDKs. All frameworks used are Apple-native (SwiftUI, SwiftData, StoreKit, UserNotifications, Contacts, FoundationModels, WidgetKit-ready).

**No intermediary server for AI**: AI requests go directly from the user's device to their chosen API provider (BYO Key path), or run entirely on-device (Apple Intelligence path). Giftly does not operate a proxy or backend for AI calls.

**Contacts are never uploaded or shared**: Contact data is read locally via `CNContactStore`, stored in the on-device SwiftData database, and never transmitted over any network call.

---

## 6. Regional Differences

**The app functions consistently across all regions.** There are no region-specific features, content restrictions, or behavior differences.

Specifically:
- All app content (UI text, descriptions) is in English and identical worldwide
- Both In-App Purchases are available in all App Store regions (prices adjust to local currency via Apple's price tiers)
- The AI feature uses a "Bring Your Own Key" model — users in any region can configure their own API provider and endpoint, so no region is blocked or favored
- No content is geo-restricted
- The app does not reference, promote, or bundle any specific AI provider (e.g., ChatGPT/OpenAI) or any specific retailer (e.g., Amazon) in the user-facing UI or metadata, making it safe for distribution in all regions including China
- Privacy Policy, Terms of Use, and Support Page are accessible globally via GitHub Pages

---

## 7. Regulated Industry / Protected Material

**Not applicable.** Giftly does not operate in a regulated industry and does not include protected third-party material.

- The app is a personal productivity/lifestyle tool (birthday reminders and gift planning)
- No medical, financial, legal, or gambling functionality
- No third-party copyrighted content (all UI, icons, and text are original or Apple system-provided)
- AI gift suggestions are generated by the user's own API key and are the user's own output — Giftly does not provide or curate AI content
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
- **API key** stored in iOS Keychain (`kSecAttrAccessibleWhenUnlocked`), never leaves the device
- **AI requests** go directly from device to user's chosen API provider (no intermediary server)
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

We are happy to provide a demo API key for AI feature testing upon request. Without an API key, the AI screen shows a clear guidance prompt (not an error) and all other features are fully functional.
