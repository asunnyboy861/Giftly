# Giftly — 配置文档

生成时间：2026-07-06

---

## 一、⚠️ 手动配置（增强功能 — 不配置不影响基本使用）

> **重要说明**：以下配置项均为**增强功能或上架必需项**。App 核心功能（生日提醒、礼物追踪、AI建议、IAP购买流程）已全部自动配置完成，下载后即可正常使用。以下为上架前需手动完成的步骤。

### 🔵 IAP StoreKit 配置（⚠️ 上架必需 — 不配置无法完成内购）

**影响功能**：不创建IAP产品则用户无法完成Pro Unlock和AI Advanced的购买
**当前状态**：StoreKit 2代码已就绪（PurchaseService.swift），本地测试用 Giftly.storekit 已创建，仅缺App Store Connect产品

**配置步骤**：
1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入 **My Apps** → **Giftly** → **Monetization** → **In-App Purchases**
3. 点击 **"+"** 创建两个非消耗型（Non-Consumable）产品：

| 产品 | Reference Name | Product ID | 价格 | Description |
|------|---------------|-----------|------|-------------|
| Pro Unlock | Giftly Pro Unlock | `com.zzoutuo.Giftly.prounlock` | $4.99 USD | Unlimited birthdays, import, reminders, widgets |
| AI Advanced | Giftly AI Advanced | `com.zzoutuo.Giftly.aiunlock` | $5.99 USD | AI gift ideas, gift history, budget tracking |

4. 每个产品填写：
   - **Display Name**: Giftly Pro Unlock / Giftly AI Advanced（≤35字符 ✅）
   - **Description**: 从 price.md 复制（≤55字符 ✅）
   - **Pricing**: 选择对应价格层级
   - **Review Screenshot**: 截图PaywallView（需在模拟器截取）
   - **Review Notes**: 注明StoreKit Configuration文件已包含在项目中用于本地测试
5. ⚠️ 创建后需要等待Apple审核（通常1-2小时）
6. 在Xcode中验证：Edit Scheme → Run → Options → StoreKit Configuration → 选择 `Giftly.storekit`
7. 在模拟器中点击 Settings → "Unlock Pro" / "Unlock AI" 验证购买流程
8. 点击 Settings → "Restore Purchases" 验证恢复购买

---

### 🟢 App Store Connect 审核信息配置（⚠️ 上架必需 — AI功能必备）

**影响功能**：不配置则Apple审核员无法测试AI功能，导致 Guideline 2.1(a) 拒绝
**当前状态**：app_review_info.md 已生成，包含完整审核说明

**配置步骤**：
1. 在 App Store Connect → Giftly → **App Review Information**
2. 在 **Demo Account** 字段中，注明：
   - 本App使用BYO Key模式，无需Demo账户
   - 免费版本可立即测试（最多5个生日联系人）
   - IAP测试请使用Sandbox Tester账户
3. 在 **Notes** 字段中，粘贴 `app_review_info.md` 中的完整内容（位于项目根目录）
4. ⚠️ **AI功能测试关键说明**（必须包含在Notes中）：
   - 本App使用Bring Your Own API Key模式
   - 审核员需购买AI Advanced ($5.99 IAP) 后，在Settings输入一个兼容ChatCompletions格式的API Key
   - API Key存储在iOS Keychain，永不离开设备
   - 无免费生成次数限制 — 用户添加自己的Key后可无限次生成
5. ⚠️ 确保 **Privacy Policy URL** 字段填写：`https://asunnyboy861.github.io/Giftly/privacy.html`
6. ⚠️ 确保 **Terms of Use URL** 字段填写（EULA字段）：`https://asunnyboy861.github.io/Giftly/terms.html`

**`app_review_info.md` 位置**：项目根目录，由 PHASE 4+5 自动生成

---

### 🟡 Capabilities 增强配置（可选 — 不配置不影响核心功能）

#### WidgetKit Extension — 主屏幕小组件（可选增强）

**增强功能**：配置后用户可在主屏幕添加Giftly小组件，显示下一个即将到来的生日
**不配置的影响**：App核心功能完全正常，仅缺少主屏幕小组件这一增强功能
**当前状态**：App核心功能（生日提醒、礼物追踪、AI建议、IAP）全部就绪，无需Widget即可正常使用

