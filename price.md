# Pricing Configuration

## Monetization Model: Freemium with Non-Consumable IAP (One-Time Purchases)

Giftly is free with a 5-contact limit. Two separate one-time (non-consumable) purchases unlock feature sets permanently. No subscriptions, ever — this is the core competitive differentiator against subscription-based rivals.

## IAP Products

### 1. Pro Unlock
- **Reference Name**: Giftly Pro Unlock
- **Product ID**: `com.zzoutuo.Giftly.prounlock`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $4.99 USD (one-time)
- **Display Name**: `Giftly Pro Unlock` (19 chars, ≤35 ✅)
- **Description**: `Unlimited birthdays, import, reminders, widgets` (48 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required

### 2. AI Advanced
- **Reference Name**: Giftly AI Advanced
- **Product ID**: `com.zzoutuo.Giftly.aiunlock`
- **Type**: Non-consumable (one-time purchase, permanently unlocked)
- **Price**: $5.99 USD (one-time)
- **Display Name**: `Giftly AI Advanced` (19 chars, ≤35 ✅)
- **Description**: `AI gift ideas, gift history, budget tracking` (45 chars, ≤55 ✅)
- **Localization**: English (US)
- **Restore Purchases**: ✅ Required

## Free Tier (Default)

- **Price**: Free
- **Features**:
  - Up to 5 birthday contacts
  - Manual birthday entry
  - Day-of birthday notifications
  - Basic card UI
  - No ads
- **Conversion hooks**:
  - Adding 6th contact triggers Pro paywall
  - Tapping "Gift Ideas" on a card triggers Pro paywall (gift idea tracking is Pro)
  - Tapping "Need gift ideas?" triggers AI paywall (AI suggestions are AI Advanced)

## Pro Features Unlocked

⚠️ **CRITICAL**: This table lists features that WILL be implemented in PHASE 4. Cross-referenced with `capabilities.md` from PHASE 2.

| Feature | Free | Pro Unlock ($4.99) | AI Advanced ($5.99) |
|---------|:----:|:---:|:---:|
| Birthday contacts | 5 max | Unlimited | Unlimited |
| Contact import (Contacts) | ❌ | ✅ | ✅ |
| Manual birthday entry | ✅ | ✅ | ✅ |
| Custom reminder schedule (7d, 1d, 0d) | Day-of only | ✅ All 3 tiers | ✅ All 3 tiers |
| Birthday card UI | ✅ Basic | ✅ Full | ✅ Full |
| Calendar view | ✅ | ✅ | ✅ |
| Gift idea recording | ❌ | ✅ | ✅ |
| Gift status tracking (Idea→Given) | ❌ | ✅ | ✅ |
| Home screen widget | ❌ | ✅ | ✅ |
| Age calculator | ❌ | ✅ | ✅ |
| Data export/import | ❌ | ✅ | ✅ |
| Dark mode | ✅ | ✅ | ✅ |
| AI gift suggestions (BYO API Key) | ❌ | ❌ | ✅ |
| Gift history tracking | ❌ | ❌ | ✅ |
| Budget management | ❌ | ❌ | ✅ |
| Notification quick actions | ✅ | ✅ | ✅ |
| Restore purchases | ✅ | ✅ | ✅ |

## BYO Key Model: AI Features

### How AI Advanced Works
- **$5.99 one-time purchase** unlocks the AI features interface (GiftSuggestionView, API key management, budget slider)
- **User provides their own OpenAI API key** (stored in iOS Keychain) for actual AI calls
- **AI generation is ALWAYS unlimited** — no counting, no limits, no free tier for AI
- User pays their own OpenAI API usage costs directly to OpenAI

### Why This Model
1. Zero server cost for developer (no API bills)
2. Sustainable — no ongoing costs to maintain
3. Privacy-friendly — requests go directly device → OpenAI
4. Supports one-time purchase — no recurring API fees to subsidize
5. User controls which AI model to use

### `canGenerate` Logic
```
canGenerate = isAIUnlocked && hasAPIKey
```
- NO `freeGenerationsUsed`, `maxFreeGenerations`, `incrementGenerationCount()` — these are dead code in BYO Key model
- If user has not purchased AI Advanced: AI buttons show paywall (not error)
- If user purchased AI Advanced but no API key: show "Enter API Key" prompt (not error)
- If user purchased AI Advanced + has API key: unlimited generation

## Free Trial
- **Duration**: None (no trial — free tier is permanently usable with 5 contacts)
- **Type**: Free tier (not a time-limited trial)

## Policy Pages Required
- Support Page: ✅ (must include restore purchases instructions + IAP info)
- Privacy Policy: ✅ (must disclose: local data, no cloud, no tracking, BYO API key goes to OpenAI directly)
- Terms of Use (EULA): ✅ (recommended for IAP apps — covers one-time purchase terms)
- **Total policy pages**: 3

## Apple IAP Compliance Checklist
- [x] One-time purchase terms will be included in Terms of Use
- [x] Restore purchases instructions included in Support Page
- [x] Pricing clearly stated in PaywallView ($4.99 + $5.99)
- [x] No free trial (not applicable — free tier is permanent)
- [x] Restore purchases functionality implemented
- [x] No external payment links (Guideline 3.1.1)
- [x] No price references to outside-App-Store options
- [x] All IAP descriptions ≤ 55 characters
- [x] All IAP display names ≤ 35 characters
- [x] No subscription — Guideline 3.1.2(c) not applicable
- [x] BYO API key: no dead code (freeGenerationsUsed, etc.)
- [x] AI generation unlimited for users with own key
- [x] App Review Info: demo instructions for testing IAP
