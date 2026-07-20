## Subtitle
Birthday & Gift Reminder

## Promotional Text
Never forget a birthday. Track gift ideas, get smart reminders, and plan thoughtful gifts - all with one-time pricing.

## Description
Giftly is the privacy-first birthday and gift reminder that helps you never forget the people who matter most. Track birthdays, plan gifts, and get smart reminders - all with one-time pricing.

NEVER FORGET A BIRTHDAY
- Get a countdown to every birthday with 7-day, 1-day, and day-of reminders
- Yearly repeating reminders keep you on track forever
- Actionable notifications with Call, Message, and Gift Ideas buttons
- See today's birthdays and upcoming celebrations at a glance

PLAN GIFTS LIKE A PRO
- Capture gift ideas for every friend and family member on your list
- Track each gift from Idea to Planned to Purchased to Given
- Never accidentally repeat a present - your full gift history is one tap away
- Set estimated budgets for every gift idea

AI GIFT SUGGESTIONS - FREE TO START
- Stuck on what to buy? Let AI suggest thoughtful gifts
- 3 free suggestions every month
- Powered by Apple Intelligence on-device for maximum privacy
- Set your budget and get 5 personalized suggestions instantly
- Upgrade to unlimited AI suggestions with a one-time purchase

IMPORT BIRTHDAYS IN SECONDS
- One tap to import birthdays from your Contacts
- We only read names, birthdays, and photos - never phone numbers, emails, or addresses
- Smart deduplication prevents duplicate entries

BEAUTIFUL AND PRIVATE
- All data stored locally on your device using SwiftData
- No cloud, no account, no tracking
- Stunning card-based interface with today's birthdays highlighted
- Full calendar view to see every birthday at a glance
- Native dark mode support
- Search birthdays by name
- Star favorites for quick access

ONE-TIME PRICING. PAY ONCE, YOURS FOREVER.
- Free: Up to 5 birthdays, day-of reminders, 3 AI suggestions per month, basic features
- Giftly Pro ($4.99 one-time): Unlimited birthdays, contact import, all reminder tiers, gift idea tracking, gift history, data export
- Giftly AI ($5.99 one-time): Unlimited AI gift suggestions - powered by Apple Intelligence

Restore purchases anytime at no extra cost. Pay once, use forever.

PRIVACY FIRST
- All data stays on your device
- No analytics, no advertising, no tracking
- AI runs on-device via Apple Intelligence - your data never leaves your phone
- Privacy Policy: https://asunnyboy861.github.io/Giftly/privacy.html
- Terms of Use: https://asunnyboy861.github.io/Giftly/terms.html

Giftly was built by people who believe in one-time pricing. One purchase, yours forever.

## Keywords
countdown,calendar,wishlist,notification,present,holiday,friends,family,party,age,reminder,gift

## What's New in This Version
Welcome to Giftly! This is our first release.

FEATURES
- Birthday reminders with 3-tier notifications (7 days, 1 day, and day-of)
- Gift idea tracking with status: Idea, Planned, Purchased, Given
- Gift history to prevent duplicate gifting
- AI gift suggestions - 3 free per month, unlimited with one-time purchase
- Powered by Apple Intelligence on-device
- One-tap contact import (privacy-minimized - name, birthday, photo only)
- Calendar view of all birthdays grouped by month
- Actionable notifications with Call, Message, and Gift Ideas buttons
- Person detail view with age, zodiac sign, and gift history
- One-time purchases only - pay once, use forever
- Privacy-first: all data stays on your device using SwiftData
- Data export and import (JSON backup)
- Dark mode support
- Search and favorites

PRICING
- Free: Up to 5 birthdays, day-of reminders, 3 AI suggestions per month
- Giftly Pro ($4.99 one-time): Unlimited birthdays, contact import, gift tracking, data export
- Giftly AI ($5.99 one-time): Unlimited AI gift suggestions - powered by Apple Intelligence

We built Giftly because we believe in one-time pricing for birthday apps. Pay once, use forever.

## Review Notes
Thank you for reviewing Giftly!

PERMISSION REQUEST UI (Guideline 5.1.1(iv) - July 16, 2026):
- The pre-permission message on the onboarding import page now uses a "Continue" button (previously "Import from Contacts") to proceed to the system Contacts permission prompt.
- The "Skip for now" button has been REMOVED from the pre-permission message. Users always proceed to the system permission request after the message.
- After the system permission dialog, if the user denies access, an alert offers "Open Settings" (to grant later) or "Cancel" (to continue without contacts). This is a post-permission alert, which is compliant.
- The pre-permission message only explains WHY contacts are needed (reads only name, birthday, photo) and does not block or delay the permission request.

AI FEATURE LOCATION (Guideline 2.3 - July 16, 2026):
- AI gift suggestions are implemented and accessible at: Person Detail View -> "AI Ideas" button (in the Gift Ideas section).
- Settings -> "AI Provider" section shows Apple Intelligence status (Active/Unavailable) with a footer explaining how to access AI Ideas.
- AI requires iOS 26+ with Apple Intelligence enabled. If unavailable, the AI screen shows "Apple Intelligence Required" guidance (this is the feature working as designed, not a missing feature).
- There is NO separate "AI configuration" screen - AI runs automatically via Apple Intelligence with no setup required.

