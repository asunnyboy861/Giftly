# Capabilities Configuration

## Analysis

Based on operation guide analysis, the following capabilities are required:

| Requirement | Keyword Found | Capability |
|-------------|---------------|------------|
| "通讯录导入" / "Contacts" | Contact import feature | Contacts Framework |
| "通知" / "notification" / "提醒" | 3-tier birthday reminders | UserNotifications |
| "购买" / "内购" / "IAP" | $4.99 + $5.99 one-time purchases | StoreKit 2 / In-App Purchase |
| "Keychain" / "API Key" | BYO OpenAI API key storage | Keychain (Security framework) |
| "小组件" / "Widget" | Home screen widget | WidgetKit Extension |
| "SwiftData" / "本地存储" | Local data storage | SwiftData (iOS 17+) |
| "App Groups" | Shared container for widget | App Groups |

## Auto-Configured Capabilities

| Capability | Status | Method |
|------------|--------|--------|
| Contacts Framework | ✅ Configured | `INFOPLIST_KEY_NSContactsUsageDescription` added to build settings (Debug + Release) |
| UserNotifications | ✅ Configured | No entitlement needed — runtime permission request in code |
| StoreKit 2 | ✅ Configured | Framework auto-linked when `import StoreKit` is used; IAP capability enabled via code |
| Keychain (Security) | ✅ Configured | No entitlement needed — `Security` framework auto-linked |
| SwiftData | ✅ Configured | iOS 17+ framework — no capability needed, just `import SwiftData` |
| Brand Colors | ✅ Configured | GiftlyPurple, GiftlyCoral, GiftlyMint colorsets added to Asset Catalog |
| App Icon | ✅ Configured | 1024x1024 icon generated via Agnes Image API and added to AppIcon.appiconset |

## Manual Configuration Required

| Capability | Status | Steps |
|------------|--------|-------|
| WidgetKit Extension | ⏳ Pending | 1. Open Xcode → File → New → Target → Widget Extension. 2. Name it "GiftlyWidget". 3. Set Bundle ID to `com.zzoutuo.Giftly.GiftlyWidget`. 4. Configure WidgetKit timeline provider. |
| App Groups | ⏳ Pending | 1. Open Xcode → Signing & Capabilities → + Capability → App Groups. 2. Add group `group.com.zzoutuo.Giftly`. 3. Required for shared SwiftData container between app and widget. |
| In-App Purchase (App Store Connect) | ⏳ Pending | 1. Sign in to App Store Connect → My Apps → Giftly → In-App Purchases. 2. Create Non-Consumable: `com.zzoutuo.Giftly.prounlock` ($4.99). 3. Create Non-Consumable: `com.zzoutuo.Giftly.aiunlock` ($5.99). 4. Add localized descriptions and screenshots. |

**Note**: The app works fully without the Widget Extension and App Groups — these are enhancement features for the home screen widget. The core app (birthday reminders, gift tracking, AI suggestions, IAP) works without them.

## NSContactsUsageDescription

Added to Info.plist via build settings:
```
"Giftly needs access to your contacts to import birthdays. We only read names, birthdays, and photos — never phone numbers, emails, or addresses."
```

## Privacy Manifest (PrivacyInfo.xcprivacy)

**Status**: ⏳ To be created in PHASE 4+5 (code generation)

The privacy manifest will declare:
- SwiftData: file timestamp API (C617.1)
- Contacts: contact info persistence
- UserNotifications: no PII collected
- StoreKit: purchase history (not shared)

## No Configuration Needed

- **iCloud**: App is local-first, no CloudKit needed
- **Push Notifications (remote)**: App uses local notifications only
- **HealthKit**: Not applicable
- **Location Services**: Not applicable
- **Camera**: Uses PhotosPicker (no camera permission needed)
- **App Tracking Transparency**: App does NOT track users
- **Sign in with Apple**: No account system — app is accountless
- **Siri**: Not in MVP
- **Apple Watch**: Not in MVP (planned for v1.2)

## Verification

- Build succeeded after configuration: ⏳ Pending (will verify after PHASE 4+5 code generation)
- All entitlements correct: ✅ (NSContactsUsageDescription added)
- App Icon configured: ✅ (1024x1024 in AppIcon.appiconset)
- Brand colors configured: ✅ (3 colorsets in Asset Catalog)
