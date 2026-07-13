## Subtitle
Birthday & Gift Reminder

## Promotional Text
Never forget a birthday again. Smart reminders, gift tracker, and free AI suggestions - all for one low price. No subscriptions, ever.

## Description
Giftly is the privacy-first birthday and gift reminder that helps you never forget the people who matter most. Track birthdays, plan gifts, and get smart reminders - all with one-time pricing and no subscriptions.

NEVER FORGET A BIRTHDAY
- Get a countdown to every birthday with 7-day, 1-day, and day-of reminders
- Yearly repeating reminders keep you on track forever
- Actionable notifications with Call, Message, and Gift Ideas buttons
- See today's birthdays and upcoming celebrations at a glance
- Custom alert time so you get reminded when it works for you

PLAN GIFTS LIKE A PRO
- Capture gift ideas for every friend and family member on your list
- Build a wish list of presents for every birthday, holiday, and party
- Track each gift from Idea to Planned to Purchased to Given
- Never accidentally repeat a present - your full gift history is one tap away
- Set estimated budgets for every gift idea
- The perfect gift tracker for birthdays, holidays, and special occasions

AI GIFT SUGGESTIONS - FREE TO START
- Stuck on what to buy? Let AI suggest thoughtful gifts
- 3 free suggestions every month - no API key needed
- Powered by Apple Intelligence (on-device, private)
- Set your budget and get 5 personalized suggestions instantly
- Each suggestion includes a reason, price range, and search terms
- Save any suggestion straight to your gift ideas list
- Upgrade to unlimited AI suggestions with a one-time purchase
- Advanced: bring your own API key for premium models (GPT-4o, Gemini, etc.)

IMPORT BIRTHDAYS IN SECONDS
- One tap to import birthdays from your Contacts
- We only read names, birthdays, and photos - never phone numbers, emails, or addresses
- Smart deduplication prevents duplicate entries
- Perfect for family and friends - everyone's bday in one place

BEAUTIFUL AND PRIVATE
- All data stored locally on your device using SwiftData
- No cloud, no account, no tracking
- Stunning card-based interface with today's birthdays highlighted
- Full calendar view to see every birthday at a glance
- Native dark mode support
- Search birthdays by name
- Star favorites for quick access

ONE-TIME PRICING. NO SUBSCRIPTIONS. EVER.
- Free: Up to 5 birthdays, day-of reminders, 3 AI suggestions per month, basic features
- Giftly Pro ($4.99 one-time): Unlimited birthdays, contact import, all reminder tiers, gift idea tracking, gift history, data export
- Giftly AI ($5.99 one-time): Unlimited AI gift suggestions - no API key needed

Restore purchases anytime at no extra cost. Pay once, use forever.

PRIVACY FIRST
- All data stays on your device
- No analytics, no advertising, no tracking
- AI runs on-device via Apple Intelligence - your data never leaves your phone
- Optional: bring your own API key for premium models (stored in iOS Keychain)
- Privacy Policy: https://asunnyboy861.github.io/Giftly/privacy.html
- Terms of Use: https://asunnyboy861.github.io/Giftly/terms.html

Giftly was built by people who hate subscriptions as much as you do. One purchase, yours forever. Whether it is a birthday, holiday, or anniversary - Giftly helps you celebrate every special moment.

## Keywords
countdown,calendar,tracker,ideas,wish list,notification,present,holiday,friends,family,ai,party,age,reminder,birthday,gift

## What's New in This Version
Welcome to Giftly! This is our first release.

FEATURES
- Birthday reminders with 3-tier notifications (7 days, 1 day, and day-of)
- Gift idea tracking with status: Idea, Planned, Purchased, Given
- Gift history to prevent duplicate gifting
- AI gift suggestions - 3 free per month, unlimited with one-time purchase
- Powered by Apple Intelligence (on-device, private) - no API key needed
- One-tap contact import (privacy-minimized - name, birthday, photo only)
- Calendar view of all birthdays grouped by month
- Actionable notifications with Call, Message, and Gift Ideas buttons
- Person detail view with age, zodiac sign, and gift history
- One-time purchases - no subscriptions, ever
- Privacy-first: all data stays on your device using SwiftData
- Data export and import (JSON backup)
- Dark mode support
- Search and favorites

