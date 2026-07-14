# Giftly — Physical Device Screen Recording Guide

> Apple requires: "A screen recording captured on a physical device, running the latest operating system, demonstrating the app's functionality. The recording must begin with launching the app and show the typical user flow through its core features."

## Prerequisites

- Physical iPhone running iOS 17.0 or later (latest iOS recommended)
- Giftly installed on the device (via TestFlight or Xcode install)
- At least 3-5 contacts with birthdays in your Contacts app (for the import demo)

## Step 1: Enable Screen Recording in Control Center

1. Open **Settings** → **Control Center**
2. Tap the **+** next to **Screen Recording**
3. Verify Screen Recording now appears in Control Center

## Step 2: Prepare the Device

1. **Close all apps** — swipe up from the bottom and close everything
2. **Ensure Giftly is on the Home screen** for a clean launch
3. **Set brightness to a comfortable level** (60-80%)
4. **Turn on Do Not Disturb** to prevent notifications during recording

## Step 3: Record the Screen

1. **Open Control Center** (swipe down from top-right on notch devices, or up from bottom on Home button devices)
2. **Long-press the Screen Recording button** (circle icon)
3. **Tap "Start Recording"** — a 3-second countdown begins
4. **Wait for the countdown**, then the status bar turns red

## Step 4: Demonstrate the Full User Flow

Follow this script exactly. Each step should take 3-5 seconds. Total recording: ~2-3 minutes.

### Part A: Launch & Onboarding (if first launch)

| Step | Action | What to Show |
|------|--------|-------------|
| 1 | Tap the **Giftly icon** on the Home screen | App launching (cold start) |
| 2 | Swipe through the **3 onboarding pages** | "Never Forget a Birthday", "Plan Gifts with AI", "Smart Reminders" |
| 3 | Tap **"Import Birthdays"** | Import page with privacy note |
| 4 | Tap **"Import from Contacts"** | **Contacts permission prompt** — tap "Allow" |
| 5 | Tap **"Let's Go!"** on the success alert | Birthdays imported, onboarding complete |
| 6 | **Notification permission prompt** appears — tap "Allow" | Notifications enabled |

> If onboarding was already completed: skip to Part B. To reset onboarding, delete and reinstall the app.

### Part B: Home Screen with Data

| Step | Action | What to Show |
|------|--------|-------------|
| 7 | View the **Home tab** | Birthday cards with names, photos, countdown days |
| 8 | Point out **today's birthday** (if any) with pink border | Highlight the today indicator |
| 9 | Scroll through the **upcoming birthdays list** | Multiple cards with different dates |

### Part C: Add a Person Manually

| Step | Action | What to Show |
|------|--------|-------------|
| 10 | Tap the **"+" button** (top-right) | Add Person sheet opens |
| 11 | Type a name (e.g., "Sarah Johnson") | Name field filling |
| 12 | Tap **Birthday** and select a date | Date picker in action |
| 13 | Tap **Photo** and select a photo | PhotosPicker opens (no permission needed) |
| 14 | Enter **Relationship** (e.g., "Sister") | Relationship field |
| 15 | Enter **Interests** (e.g., "Reading, Yoga, Cooking") | Interests field |
| 16 | Tap **Save** | Person added to list with confetti animation |

### Part D: Person Detail & Gift Ideas

| Step | Action | What to Show |
|------|--------|-------------|
| 17 | Tap a **birthday card** to open Person Detail | Detail view: age, zodiac, interests |
| 18 | Scroll to **Gift Ideas** section | Gift idea list (empty or with ideas) |
| 19 | Tap **"Add Gift Idea"** | Gift idea entry sheet |
| 20 | Type a gift name (e.g., "Yoga Mat") | Gift idea field |
| 21 | Tap **Save** | Gift idea added with "Idea" status |
| 22 | Tap the **status button** on the gift idea | Status changes: Idea → Planned → Purchased → Given |
| 23 | Scroll to **Gift History** section | Gift history (may be empty if first gift) |

### Part E: Calendar Tab

| Step | Action | What to Show |
|------|--------|-------------|
| 24 | Tap the **Calendar tab** (bottom bar) | All birthdays grouped by month |
| 25 | Scroll through months | Multiple months with birthdays |
| 26 | Tap a **month header** to expand/collapse | Collapsible month sections |