**已自动配置部分**：
- ✅ SwiftData @Model 已定义（Person, GiftIdea, GiftHistory）
- ✅ App代码已使用 SwiftData 本地存储（无需共享容器即可工作）
- ✅ 优雅降级已实现 — 无Widget时App完全可用

**如需启用Widget增强功能，请手动配置**：
1. 打开 Xcode → Giftly 项目
2. File → New → Target → **Widget Extension**
3. 名称填写：`GiftlyWidget`
4. Bundle ID 设置为：`com.zzoutuo.Giftly.GiftlyWidget`
5. Embed in Application: 选择 Giftly
6. ⚠️ Widget代码需手动编写（TimelineProvider读取SwiftData）
7. ⚠️ 配置完成后需要重新 Build 验证

#### App Groups — 共享容器（可选，仅Widget需要）

**增强功能**：为Widget Extension提供共享SwiftData容器
**不配置的影响**：仅Widget无法读取App数据，App本体完全正常
**当前状态**：App使用本地SwiftData存储，无需共享容器

**如需启用（仅当配置了Widget时）**：
1. 打开 Xcode → Giftly → **Signing & Capabilities**
2. 点击 **+ Capability** → 选择 **App Groups**
3. 添加 group：`group.com.zzoutuo.Giftly`
4. 在Widget Extension target中也添加相同的App Group
5. ⚠️ 修改SwiftData ModelContainer配置使用共享容器URL
6. ⚠️ 配置完成后需要重新 Build 验证

---

## 二、✅ 自动配置记录（已由系统完成，无需操作）

### Capabilities 自动配置

| Capability | 说明 | 状态 |
|------------|------|------|
| Contacts Framework | 已通过 `INFOPLIST_KEY_NSContactsUsageDescription` 配置（Debug+Release） | ✅ 已配置 |
| UserNotifications | 运行时权限请求，无需entitlement | ✅ 已配置 |
| StoreKit 2 | 框架自动链接（`import StoreKit`），IAP代码就绪 | ✅ 已配置 |
| Keychain (Security) | 框架自动链接，API Key存储就绪 | ✅ 已配置 |
| SwiftData | iOS 17+框架，`import SwiftData` 即可 | ✅ 已配置 |
| Outgoing Network Connections | AI建议和客服反馈需要，已配置 | ✅ 已配置 |

### 资源配置