PRICING
- Free: Up to 5 birthdays, day-of reminders, 3 AI suggestions per month
- Giftly Pro ($4.99 one-time): Unlimited birthdays, contact import, gift tracking, data export
- Giftly AI ($5.99 one-time): Unlimited AI gift suggestions - no API key needed

We built Giftly because we were tired of subscription-only birthday apps. Pay once, use forever.

## Review Notes
Thank you for reviewing Giftly!

CONTACTS PRIVACY (in response to Guideline 2.1 inquiry):
- Do you upload the user's contacts to the server? NO. Contacts are read locally via Apple's CNContactStore and stored in the on-device SwiftData database. No network call transmits contact data. The only network calls in the app are optional AI suggestions (which send only the person's name, age, relationship, interests, budget — never the contact record or contacts list) and an optional support form (which sends only user-typed message + app diagnostics — never contact data).
- Do you share the user's contacts to any third-party? NO. The app contains zero third-party SDKs (no analytics, no advertising, no tracking). No data broker, advertising network, or third-party API receives contact information. The default AI provider is Apple Intelligence (on-device, iOS 26+) — no data leaves the device. The optional BYO Key AI path sends only a minimal prompt (name, age, relationship, interests, budget) to the user's own chosen provider, never the full contact record.
- Privacy manifest (PrivacyInfo.xcprivacy) declares NSPrivacyTracking: false and an empty NSPrivacyCollectedDataTypes array.
- Updated Privacy Policy with a dedicated "Contacts Privacy — Direct Answers" section: https://asunnyboy861.github.io/Giftly/privacy.html

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
  - com.zzoutuo.Giftly.aiunlock ($5.99) - Unlimited AI gift suggestions (no API key needed - uses Apple Intelligence)
- A StoreKit Configuration file (Giftly.storekit) is included in the project for local testing
- To enable StoreKit testing: Edit Scheme -> Run -> Options -> StoreKit Configuration -> select Giftly.storekit
- Purchase Pro Unlock from Settings tab -> "Upgrade to Giftly Pro" button
- Purchase AI Add-on from Settings tab -> Purchases section
- "Restore Purchases" button is available in Settings -> Purchases section

AI FEATURE TESTING - IMPORTANT:
- The app uses Apple Intelligence (on-device) as the default AI provider - NO API KEY REQUIRED
- Free tier: 3 AI suggestions per month (auto-resets monthly)
- AI Add-on ($5.99): Unlimited AI suggestions
- To test AI (on iOS 26+ with Apple Intelligence enabled):
  1. Open any person's detail view -> Tap "AI Ideas" button
  2. Set budget using the sliders -> Tap "Generate Ideas"
  3. View 5 AI-generated gift suggestions
  4. Tap "Add as Idea" on any suggestion to save it to gift ideas
  5. The usage banner shows remaining free suggestions (e.g., "3 of 3 free suggestions remaining this month")
- If Apple Intelligence is not available (pre-iOS 26 or unsupported device):
  - The AI screen shows "API Key Required" with a link to Settings
  - User can add their own API key in Settings -> Advanced -> BYO Key
  - Any ChatCompletions-compatible provider works (OpenAI, Gemini, DeepSeek, etc.)
- If free tier is exhausted: AI buttons show the paywall (NOT an error)
- API key (optional) is stored in iOS Keychain and never leaves the device
- AI requests go directly from the device to the provider (no intermediary server)

CONTACT IMPORT TESTING:
- Requires Contacts access permission
- Tap "+" on Home tab -> Tap "Import from Contacts"
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
- Optional API key stored in iOS Keychain
- Privacy Policy: https://asunnyboy861.github.io/Giftly/privacy.html
- Terms of Use: https://asunnyboy861.github.io/Giftly/terms.html
- Support Page: https://asunnyboy861.github.io/Giftly/support.html

DATA EXPORT/IMPORT:
- Settings -> Export Backup: Generates a JSON file with all people, gift ideas, and gift history
- Settings -> Import Backup: Restore from a previously exported JSON file (with deduplication)

Sandbox testing account is not required for the free tier. For IAP testing, use a Sandbox Tester account configured in App Store Connect, or use the included Giftly.storekit StoreKit Configuration file for local testing.

If you have any questions during review, please contact: iocompile67692@gmail.com
