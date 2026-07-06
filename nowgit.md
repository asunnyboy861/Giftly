# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | Giftly |
| **Git URL** | git@github.com:asunnyboy861/Giftly.git |
| **Repo URL** | https://github.com/asunnyboy861/Giftly |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/Giftly/ | ✅ Active |
| Support | https://asunnyboy861.github.io/Giftly/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/Giftly/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/Giftly/terms.html | ✅ Active |

## Repository Structure

```
Giftly/
├── Giftly/                        # iOS App Source Code
│   ├── Giftly.xcodeproj/          # Xcode Project
│   ├── Giftly/                    # Swift Source Files
│   │   ├── GiftlyApp.swift        # App entry point
│   │   ├── Models/                # SwiftData models
│   │   │   ├── Person.swift
│   │   │   ├── GiftIdea.swift
│   │   │   ├── GiftHistory.swift
│   │   │   └── GiftStatus.swift
│   │   ├── Services/              # Business logic
│   │   │   ├── KeychainHelper.swift
│   │   │   ├── ContactImportService.swift
│   │   │   ├── NotificationService.swift
│   │   │   ├── PurchaseService.swift
│   │   │   ├── GiftAIService.swift
│   │   │   └── DataExportService.swift
│   │   ├── ViewModels/            # MVVM ViewModels
│   │   │   ├── PersonViewModel.swift
│   │   │   ├── GiftViewModel.swift
│   │   │   └── AppViewModel.swift
│   │   ├── Views/                  # SwiftUI Views
│   │   │   ├── ContentView.swift
│   │   │   ├── OnboardingView.swift
│   │   │   ├── BirthdayCardView.swift
│   │   │   ├── CalendarView.swift
│   │   │   ├── PersonDetailView.swift
│   │   │   ├── AddPersonView.swift
│   │   │   ├── GiftIdeaListView.swift
│   │   │   ├── GiftSuggestionView.swift
│   │   │   ├── PaywallView.swift
│   │   │   ├── SettingsView.swift
│   │   │   ├── ContactSupportView.swift
│   │   │   └── EmptyStateView.swift
│   │   ├── Assets.xcassets/       # App icon & colors
│   │   └── PrivacyInfo.xcprivacy  # Privacy manifest
├── docs/                          # Policy Pages (GitHub Pages source)
│   ├── index.html
│   ├── support.html
│   ├── privacy.html
│   └── terms.html
├── .github/workflows/
│   └── deploy.yml
├── us.md                          # Development guide
├── capabilities.md                # Capabilities documentation
├── icon.md                        # App icon documentation
├── price.md                       # Pricing configuration
├── app_review_info.md             # App Store review notes
├── improvement_plan_1.md           # QA scorecard
├── nowgit.md                      # This file
├── Giftly.storekit                # StoreKit configuration for testing
├── keytext.md                     # ⚠️ EXCLUDED from repo (.gitignore)
└── COMPETITOR_REPORT.md           # ⚠️ EXCLUDED from repo (.gitignore)
```

## Build Status

| Device | Build | Run Test |
|--------|-------|----------|
| iPhone 16 (iOS 26.4) | ✅ Succeeded | ✅ Launched |
| iPad Pro 13-inch (M5) | ✅ Succeeded | ✅ Launched |