| 资源 | 说明 | 状态 |
|------|------|------|
| App Icon | 1024x1024 通过Agnes Image API生成，已加入AppIcon.appiconset | ✅ 已配置 |
| Brand Colors | GiftlyPurple (#7B68EE), GiftlyCoral (#FF6B9D), GiftlyMint (#4ECDC4) 已加入Asset Catalog | ✅ 已配置 |
| AccentColor | 已配置 | ✅ 已配置 |
| PrivacyInfo.xcprivacy | 隐私清单已创建（UserDefaults, FileTimestamp声明） | ✅ 已配置 |
| StoreKit Configuration | Giftly.storekit 本地测试文件已创建（2个非消耗型产品） | ✅ 已配置 |

### 后端服务

| 服务 | 说明 | 状态 |
|------|------|------|
| 联系客服后端 | Cloudflare Workers 部署，地址：`https://feedback-board.iocompile67692.workers.dev` | ✅ 已部署 |
| 后端URL代码集成 | ContactSupportView.swift 中已硬编码后端URL | ✅ 已完成 |
| NSAppTransportSecurity | 允许HTTPS出站连接，已在Info.plist配置 | ✅ 已配置 |

### 政策页面部署

| 页面 | URL | 状态 |
|------|-----|------|
| Landing Page | https://asunnyboy861.github.io/Giftly/ | ✅ 已部署 |
| Support | https://asunnyboy861.github.io/Giftly/support.html | ✅ 已部署 |
| Privacy Policy | https://asunnyboy861.github.io/Giftly/privacy.html | ✅ 已部署 |
| Terms of Use | https://asunnyboy861.github.io/Giftly/terms.html | ✅ 已部署 |

政策页面URL已集成到AppViewModel.swift中（supportURL/privacyPolicyURL/termsOfUseURL方法）。

### 代码生成

| 模块 | 说明 | 状态 |
|------|------|------|
| Models | Person, GiftIdea, GiftHistory, GiftStatus (SwiftData @Model) | ✅ 已完成 |
| Services | KeychainHelper, ContactImportService, NotificationService, PurchaseService, GiftAIService, DataExportService | ✅ 已完成 |
| ViewModels | PersonViewModel, GiftViewModel, AppViewModel (@Observable) | ✅ 已完成 |
| Views | ContentView, OnboardingView, BirthdayCardView, CalendarView, AddPersonView, PersonDetailView, GiftIdeaListView, GiftSuggestionView, PaywallView, SettingsView, ContactSupportView, EmptyStateView | ✅ 已完成 |
| MVVM架构 | @Observable ViewModels + ObservableObject PurchaseService (IAP合规) | ✅ 已完成 |
| StoreKit 2 | PurchaseService.swift 实现完整IAP流程（购买/恢复/监听） | ✅ 已完成 |
| AI Module | GiftAIService.swift (BYO Key, KeychainHelper, 自定义baseURL/model) | ✅ 已完成 |
| 隐私合规 | 13项ios-custom-ai-config检查全部通过 | ✅ 已完成 |
| 中国合规 | 用户界面无"OpenAI"/"ChatGPT"引用 | ✅ 已完成 |
| QA迭代 | improvement_plan_1.md (8.9/10评分，23/23功能实现) | ✅ 已完成 |

### 💡 使用提示（非开发者配置，App内操作即可）

**AI 功能**：App 已内置 AI 配置界面，用户下载后在 **Settings → API Key** 中输入自己的兼容ChatCompletions格式的API Key即可使用。支持自定义Base URL和模型名称，可用于任何兼容提供商。这不是开发者配置步骤，用户按需在 App 内操作即可。API Key存储在iOS Keychain中，永不离开设备。

### 部署

| 项目 | 说明 | 状态 |
|------|------|------|
| GitHub仓库 | 代码已推送至 https://github.com/asunnyboy861/Giftly | ✅ 已完成 |
| GitHub Pages | 政策页面已部署，GitHub Actions自动构建 | ✅ 已完成 |
| Landing Page | 已部署（App Store ID为占位符，需上架后更新） | ✅ 已完成 |
| App Store元数据 | keytext.md 已生成并通过13项验证 | ✅ 已完成 |
| 定价配置 | price.md 已生成（Freemium + 2个非消耗型IAP） | ✅ 已完成 |
| App Review信息 | app_review_info.md 已生成 | ✅ 已完成 |

---

## 三、能力检测详情

> 以下为 PHASE 2 原始检测数据。

### Analysis

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

### NSContactsUsageDescription

Added to Info.plist via build settings:
```
"Giftly needs access to your contacts to import birthdays. We only read names, birthdays, and photos — never phone numbers, emails, or addresses."
```

### Privacy Manifest (PrivacyInfo.xcprivacy)

Created in PHASE 4+5. Declares:
- NSPrivacyAccessedAPICategoryUserDefaults (CA92.1)
- NSPrivacyAccessedAPICategoryFileTimestamp (DDA9.2)
- NSPrivacyTracking = false

### No Configuration Needed

- **iCloud**: App is local-first, no CloudKit needed
- **Push Notifications (remote)**: App uses local notifications only
- **HealthKit**: Not applicable
- **Location Services**: Not applicable
- **Camera**: Uses PhotosPicker (no camera permission needed)
- **App Tracking Transparency**: App does NOT track users
- **Sign in with Apple**: No account system — app is accountless
- **Siri**: Not in MVP
- **Apple Watch**: Not in MVP (planned for v1.2)

### Verification

- Build succeeded on iPhone 16 and iPad Pro 13-inch (M5) simulators: ✅ (zero warnings)
- All entitlements correct: ✅ (NSContactsUsageDescription added)
- App Icon configured: ✅ (1024x1024 in AppIcon.appiconset)
- Brand colors configured: ✅ (3 colorsets in Asset Catalog)
- StoreKit Configuration: ✅ (Giftly.storekit with 2 non-consumable products)
- 13 ios-custom-ai-config compliance checks: ✅ All passed
- 13 keytext validation checks: ✅ All passed