### Part F: Settings & Paywall (IAP Flow)

| Step | Action | What to Show |
|------|--------|-------------|
| 27 | Tap the **Settings tab** (bottom bar) | Settings form: Purchases, AI Provider, Notifications, Legal, About |
| 28 | Tap **"Upgrade to Giftly Pro"** | **Paywall opens** — shows both products with prices |
| 29 | Point out **"No subscriptions. Ever."** text | Non-subscription model |
| 30 | Point out **Privacy Policy** and **Terms of Use** links | Legal links present |
| 31 | Tap **"Restore Purchases"** | Restore button works |
| 32 | Tap a **purchase button** (e.g., "$4.99") | **Apple purchase sheet** appears (Sandbox) |
| 33 | Cancel the purchase | Purchase sheet dismissed |

### Part G: AI Suggestions (Optional, requires iOS 26+ with Apple Intelligence)

| Step | Action | What to Show |
|------|--------|-------------|
| 34 | Go to a **Person Detail** → tap **"AI Ideas"** | AI suggestion screen |
| 35 | Set a budget range and tap **"Generate Ideas"** | AI generating (loading) → gift suggestions appear on-device |
| 36 | Tap **"Add as Idea"** on one suggestion | Suggestion saved to gift ideas |

> If Apple Intelligence is unavailable: Show the "Apple Intelligence Required" guidance state (NOT an error).

### Part H: Settings Features

| Step | Action | What to Show |
|------|--------|-------------|
| 39 | Tap **"Privacy Policy"** | Opens policy page in browser |
| 40 | Tap **"Terms of Use"** | Opens terms page in browser |
| 41 | Tap **"Contact Support"** | Opens support form |
| 42 | Tap **"Export Backup"** | Shows share sheet with JSON file |
| 43 | Point out **app version** in About section | Version info |

### Part I: Stop Recording

| Step | Action |
|------|--------|
| 44 | Open **Control Center** |
| 45 | Tap the **red Screen Recording button** (or red status bar) |
| 46 | Tap **"Stop"** |
| 47 | The recording is saved to **Photos** → **Screen Recordings** |

## Step 5: Verify the Recording

1. Open **Photos** app → **Screen Recordings** album
2. Play the recording to verify:
   - Audio is clear (if you narrated)
   - All permission prompts are visible (Notifications, Contacts)
   - The IAP/purchase flow is shown
   - No crashes or bugs occurred
3. Trim unnecessary parts (beginning/end) if needed

## Step 6: Attach to App Store Connect

1. Go to **App Store Connect** → your app → the submission
2. In the **Review Information** section, find the **Notes** field
3. Paste the content from `app_review_info.md`
4. Upload the screen recording as an attachment (if App Store Connect supports video attachment in the reply)
5. If video attachment is not available:
   - Upload the recording to a cloud service (Google Drive, Dropbox)
   - Add a shared link in the Notes field
   - Or: Reply to the review message and attach the video there

## Key Points to Remember

- **Physical device required** — Apple explicitly states "captured on a physical device"
- **Latest iOS** — update your iPhone to the latest iOS version before recording
- **Show permission prompts** — Notifications and Contacts permission dialogs must appear in the recording
- **Show IAP flow** — The Apple purchase sheet (even in Sandbox) must be visible
- **No account flows** — Giftly has NO account registration/login/deletion. This is normal — just note it in the review notes
- **Smooth flow** — Practice the flow 2-3 times before recording the final version
- **Duration** — Keep it under 3 minutes; Apple reviewers have limited time

## Troubleshooting

| Issue | Solution |
|-------|---------|
| Screen Recording not in Control Center | Settings → Control Center → add Screen Recording |
| Recording has no audio | Long-press Screen Recording → turn on Microphone |
| App crashes during recording | Report the crash, fix the bug, re-record |
| Permission prompts don't appear | Delete and reinstall the app to reset permissions |
| IAP products don't load | Sign into Sandbox account: Settings → App Store → Sandbox Account |
| Recording is too large | Use QuickTime or iMovie to compress, or record at lower quality |
