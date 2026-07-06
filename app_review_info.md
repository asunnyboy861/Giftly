# Giftly — App Review Information

## App Details
- **App Name**: Giftly
- **Bundle ID**: com.zzoutuo.Giftly
- **Version**: 1.0
- **Category**: Lifestyle / Productivity
- **Pricing**: Freemium (Free with In-App Purchases)

## Demo Account / Configuration

Giftly is a fully offline app that does not require a login or demo account. All features are accessible immediately after download.

### AI Feature Testing (BYO Key Model)

Giftly's AI gift suggestions use a **Bring Your Own Key (BYO Key)** model:

1. Open the app → Settings → AI Configuration
2. Enter any OpenAI-compatible API key (e.g., GPT-4o-mini, gpt-4o)
3. Tap "Save API Settings"
4. Go to any person → "AI Ideas" → set budget → "Generate Ideas"

**For reviewer convenience**, a demo API key can be provided upon request. Without a key, the AI suggestion screen shows a clear guidance message and a link to Settings. The app works perfectly without an API key — all other features (birthday tracking, gift idea lists, reminders, calendar, export/import) are fully functional.

## In-App Purchases

| Product ID | Type | Price | Display Name | Description |
|---|---|---|---|---|
| com.zzoutuo.Giftly.prounlock | Non-Consumable | $4.99 | Giftly Pro | Unlimited tracking & reminders |
| com.zzoutuo.Giftly.aiunlock | Non-Consumable | $5.99 | AI Add-on | Unlock AI gift suggestions |

### Testing IAP
- Both products are **non-consumable** (one-time purchases, no subscription)
- "Restore Purchases" button is available in the Paywall
- Purchase status is reactive — features unlock immediately after purchase
- No auto-renewal, no trial period, no subscription

## Policy Pages

| Page | URL |
|---|---|
| Privacy Policy | https://asunnyboy861.github.io/Giftly/privacy.html |
| Terms of Use | https://asunnyboy861.github.io/Giftly/terms.html |
| Support Page | https://asunnyboy861.github.io/Giftly/support.html |

All three links are accessible from:
- Paywall view (Privacy Policy + Terms of Use below purchase buttons)
- Settings → Legal section (all three links)

## Review Notes

### AI Gift Suggestions (BYO Key Model)
- AI features use a "Bring Your Own API Key" model
- Users provide their own API key in Settings → "AI Configuration" → "API Key"
- The app does NOT sell API keys or AI usage
- No specific AI provider (ChatGPT/OpenAI) is promoted in the UI
- Users can use any OpenAI-compatible API endpoint (custom Base URL supported)
- AI features are gated behind a separate "AI Add-on" IAP ($5.99 one-time)
- The "AI Add-on" unlocks the AI feature UI; users still need their own API key
- Any API costs are paid directly by the user to their chosen provider
- No free generation counting — once unlocked with a key, AI is unlimited

### IAP Compliance
- Both IAP products are non-consumable (one-time purchases)
- No subscriptions, no auto-renewal, no trial periods
- Purchase status uses `Transaction.currentEntitlement(for:)` for reactive updates
- All views that depend on purchase status use `@EnvironmentObject` reactive binding
- "Restore Purchases" button is available in the Paywall
- Privacy Policy and Terms of Use links are visible in the Paywall below purchase buttons

### China App Store Compliance
This app does NOT include ChatGPT functionality or reference ChatGPT/OpenAI in any user-facing UI or metadata for the China storefront. The AI gift suggestion feature uses a generic "Bring Your Own API Key" model where users configure their own API endpoint. No specific AI provider is promoted or bundled. The app is safe for distribution in all App Store regions including China.

### Privacy
- **Contacts**: Used only to import names, birthdays, and photos (privacy-minimized — no phone/email/address is accessed)
- **Notifications**: Used for birthday reminders (7-day, 1-day, day-of at 9 AM)
- **Keychain**: API keys stored securely in Keychain (never in UserDefaults)
- **No analytics, no tracking, no third-party SDKs**
- **PrivacyInfo.xcprivacy**: Included in the app bundle declaring UserDefaults and FileTimestamp API usage reasons

### Core Features (All Free)
- Add unlimited people (no limit on free tier)
- Track birthdays with automatic age calculation
- Zodiac sign display
- Yearly repeating notifications (7 days, 1 day, day-of)
- Gift idea list with status tracking (Idea → Planned → Purchased → Given)
- Gift history recording
- Contact import (birthdays only)
- Calendar view of upcoming birthdays
- Search and favorites
- Export/import backup (JSON)

### Pro Features ($4.99 one-time)
The free tier is fully functional. Pro unlock is positioned as a "support the developer" purchase with no feature gating on core functionality. The Paywall leads with app features, not AI usage.

### How to Test
1. Launch the app — onboarding will request notification permission
2. Tap "+" to add a person (name, birthday, photo, relationship, interests, notes)
3. View the person's detail page — see age, zodiac, countdown
4. Tap "View List" to add gift ideas and track their status
5. Go to Calendar tab to see all birthdays sorted by month
6. Go to Settings to configure API key, export/import data, view legal pages
7. Tap "Upgrade" in Settings to see the Paywall with two IAP products
