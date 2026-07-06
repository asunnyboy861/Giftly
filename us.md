# Giftly: Birthday & Gift Reminder — iOS Development Guide

## Executive Summary

**Giftly** is a privacy-first birthday and gift reminder app targeting the US market. The product vision is built on a "zero-friction, instant-value, continuous-delight" design philosophy: users can set up birthday reminders in under 30 seconds, all data is stored locally (no cloud, no account), and the app monetizes through one-time purchases — directly attacking the subscription fatigue that dominates this category.

**Key Differentiators**:
1. **Anti-subscription positioning**: One-time $4.99 unlocks unlimited contacts forever — competitors charge $3–30/year.
2. **Privacy-first**: All data local (SwiftData), contacts import reads only name/birthday/photo (no phone/email/address).
3. **AI gift suggestions via BYO API Key**: Zero server cost, user controls their own OpenAI key (stored in Keychain).
4. **Gift history tracking**: Prevents duplicate gifting — no competitor does this well.
5. **Brandable name**: "Giftly" — 2 syllables, verb-izable ("Just Giftly it"), strong recall.

**Target Audience**: Family users (35%), social-active users (25%), professionals (20%), privacy-sensitive users (15%), anti-subscription users (5%). Estimated US market: ~50M active users with birthday-reminder needs.

**App Store Category**: Lifestyle (or Productivity)

---

## Competitive Analysis

| App | Strengths | Weaknesses | Our Advantage |
|-----|-----------|------------|---------------|
| **Birthday Reminder: Countdowns** (Damien Asseya) | Local-first, contact import, gift ideas tracking, 5-free-tier one-time purchase model | No AI suggestions, no gift history, smaller feature set | We add AI gift ideas + gift history + richer card UI |
| **Gifties – Birthday Reminder** (Joshua Kranefeld) | AI gift ideas, wishlists, lock-screen widget, multi-language | Likely subscription/ads, less privacy-focused, no gift history | One-time pricing, gift history tracking, stricter privacy |
| **Birthdays: Cards & Reminders** (LEAN ASIA) | 20+ greeting cards, relationship organization, countdown timer | Subscription-only premium, generic | No subscription, gift history, AI suggestions, no ads |
| **Facebook Birthday** | Free, network effect | Requires FB account, privacy concerns | No social account needed, privacy-first |
| **Google Calendar** | Free, sync everywhere | Generic — birthdays clutter calendar | Birthday-focused card UI, gift tracking |
| **birthdays.app** | Established | SMS-only reminders, no full app | Full app experience, richer features |

**Core Competitive Weapon**: One-time $4.99 forever vs. competitors' $3–30/year subscriptions.

---