CONTACTS PRIVACY (Guideline 2.1 - July 16, 2026):
- Do you upload the user's contacts to the server? NO. Contacts are read locally via Apple's CNContactStore and stored in the on-device SwiftData database. No network call transmits contact data. AI gift suggestions run entirely on-device via Apple Intelligence - no network call is made for AI suggestions. The only network call in the app is the optional support form (which sends only user-typed message + app diagnostics - never contact data).
- Do you share the user's contacts to any third-party? NO. The app contains zero third-party SDKs (no analytics, no advertising, no tracking). No data broker, advertising network, or third-party API receives contact information. AI gift suggestions use Apple Intelligence (on-device, iOS 26+) - no data leaves the device.
- Privacy manifest (PrivacyInfo.xcprivacy) declares NSPrivacyTracking: false and an empty NSPrivacyCollectedDataTypes array.
- Updated Privacy Policy with a dedicated "Contacts Privacy - Direct Answers" section: https://asunnyboy861.github.io/Giftly/privacy.html

TESTING THE APP (Free Tier):
1. Add up to 5 birthdays manually - tap the + button on the Home tab
2. Add a birthday with today's date to see the "today" highlight (pink border) on the card
3. Tap any birthday card to open Person Detail - see age, zodiac, gift ideas, and gift history
4. Switch to the Calendar tab to see all birthdays grouped by month
5. Use the search bar at the top to filter birthdays by name
6. Long-press or swipe on gift ideas to change status (Idea -> Planned -> Purchased -> Given)

IAP TESTING:
- Two non-consumable products:
  - com.zzoutuo.Giftly.prounlock ($4.99) - Removes 5-contact limit, enables contact import, gift tracking, gift history, data export
  - com.zzoutuo.Giftly.aiunlock ($5.99) - Unlimited AI gift suggestions - powered by Apple Intelligence
- A StoreKit Configuration file (Giftly.storekit) is included in the project for local testing
- To enable StoreKit testing: Edit Scheme -> Run -> Options -> StoreKit Configuration -> select Giftly.storekit
- Purchase Pro Unlock from Settings tab -> "Upgrade to Giftly Pro" button
- Purchase AI Add-on from Settings tab -> Purchases section
- "Restore Purchases" button is available in Settings -> Purchases section

AI FEATURE TESTING - IMPORTANT:
- The app uses Apple Intelligence (on-device) as the ONLY AI provider
- Free tier: 3 AI suggestions per month (auto-resets monthly)
- AI Add-on ($5.99): Unlimited AI suggestions
- WHERE TO FIND AI FEATURES (in response to Guideline 2.3):
  - AI suggestions are NOT a separate settings screen. They are accessed per-person.
  - Step 1: Tap the "+" button on the Home tab to add a person (name + birthday)
  - Step 2: Tap that person's birthday card to open Person Detail View
  - Step 3: In the "Gift Ideas" section, tap the "AI Ideas" button (wand.and.stars icon)
  - Step 4: The AI Suggestions screen opens with budget sliders and a "Generate Ideas" button
  - Settings -> "AI Provider" section shows the STATUS of Apple Intelligence (Active/Unavailable) and includes a footer explaining how to access AI Ideas
- To test AI (on iOS 26+ with Apple Intelligence enabled):
  1. Open any person's detail view -> Tap "AI Ideas" button
  2. Set budget using the sliders -> Tap "Generate Ideas"
  3. View 5 AI-generated gift suggestions
  4. Tap "Add as Idea" on any suggestion to save it to gift ideas
  5. The usage banner shows remaining free suggestions (e.g., "3 of 3 free suggestions remaining this month")
- If Apple Intelligence is not available (pre-iOS 26 or unsupported device, or not enabled in iOS Settings > Apple Intelligence & Siri):
  - The AI screen shows "Apple Intelligence Required" explaining the feature is unavailable - THIS IS THE FEATURE WORKING AS DESIGNED, not a missing feature
  - The "Apple Intelligence Required" screen includes guidance to enable it in Settings > Apple Intelligence & Siri
  - No external AI provider or outside mechanism is used
- If free tier is exhausted: AI buttons show the paywall (NOT an error)
- AI runs entirely on-device via Apple Intelligence - no network call is made for AI suggestions

CONTACT IMPORT TESTING:
- Requires Contacts access permission
- Onboarding: On the final onboarding page, tap "Continue" to proceed to the system Contacts permission prompt
- Home tab: Tap the person.2.badge.gearshape icon (top-left) or tap "Import from Contacts" on the empty state
- Grant permission when prompted
- App reads ONLY: name, birthday, and photo (privacy-minimized - no phone/email/address)
- Duplicate detection prevents importing contacts already in the app

NOTIFICATIONS:
- App schedules 3 notifications per birthday (7 days before, 1 day before, day-of at 9:00 AM)
- Notifications repeat yearly
- Notification category includes Call, Message, and Gift Ideas action buttons
- To test: Add a birthday with a date 7 days from today, then check pending notification requests

PRIVACY:
- All user data stored locally using SwiftData (no cloud, no account, no server)
- No analytics SDK, no advertising SDK, no tracking
- App does NOT use App Tracking Transparency (no tracking performed)
- Contact import reads only name, birthday, and photo
- AI runs on-device via Apple Intelligence (no data leaves the device)
- Privacy Policy: https://asunnyboy861.github.io/Giftly/privacy.html
- Terms of Use: https://asunnyboy861.github.io/Giftly/terms.html
- Support Page: https://asunnyboy861.github.io/Giftly/support.html

DATA EXPORT/IMPORT:
- Settings -> Export Backup: Generates a JSON file with all people, gift ideas, and gift history
- Settings -> Import Backup: Restore from a previously exported JSON file (with deduplication)

Sandbox testing account is not required for the free tier. For IAP testing, use a Sandbox Tester account configured in App Store Connect, or use the included Giftly.storekit StoreKit Configuration file for local testing.

If you have any questions during review, please contact: iocompile67692@gmail.com