# keytext Inventory - Code-to-Metadata Audit Trail

## App Info
- **App Name (Title)**: Giftly
- **keytext File**: keytext.md
- **Generated**: 2026-07-13
- **Codebase Path**: /Volumes/ORICO-APFS/app/APP/IOS-APP/2026/202607/20260706/Giftly/Giftly

## Feature Verification Table

| Feature Name | Code Evidence (file + line/class) | Status | Monetization | keytext Description |
|--------------|-----------------------------------|--------|--------------|---------------------|
| Birthday Reminders (3-tier) | `NotificationService.swift` - scheduleBirthdayReminders() | IMPLEMENTED | free (day-of), pro (7d,1d) | "Get a countdown to every birthday with 7-day, 1-day, and day-of reminders" |
| Gift Idea Tracking | `GiftIdea.swift` + `GiftIdeaListView.swift` + `GiftViewModel.swift` | IMPLEMENTED | pro | "Track each gift from Idea to Planned to Purchased to Given" |
| Gift History | `GiftHistory.swift` + `PersonDetailView.swift` | IMPLEMENTED | pro | "Never accidentally repeat a present - your full gift history is one tap away" |
| AI Gift Suggestions (Apple Intelligence) | `AppleIntelligenceService.swift` + `AIUsageTracker.swift` | IMPLEMENTED | free (3/month), ai addon (unlimited) | "3 free suggestions every month - no API key needed" |
| AI Gift Suggestions (BYO Key) | `GiftAIService.swift` + `KeychainHelper.swift` | IMPLEMENTED | ai addon | "Optional: bring your own API key for premium models" |
| Contact Import | `ContactImportService.swift` | IMPLEMENTED | pro | "One tap to import birthdays from your Contacts" |
| Calendar View | `CalendarView.swift` | IMPLEMENTED | free | "Full calendar view to see every birthday at a glance" |
| Person Detail View | `PersonDetailView.swift` | IMPLEMENTED | free | "Person detail view with age, zodiac sign, and gift history" |
| Actionable Notifications | `NotificationService.swift` + `NotificationDelegate.swift` | IMPLEMENTED | free | "Actionable notifications with Call, Message, and Gift Ideas buttons" |
| Data Export/Import | `DataExportService.swift` | IMPLEMENTED | pro | "Data export and import (JSON backup)" |
| Dark Mode | Asset Catalog colors + SwiftUI native | IMPLEMENTED | free | "Native dark mode support" |
| Search & Favorites | `ContentView.swift` + `Person.swift` isFavorite | IMPLEMENTED | free | "Search birthdays by name, Star favorites for quick access" |
| Onboarding | `OnboardingView.swift` | IMPLEMENTED | free | 3-page welcome + contact import option |
| IAP: Pro Unlock | `PurchaseService.swift` - com.zzoutuo.Giftly.prounlock | IMPLEMENTED | $4.99 one-time | "Unlimited birthdays, contact import, gift tracking, data export" |
| IAP: AI Add-on | `PurchaseService.swift` - com.zzoutuo.Giftly.aiunlock | IMPLEMENTED | $5.99 one-time | "Unlimited AI gift suggestions - no API key needed" |

## Document-Code Conflict Resolution

| # | Conflicting Document Claim | Actual Code Evidence | Resolution | Impact on keytext.md |
|---|---------------------------|----------------------|------------|----------------------|
| 1 | `price.md` lists "AI gift suggestions" under AI Advanced only | `AppleIntelligenceService.swift` + `AIUsageTracker.swift` implement free tier (3/month) via Apple Intelligence | Code wins: Free tier 3/month exists | Added "3 free suggestions every month" to Description |
| 2 | `us.md` mentions Widget feature | No Widget Extension target found in project | Code wins: Widget not implemented | Removed widget mention from Description |
| 3 | None other | - | - | - |

## ASO Keyword Evidence

| Keyword | Source | Traffic | Difficulty | ROI | Placement | Rationale |
|---------|--------|---------|------------|-----|-----------|-----------|
| birthday reminder | aso-mcp search_keywords | 8.0 | 8.5 | 0.94 | Subtitle | Core feature, high traffic |
| gift | aso-mcp search_keywords | 8.8 | 8.6 | 1.02 | Subtitle + Keywords | Highest ROI, core feature |
| countdown | aso-mcp search_keywords | 7.7 | 9.4 | 0.82 | Keywords | Related feature, long-tail |
| calendar | Competitor analysis | Medium | Medium | - | Keywords | Category word |
| reminder | aso-mcp search_keywords | 8.0 | 8.5 | 0.94 | Keywords | Core feature synonym |

## Keyword-to-Feature Mapping

| Keyword | Maps to Feature | Relevance |
|---------|-----------------|-----------|
| birthday | Birthday Reminders | RELEVANT |
| gift | Gift Idea Tracking | RELEVANT |
| reminder | Notification Scheduling | RELEVANT |
| countdown | Birthday countdown display | RELEVANT |
| calendar | Calendar View | RELEVANT |
| wishlist | Gift Idea Tracking | TANGENTIAL |
| notification | Local Notifications | RELEVANT |
| present | Gift Idea Tracking | RELEVANT |
| holiday | Gift occasions | TANGENTIAL |
| friends | Target audience | TANGENTIAL |
| family | Target audience | TANGENTIAL |
| party | Gift occasions | TANGENTIAL |
| age | Age calculation | RELEVANT |

## Validation History

| Run | Date | Script Result | Issues Fixed |
|-----|------|---------------|--------------|
| 1 | 2026-07-13 | Manual validation | All sections verified against code |