## Feature Inventory (MANDATORY — Every Feature From Guide)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | Onboarding Welcome | 1. App first launch → 2. Show welcome screen with logo/slogan → 3. Auto-dismiss after 3 sec → 4. Show permission request | None | Check if any Person exists in SwiftData; if empty → trigger onboarding | Welcome screen + permission gate | UserDefaults flag `hasCompletedOnboarding` | Onboarding appears only on first launch; disappears automatically |
| 2 | Notification Permission Request | 1. User taps "Allow Notifications" → 2. System permission dialog → 3. User grants → 4. Register notification categories | Tap action | `UNUserNotificationCenter.requestAuthorization([.alert,.sound,.badge])`; register `BIRTHDAY_REMINDER` category with Call/Message/GiftIdeas actions | Permission granted state | UserDefaults `notificationsEnabled` | Notification permission requested once; categories registered for actionable notifications |
| 3 | Contact Import (one-tap) | 1. User taps "Import from Contacts" → 2. System permission dialog → 3. User grants → 4. Show "Found X birthdays!" with list → 5. User taps "Start Using Giftly" | Tap action; system permission grant | `CNContactStore.requestAccess(.contacts)`; enumerate contacts with givenName/familyName/birthday/imageData ONLY (privacy minimization — no phone/email/address); filter contacts without birthday; dedup against existing Person records; bulk insert to SwiftData; schedule notifications for each | List of discovered birthdays; count "Found X birthdays!" | SwiftData `Person` entities; notification requests scheduled | Only contacts with birthday imported; existing contacts not duplicated; notifications scheduled |
| 4 | Manual Birthday Entry | 1. User taps "+" → 2. Fill form (name, birthday date picker, photo optional, relationship optional, interests optional, notes optional) → 3. Tap Save → 4. Confetti animation → 5. Card appears in list | Name (text), Birthday (DatePicker), Photo (PhotosPicker optional), Relationship (text optional), Interests (text array optional), Notes (text optional) | Validate name non-empty; validate birthday not null; create Person SwiftData entity; schedule notifications; refresh list | New birthday card in sorted list | SwiftData `Person` entity | Person appears in list sorted by next birthday; notifications scheduled; pro-limit enforced (5 free) |
| 5 | Birthday Card List (Today + Upcoming) | 1. User opens app → 2. See "Today's Birthdays" section (if any) → 3. See "Coming Up" section (next 30 days) → 4. Swipe/tap cards | App open | Query SwiftData sorted by birthday; filter `isBirthdayToday`; filter `daysUntilBirthday <= 30` excluding today; compute countdown | Card UI with avatar, name, days-until, age, quick actions | Read-only query of `Person` entities | Today's birthdays highlighted with pink border; upcoming sorted ascending by days; empty state shown when no birthdays |
| 6 | Calendar View | 1. User taps Calendar tab → 2. See month grid with birthday markers → 3. Tap a day → 4. See that day's birthdays | Tab tap; day tap | Build month grid; mark days where any Person.birthday month/day matches | Calendar grid with birthday indicators; day detail sheet | Read-only query of `Person` entities | All birthdays marked on calendar; tap day shows birthdays on that day |
| 7 | Person Detail View | 1. User taps a card → 2. See person detail (photo, name, birthday, age, relationship, interests, notes) → 3. See gift ideas list → 4. See gift history list → 5. Edit/delete actions | Card tap | Query Person + related GiftIdea[] + GiftHistory[] | Detail screen with sections | Read-only query | All person info displayed; gift ideas/history visible; edit/delete work |
| 8 | Gift Idea Recording | 1. User taps "Add Gift Idea" on person detail → 2. Enter title, description optional, estimated price optional → 3. Save → 4. Confetti animation → 5. Appears in gift ideas list | Title (text), Description (text optional), Estimated Price (number optional) | Create GiftIdea SwiftData entity with status=.idea; link to Person; refresh list | New gift idea card in list | SwiftData `GiftIdea` entity (status: idea/planned/purchased/given) | Gift idea saved and displayed; status transitions work (idea→planned→purchased→given) |
| 9 | Gift Status Tracking | 1. User taps gift idea → 2. Change status (Idea → Planned → Purchased → Given) → 3. When "Given": auto-create GiftHistory entry | Status selection | Update GiftIdea.status; if .given → create GiftHistory entity with description and dateGiven=now | Updated status badge; gift history updated | SwiftData `GiftIdea.status` + new `GiftHistory` entity | Status changes persist; "Given" creates history entry automatically |
| 10 | Gift History Tracking | 1. User opens person detail → 2. See "Gift History" section → 3. View past gifts with dates → 4. Prevents duplicate gifting | View action | Query GiftHistory sorted by dateGiven descending | List of past gifts with description + date | SwiftData `GiftHistory` entities | All given gifts appear; sorted newest first; visible at-a-glance before buying new gift |
| 11 | Notification Scheduling (3-tier) | 1. Person added/updated → 2. System schedules 3 notifications per person (7-day, 1-day, day-of) → 3. Yearly repeat | Automatic on Person create/update | Compute nextBirthday; for each reminderDays=[7,1,0]: create UNCalendarNotificationTrigger with yearly repeat at 9:00 AM; set categoryIdentifier="BIRTHDAY_REMINDER"; build body with name/age | 3 pending notification requests per person | UNUserNotificationCenter pending requests | 3 notifications scheduled per person; yearly repeat; correct date/time; bodies include name + age |
| 12 | Notification Quick Actions | 1. User receives notification → 2. Sees Call/Message/GiftIdeas buttons → 3. Taps action → 4. System performs action without opening app (Call/Message) or opens person detail (GiftIdeas) | Notification action tap | UNNotificationCategory with CALL_ACTION, MESSAGE_ACTION, GIFT_ACTION; handle in UNUserNotificationCenterDelegate | Phone call / Messages app / Person detail deep link | None (action handler) | Notification shows 3 action buttons; Call/Message work from notification; GiftIdeas deep-links to person |
| 13 | AI Gift Suggestions (BYO API Key) | 1. User taps "Need gift ideas?" on person card → 2. If no API key: prompt to enter key (stored in Keychain) → 3. Fill form (age auto, relationship auto, interests manual, budget slider) → 4. Tap Generate → 5. See 5 AI suggestions as swipeable cards → 6. Save desired ones to GiftIdeas | API Key (text, Keychain), Interests (text), Budget (slider $0–$500) | Build prompt with person info + budget; call OpenAI ChatCompletions (gpt-4o-mini, temp 0.8); parse JSON array of {title, reason, priceRange, searchTerms}; display as cards | 5 AI suggestion cards; "Search on Amazon" + "Save to Gift Ideas" buttons | Keychain `openai_api_key`; saved suggestions → SwiftData `GiftIdea` | 5 suggestions returned; valid JSON parsed; save creates GiftIdea; search opens Amazon with searchTerms |
| 14 | One-time IAP: Pro Unlock ($4.99) | 1. User tries to add 6th contact OR taps Unlock in Settings → 2. Show paywall with feature list + price → 3. User taps "Unlock for $4.99" → 4. Apple purchase flow → 5. Pro features unlocked | Purchase confirmation | StoreKit 2 `Product.purchase()`; verify Transaction; set `isProUnlocked=true`; finish transaction | Paywall dismissed; pro features available | StoreKit transaction; UserDefaults/Keychain `isProUnlocked` flag | Purchase completes; unlimited contacts; contact import unlocked; custom reminders; widgets; gift ideas; data export |
| 15 | One-time IAP: AI Advanced ($5.99) | 1. User taps "Unlock AI" in Settings or on AI prompt → 2. Show AI paywall → 3. User taps "Unlock for $5.99" → 4. Apple purchase flow → 5. AI features unlocked | Purchase confirmation | StoreKit 2 purchase; verify; set `isAIUnlocked=true`; finish | AI paywall dismissed; AI features available | StoreKit transaction; `isAIUnlocked` flag | Purchase completes; AI gift suggestions available; gift history; budget management |
| 16 | Free Version Limit (5 contacts) | 1. User adds contacts → 2. After 5th contact, next "Add" shows paywall → 3. User can continue using free features with 5 contacts | Add 6th contact attempt | Check `people.count >= 5 && !isProUnlocked` → present paywall | Paywall presented | None | Free users capped at 5 contacts; paywall on 6th attempt; existing 5 contacts retained |
| 17 | Home Screen Widget | 1. User long-presses home screen → 2. Adds Giftly widget → 3. Widget shows next upcoming birthday (name, days-until, age) | Widget configuration | WidgetKit TimelineProvider; query SwiftData for nearest upcoming birthday; refresh daily | Widget displaying next birthday info | App Group shared SwiftData container | Widget shows correct next birthday; updates daily; tap opens app |
| 18 | Settings View | 1. User taps Settings tab → 2. See: notification toggle, reminder time picker, default reminder days, theme, restore purchases, unlock pro, unlock AI, API key management, privacy policy, terms, support, about | Tab tap; various toggles | Load/save UserDefaults; toggle notification scheduling; manage Keychain API key; restore StoreKit transactions | Settings screen with all options | UserDefaults + Keychain + StoreKit | All settings persist; notification toggle reschedules; restore works; legal links open |
| 19 | Restore Purchases | 1. User taps "Restore Purchases" in Settings → 2. App syncs with App Store → 3. Previously purchased items restored | Tap action | `AppStore.sync()`; iterate `Transaction.currentEntitlements`; set flags | Toast: "Purchases restored" or "No purchases found" | StoreKit Transaction state | Pro/AI flags correctly set after restore; works across devices |
| 20 | Data Export | 1. User taps "Export Data" in Settings → 2. App generates JSON of all Person + GiftIdea + GiftHistory → 3. Share sheet opens → 4. User saves/shares file | Tap action | Serialize SwiftData to JSON; present UIActivityViewController | JSON file shared | None (export file) | Export file contains all data; valid JSON; share sheet works |
| 21 | Data Import | 1. User taps "Import Data" in Settings → 2. Select JSON file → 3. App parses and imports → 4. Dedup against existing | File selection | Parse JSON; validate schema; create Person/GiftIdea/GiftHistory; dedup by name+birthday | Toast: "Imported X contacts" | SwiftData entities | Imported data appears in list; no duplicates; notifications scheduled |
| 22 | Dark Mode | 1. User changes system to Dark Mode → 2. App adapts: true black background, system-standard dark card colors, brighter gradients | System setting | SwiftUI `.preferredColorScheme` or asset catalog dark variants | Dark-themed UI | None (system-driven) | All screens adapt to dark mode; gradients visible; text readable |
| 23 | Confetti Animation (delight) | 1. User marks gift as "Given" or completes onboarding or saves gift idea → 2. Confetti burst animation plays → 3. Haptic feedback (success) | Action completion | SwiftUI confetti view; UIImpactFeedbackGenerator(.success) | Animated confetti overlay | None | Confetti plays on key delight moments; respects Reduce Motion setting |

### Sub-Features & Detail Interactions

| # | Parent Feature | Sub-Feature | Detail Description | Interaction Pattern |
|---|---------------|-------------|-------------------|--------------------|
| 1.1 | Onboarding | Auto-dismiss timer | Welcome screen disappears after 3 seconds automatically | Timer-driven; no tap required |
| 1.2 | Onboarding | Skip button | User can tap to skip welcome screen | Tap |
| 2.1 | Notification Permission | Graceful denial | If denied, app continues; in-app badge reminders shown instead | System dialog |
| 3.1 | Contact Import | Progress indicator | Show spinner during contact enumeration | ActivityIndicator |
| 3.2 | Contact Import | "Found X birthdays!" magic moment | Celebratory message with count | Auto-display |
| 3.3 | Contact Import | Deduplication | Skip contacts already in SwiftData (match by name lowercase) | Automatic |
| 4.1 | Manual Entry | PhotosPicker | User can pick photo from Photos library | PhotosPicker SwiftUI |
| 4.2 | Manual Entry | Relationship field | Free text or picker (Family/Friend/Colleague/Partner/Other) | TextField/Picker |
| 5.1 | Birthday Card | Today's pink border | Birthday-today cards have pink border + slight pulse | Visual |
| 5.2 | Birthday Card | Countdown text | "In X days · Turning Y" format | Text rendering |
| 5.3 | Birthday Card | Quick action buttons | Today's cards show Call/Message/GiftIdeas; upcoming show GiftIdeas only | Button taps |
| 5.4 | Birthday Card | Swipe gestures | Right swipe = mark "gift prepared"; left swipe = add gift idea | Swipe |
| 5.5 | Birthday Card | Haptic feedback | Light haptic on tap; medium haptic on long-press | UIImpactFeedbackGenerator |
| 7.1 | Person Detail | Edit person | Edit all fields; re-schedule notifications on birthday change | Tap edit button |
| 7.2 | Person Detail | Delete person | Delete with confirmation; cascade delete GiftIdea + GiftHistory; cancel notifications | Tap delete + confirm |
| 7.3 | Person Detail | Favorite toggle | Star/unstar person; favorites appear at top | Tap star icon |
| 8.1 | Gift Idea | Edit gift idea | Edit title/description/price | Tap to edit |
| 8.2 | Gift Idea | Delete gift idea | Delete with swipe | Swipe |
| 11.1 | Notification | Custom reminder time | User can change default 9:00 AM reminder time in Settings | Settings picker |
| 11.2 | Notification | Custom reminder days | User can change [7,1,0] to custom set (e.g., [14,7,1,0]) | Settings toggles |
| 11.3 | Notification | 64-limit handling | If pending notifications > 64, remove oldest before adding new | Automatic |
| 13.1 | AI Suggestions | Budget slider | Slider $0–$500, range selection (min–max) | Slider |
| 13.2 | AI Suggestions | Search on Amazon | Opens Amazon search with searchTerms via URL | Tap button → URL open |
| 13.3 | AI Suggestions | Save to Gift Ideas | Creates GiftIdea from AI suggestion | Tap button |
| 13.4 | AI Suggestions | API Key management | Settings: enter/edit/clear API key; stored in Keychain; "Key never leaves device" privacy note | Settings form |
| 18.1 | Settings | App version display | Read version dynamically from Bundle.main (no hardcoded version) | Static text |

### Cross-Feature Dependencies

| Dependency | Source Feature | Target Feature | Data Passed | Trigger Condition |
|------------|---------------|----------------|-------------|-------------------|
| Contact Import → Card List | Contact Import (#3) | Birthday Card List (#5) | New Person entities | Import completes |
| Manual Entry → Card List | Manual Birthday Entry (#4) | Birthday Card List (#5) | New Person entity | Save tapped |
| Person CRUD → Notifications | Any Person create/update/delete (#3,4,7) | Notification Scheduling (#11) | Person.birthday, Person.id, Person.name | Person saved |
| Gift Idea → Gift History | Gift Status Tracking (#9) | Gift History Tracking (#10) | GiftIdea.title, Person | Status set to .given |
| AI Suggestions → Gift Ideas | AI Gift Suggestions (#13) | Gift Idea Recording (#8) | GiftSuggestion.title/reason/priceRange | User taps "Save to Gift Ideas" |
| IAP Pro → Contact Import | One-time IAP Pro (#14) | Contact Import (#3) | isProUnlocked flag | Pro unlocked |
| IAP Pro → Manual Entry limit | One-time IAP Pro (#14) | Free Version Limit (#16) | isProUnlocked flag | Pro unlocked removes 5-cap |
| IAP AI → AI Suggestions | One-time IAP AI (#15) | AI Gift Suggestions (#13) | isAIUnlocked flag | AI unlocked |
| Person data → Widget | Person CRUD | Home Screen Widget (#17) | Nearest upcoming birthday | Widget refresh |
| Settings reminder time → Notifications | Settings (#18) | Notification Scheduling (#11) | Reminder hour/minute | Setting changed |

---

## Apple Design Guidelines Compliance

- **HIG — Contacts**: App requests contacts access with clear `NSContactsUsageDescription`. Reads only name/birthday/photo (privacy minimization). No phone/email/address read.
- **HIG — Notifications**: Actionable notifications with Call/Message/GiftIdeas actions. User can disable in Settings. No spammy notifications.
- **HIG — Privacy Manifest (2026)**: App includes `PrivacyInfo.xcprivacy` declaring SwiftData (file timestamp), Contacts (contact info), UserNotifications (no PII), StoreKit (purchase history). No third-party SDKs that collect data.
- **HIG — App Tracking Transparency**: App does NOT track users. No ATT prompt needed. No analytics SDK. No advertising SDK.
- **App Store Guideline 2.1 (App Completeness)**: All features fully functional; no placeholder content; no dead AI buttons leading to errors when no API key (graceful onboarding prompt instead).
- **App Store Guideline 3.1.2 (Business)**: One-time purchases (not subscription) — simpler compliance. Paywall shows price, feature list, and "No subscriptions, ever" tagline. Restore Purchases available.
- **App Store Guideline 5.1 (Privacy)**: Privacy Policy deployed to GitHub Pages. All data local; no server. Privacy policy clearly states no cloud, no account, no tracking.
- **HIG — Dark Mode**: Native SwiftUI dark mode support via asset catalog.
- **HIG — Dynamic Type**: All text uses `.font(.system())` supporting Dynamic Type.
- **HIG — Accessibility**: VoiceOver labels on all interactive elements; respects Reduce Motion (disables confetti); respects Reduce Haptics (disables haptic feedback).

---

## Technical Architecture

- **Language**: Swift 5.9+
- **Framework**: SwiftUI (primary); UIKit only if needed (Contacts enumeration uses CNContactStore)
- **Architecture**: MVVM with `@Observable` ViewModels (iOS 17+)
- **Data**: SwiftData (`@Model` for Person, GiftIdea, GiftHistory) — local only, no CloudKit
- **Notifications**: `UserNotifications` framework with `UNCalendarNotificationTrigger` (yearly repeat)
- **Contacts**: `Contacts` framework (`CNContactStore`) — read-only, minimal keys
- **In-App Purchase**: StoreKit 2 (`Product`, `Transaction`, `VerificationResult`)
- **Widget**: WidgetKit with TimelineProvider reading App Group shared SwiftData container
- **AI**: OpenAI ChatCompletions API via URLSession (BYO API Key stored in Keychain)
- **Haptics**: `UIImpactFeedbackGenerator` / `UINotificationFeedbackGenerator`
- **Min iOS**: 17.0 (required for SwiftData + `@Observable`)

---

## Module Structure

```
Giftly/
├── GiftlyApp.swift                  # App entry, SwiftData container, onboarding gate
├── Models/
│   ├── Person.swift                 # @Model — name, birthday, photoData, relationship, interests, notes, isFavorite
│   ├── GiftIdea.swift                # @Model — title, description, price, status, searchTerms
│   ├── GiftHistory.swift             # @Model — description, occasion, dateGiven
│   └── GiftStatus.swift             # enum: idea, planned, purchased, given
├── ViewModels/
│   ├── PersonViewModel.swift        # @Observable — CRUD persons, contact import, dedup
│   ├── GiftViewModel.swift          # @Observable — gift idea CRUD, status transitions, history
│   ├── NotificationManager.swift    # @Observable — schedule/cancel notifications, categories
│   ├── PurchaseManager.swift        # @Observable — StoreKit 2, isProUnlocked, isAIUnlocked
│   └── AIViewModel.swift            # @Observable — API key management, AI request/response
├── Views/
│   ├── ContentView.swift            # TabView: Today / Calendar / Settings
│   ├── OnboardingView.swift        # Welcome + permission requests
│   ├── BirthdayCardView.swift       # Today + Upcoming sections
│   ├── BirthdayCard.swift           # Single card component
│   ├── CalendarView.swift           # Month grid with birthday markers
│   ├── PersonDetailView.swift       # Person detail + gift ideas + gift history
│   ├── AddPersonView.swift          # Manual entry form
│   ├── GiftIdeaListView.swift       # Gift ideas per person
│   ├── GiftSuggestionView.swift     # AI suggestions swipeable cards
│   ├── PaywallView.swift            # Pro unlock paywall
│   ├── AISettingsView.swift         # API key management
│   └── SettingsView.swift           # Settings + legal links
├── Services/
│   ├── ContactImportService.swift   # CNContactStore wrapper, minimal keys
│   ├── NotificationService.swift    # UNUserNotificationCenter scheduling
│   ├── GiftAIService.swift          # OpenAI API client
│   ├── PurchaseService.swift        # StoreKit 2 wrapper
│   └── DataExportService.swift      # JSON export/import
├── Widgets/
│   ├── BirthdayWidget.swift         # WidgetKit TimelineProvider
│   └── WidgetModels.swift           # Shared entry model
├── Assets.xcassets/
│   ├── AppIcon.appiconset
│   ├── GiftlyPurple.colorset
│   ├── GiftlyCoral.colorset
│   ├── GiftlyMint.colorset
│   └── ...
└── PrivacyInfo.xcprivacy            # Privacy manifest (2026 requirement)
```

---

## Data Flow Diagram (MANDATORY — Every Feature's Data Lifecycle)

### Feature 3: Contact Import

```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap "Import from Contacts" → System permission grant  │
│       │                                                   │
│  ContactImportService                                     │
│  └── CNContactStore.requestAccess(.contacts)              │
│  └── enumerateContacts(keys: [givenName, familyName,      │
│       birthday, imageData])                              │
│  └── Filter: only contacts with non-nil birthday          │
│  └── Map: CNContact → Person(name, birthday, photoData)   │
│  └── Dedup: skip if name.lowercased() exists in SwiftData │
│       │                                                   │
│  PersonViewModel.bulkInsert(people)                      │
│  └── ModelContext.insert(each) → ModelContext.save()      │
│       │                                                   │
│  NotificationService.scheduleAllReminders(people)        │
│  └── For each Person: schedule 3 triggers (7d, 1d, 0d)    │
│       │                                                   │
│  Display Output                                           │
│  └── "Found X birthdays!" screen with list                │
│  └── BirthdayCardView refreshes with new cards            │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Widget refresh queued; notifications pending          │
└───────────────────────────────────────────────────────────┘
```

### Feature 11: Notification Scheduling

```
┌───────────────────────────────────────────────────────────┐
│  Trigger                                                  │
│  └── Person created / birthday updated / app launch check │
│       │                                                   │
│  NotificationService.scheduleBirthdayReminders(person)   │
│  └── cancelReminders(personId) — remove old 3 requests   │
│  └── Compute person.nextBirthday (Calendar.nextDate)     │
│  └── For daysBefore in [7, 1, 0]:                         │
│       └── triggerDate = nextBirthday - daysBefore days    │
│       └── components = [.month, .day, .hour=9, .minute=0]  │
│       └── UNCalendarNotificationTrigger(repeats: true)    │
│       └── content.title = "🎁 Giftly"                      │
│       └── content.body = dynamic by daysBefore            │
│       └── content.categoryIdentifier = "BIRTHDAY_REMINDER"│
│       └── content.userInfo = [personId, personName, days]  │
│       └── request identifier = "birthday-{id}-{days}"     │
│       └── center.add(request)                             │
│       │                                                   │
│  Persistence                                              │
│  └── UNUserNotificationCenter pending requests (transient)│
│       │                                                   │
│  Display Output                                           │
│  └── Notification fires at scheduled time                │
│  └── User sees notification with Call/Message/GiftIdeas   │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Tap Call → opens tel: (needs phone — not in MVP)    │
│  └── Tap Message → opens sms: (needs phone — not in MVP)  │
│  └── Tap GiftIdeas → deep links to PersonDetailView       │
└───────────────────────────────────────────────────────────┘
```

### Feature 13: AI Gift Suggestions

```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap "Need gift ideas?" on person card                │
│  └── If no API key: enter key → save to Keychain          │
│  └── Fill: interests (text), budget (slider $0–$500)      │
│  └── Tap "Generate"                                       │
│       │                                                   │
│  AIViewModel.generateSuggestions(person, budget)         │
│  └── Read API key from Keychain (kSecAttrAccessibleWhenUnlocked)│
│  └── Build prompt: age, relationship, interests, budget   │
│  └── POST https://api.openai.com/v1/chat/completions      │
│       Authorization: Bearer {userKey}                     │
│       body: { model: "gpt-4o-mini", messages, temp: 0.8 } │
│  └── Parse JSON: [GiftSuggestion(title, reason, price,    │
│       searchTerms)]                                       │
│       │                                                   │
│  Display Output                                           │
│  └── Swipeable cards: title, reason, priceRange          │
│  └── Per card: "Search on Amazon" + "Save to Gift Ideas"  │
│       │                                                   │
│  Cross-Feature Output                                     │
│  └── Save → GiftViewModel.createGiftIdea(person, title)   │
│       └── SwiftData GiftIdea entity (status: .idea)       │
└───────────────────────────────────────────────────────────┘
```

### Feature 14: IAP Pro Unlock

```
┌───────────────────────────────────────────────────────────┐
│  User Input                                               │
│  └── Tap "Unlock for $4.99" on paywall                   │
│       │                                                   │
│  PurchaseManager.purchase(productId: "com.zzoutuo.Giftly.prounlock")│
│  └── Product.products(for: [productId])                  │
│  └── product.purchase() → VerificationResult             │
│  └── case .verified(let transaction):                    │
│       └── transaction.finish()                           │
│       └── isProUnlocked = true                           │
│       │                                                   │
│  Persistence                                              │
│  └── StoreKit Transaction (synced via AppStore)          │
│  └── PurchaseManager.isProUnlocked (in-memory, reloaded on launch)│
│       │                                                   │
│  Display Output                                           │
│  └── Paywall dismissed with success animation            │
│  └── All Pro features available immediately              │
│       │                                                   │
│  Cross-Feature Output                                    │
│  └── Contact Import unlocked (Feature 3)                 │
│  └── Manual Entry limit removed (Feature 16)            │
│  └── Custom reminders enabled (Feature 11.1)             │
│  └── Widgets enabled (Feature 17)                        │
└───────────────────────────────────────────────────────────┘
```

---

## Implementation Flow

1. **Project scaffold**: Configure Xcode project (Bundle ID `com.zzoutuo.Giftly`), set min iOS 17.0, add capabilities (Contacts, UserNotifications, StoreKit, Widget Extension, Keychain Sharing if widget shares data).
2. **Data layer**: Define SwiftData `@Model` classes (Person, GiftIdea, GiftHistory, GiftStatus enum). Configure ModelContainer in `GiftlyApp.swift`.
3. **Services layer**: Implement ContactImportService, NotificationService (with category registration), PurchaseService (StoreKit 2), GiftAIService, DataExportService.
4. **Onboarding flow**: WelcomeView auto-dismiss + permission requests (notifications, contacts).
5. **Main views**: ContentView (TabView), BirthdayCardView, CalendarView, PersonDetailView, SettingsView.
6. **Person CRUD**: AddPersonView form, edit, delete with cascade.
7. **Gift features**: GiftIdeaListView, status transitions, history tracking.
8. **Notifications**: 3-tier scheduling, actionable notifications, deep linking.
9. **IAP integration**: Product loading, purchase flow, restore, paywall view.
10. **AI integration**: API key management (Keychain), GiftSuggestionView, OpenAI client.
11. **Widget**: Widget Extension target, TimelineProvider, App Group shared container.
12. **Polish**: Dark mode, Dynamic Type, VoiceOver labels, confetti animation, haptics, empty states.
13. **App icon**: Generate via Agnes Image API (gift icon with gradient background).
14. **Privacy manifest**: Create `PrivacyInfo.xcprivacy`.
15. **Build & test**: iPhone + iPad simulators.
16. **Push to GitHub**: Repository + GitHub Pages for policy pages.

---

## UI/UX Design Specifications

### Color Scheme
- **Primary (Lavender)**: `#7B68EE` — main brand color, used for tabs/buttons
- **Accent 1 (Coral Pink)**: `#FF6B9D` — today's birthday highlight, gift actions
- **Accent 2 (Mint Green)**: `#4ECDC4` — gift-related elements, success states
- **Gradients**: Lavender→Coral (diagonal), Mint→Lavender (diagonal) for cards/buttons
- **Backgrounds**: Light `#FFFFFF` / Dark `#000000` (true black for OLED)
- **Cards**: Light `#F2F2F7` / Dark `#1C1C1E`
- **Text Primary**: Light `#000000` / Dark `#FFFFFF`
- **Text Secondary**: Light `#8E8E93` / Dark `#AEAEB2`

### Typography
- App title: SF Pro Display 34pt Bold
- Page title: SF Pro Display 28pt Semibold
- Card title: SF Pro Text 17pt Semibold
- Body: SF Pro Text 15pt Regular
- Caption: SF Pro Text 13pt Regular
- All support Dynamic Type

### Layout
- Card corner radius: 20pt
- Card shadow: 0.05 opacity, 10pt blur, 5pt y-offset
- Today's card: pink border 2pt + subtle pulse
- Standard padding: 20pt
- Spacing between cards: 20pt

### Animations
- Card appear: `spring(response: 0.4, dampingFraction: 0.8)` + light haptic
- Gift prepared: confetti + scale 1.2s + medium haptic
- Tab switch: `.easeInOut` 0.25s + light haptic
- Button tap: `scale(0.95)` + spring 0.2s + light haptic
- Confetti respects `UIAccessibility.isReduceMotionEnabled`

---

## Code Generation Rules

- One feature per module, high cohesion, low coupling
- Semantic naming, clear file structure
- Never add comments in code unless asked
- Apple native first: prioritize SwiftUI/Swift/SwiftData/StoreKit 2
- Open source first: integrate existing MIT projects when available (reference: `kkulykk/birthday-reminder`)
- Read version dynamically from `Bundle.main.infoDictionary` — NEVER hardcode version
- `@Observable` not `ObservableObject` (iOS 17+)
- Store API keys in Keychain with `kSecAttrAccessibleWhenUnlocked`
- Contacts: read only name/birthday/photo (privacy minimization)
- All user data in SwiftData local store (no CloudKit, no server)

---

## App Store Compliance — AI Features

### Guideline 2.1(a) — App Completeness
This app uses BYO (Bring Your Own) API key model for AI features. Apple reviewers need a way to test AI functionality.

**Required Actions**:
1. Create `app_review_info.md` with demo API key configuration instructions (in project root, NOT pushed to public GitHub)
2. Add clear onboarding guidance for new users (API key setup in Settings)
3. NEVER show clickable AI buttons that lead to errors when no key is configured — show graceful prompt to enter key
4. `canGenerate` logic: `isAIUnlocked && hasAPIKey` — no free generation counting (BYO Key model)

### Dead Code Prevention
- NEVER add: `freeGenerationsUsed`, `maxFreeGenerations`, `canGenerateFree`, `incrementGenerationCount()`
- These are dead code in BYO Key model and cause App Store rejections under 2.1(a)

### Guideline 5.1 — Privacy
- API key stored in Keychain (never leaves device)
- AI requests go directly from device to OpenAI (no intermediary server)
- Privacy Policy must disclose: "AI gift suggestions are generated using your own OpenAI API key. Your key is stored securely in iOS Keychain and never transmitted to our servers. Gift suggestion requests are sent directly from your device to OpenAI's API."

---

## Build & Deployment Checklist

- [ ] Xcode project: Bundle ID `com.zzoutuo.Giftly`, min iOS 17.0
- [ ] Capabilities: Contacts, UserNotifications, StoreKit, Keychain Sharing (for widget), App Groups (for widget shared container)
- [ ] App icon: 1024x1024 generated via Agnes Image API
- [ ] PrivacyInfo.xcprivacy: declare SwiftData/Contacts/UserNotifications/StoreKit usage
- [ ] NSContactsUsageDescription: "Giftly needs access to your contacts to import birthdays. We only read names, birthdays, and photos — never phone numbers, emails, or addresses."
- [ ] NSUserTrackingUsageDescription: NOT needed (no tracking)
- [ ] StoreKit products configured in App Store Connect:
  - `com.zzoutuo.Giftly.prounlock` — Non-consumable, $4.99
  - `com.zzoutuo.Giftly.aiunlock` — Non-consumable, $5.99
- [ ] Widget Extension target added
- [ ] App Group: `group.com.zzoutuo.Giftly` (shared SwiftData container for widget)
- [ ] Policy pages deployed to GitHub Pages (Privacy, Terms, Support)
- [ ] Landing page with App Store download button
- [ ] Test on iPhone simulator (iPhone 16, iOS 18.4) and iPad simulator (iPad Pro 13-inch M5)
- [ ] Verify all features from Feature Inventory work end-to-end
- [ ] Verify no dead AI buttons when no API key configured
- [ ] Verify dark mode, Dynamic Type, VoiceOver
- [ ] Verify notification scheduling (3-tier, yearly repeat)
- [ ] Verify IAP purchase + restore flows
