# Analytics & Data Collection Implementation Plan

**Date**: 2025-12-10
**Status**: 📋 Planned (Not Yet Implemented)
**Target**: First 1,000 users

---

## Overview

This document outlines the plan for implementing **anonymous, privacy-friendly analytics** to track app usage and user demographics for FoodCal. All data is stored **locally on-device** and only shared with the developer when the user explicitly consents.

---

## Goals

### Primary Goals (MVP - First 1,000 Users)

1. **Verify app stability** - Track crashes, errors, API failures
2. **Monitor API usage** - Which provider is used most (Gemini vs Qwen)?
3. **Collect demographics** - Age, gender, location for marketing insights
4. **Track feature usage** - How often users analyze food photos

### Secondary Goals (Future)

- Track nutrition data (calories, macros) per meal
- User health tracking (weight, goals)
- Meal frequency and timing patterns
- Popular foods and dietary trends

---

## What Data We Collect

### User Profile (Collected Once - First Launch)

| Field | Type | Required | Purpose |
|-------|------|----------|---------|
| `user_id` | String (UUID) | Yes | Anonymous identifier (generated locally) |
| `age` | Integer | Optional | Marketing demographics |
| `gender` | String | Optional | Marketing demographics |
| `location` | String | Optional | Region/country (auto-detected from locale or user-selected) |
| `created_at` | DateTime | Yes | When user first opened app |

**Privacy Notes:**
- `user_id` is random UUID (not linked to email/phone)
- All fields except `user_id` are **optional** - user can skip
- Location is country/region level only (e.g., "Hong Kong", not GPS coordinates)

---

### API Usage Log (Tracked Automatically)

Every time a user analyzes a food photo, save:

| Field | Type | Purpose |
|-------|------|---------|
| `id` | Integer (auto-increment) | Primary key |
| `timestamp` | DateTime | When photo was analyzed |
| `api_provider` | String | "Gemini" or "Qwen" |
| `success` | Boolean | Did API call succeed? |
| `response_time` | Float | How long API took (seconds) |
| `food_name` | String | Name of food recognized |
| `error_message` | String (optional) | If failed, what error occurred |

**Phase 2 (Future - Nutrition Data):**

Add these columns when we want nutrition tracking:

| Field | Type | Purpose |
|-------|------|---------|
| `calories` | Integer | Calories from API |
| `protein` | Integer | Protein (g) from API |
| `carbs` | Integer | Carbs (g) from API |
| `fat` | Integer | Fat (g) from API |

---

## Technical Implementation

### Phase 1: Local SQLite Tracking

**Where data lives:** SQLite database on user's device

**Files to create/modify:**

1. **`lib/data/models/analytics_log.dart`** - Data model
2. **`lib/data/services/analytics_service.dart`** - Service to save/retrieve analytics
3. **`lib/data/services/analytics_database.dart`** - SQLite database helper
4. **`lib/providers/analytics_provider.dart`** - State management for analytics
5. **`lib/screens/analytics_summary_screen.dart`** - Show user their stats (optional)
6. **`lib/screens/user_profile_setup_screen.dart`** - First-launch profile collection

**Database Schema:**

```sql
-- User Profile Table
CREATE TABLE user_profile (
  user_id TEXT PRIMARY KEY,
  age INTEGER,
  gender TEXT,
  location TEXT,
  created_at TEXT
);

-- API Usage Log Table
CREATE TABLE api_usage_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp TEXT NOT NULL,
  api_provider TEXT NOT NULL,
  success INTEGER NOT NULL,
  response_time REAL,
  food_name TEXT,
  error_message TEXT
);

-- Phase 2: Add nutrition columns (future)
ALTER TABLE api_usage_log ADD COLUMN calories INTEGER;
ALTER TABLE api_usage_log ADD COLUMN protein INTEGER;
ALTER TABLE api_usage_log ADD COLUMN carbs INTEGER;
ALTER TABLE api_usage_log ADD COLUMN fat INTEGER;
```

**Integration Points:**

Where to add tracking code:

- **User profile setup:** Show on first app launch (before camera access)
- **API call tracking:** In `lib/data/services/api_service.dart` after every `analyzeImage()` call
- **Analytics export:** Add button in Settings screen

---

## Data Export & Sharing

### Option A: Google Sheets + Apps Script (Recommended for MVP)

**Why this option:**
- ✅ Free forever
- ✅ Simplest setup (5 minutes)
- ✅ No server management
- ✅ Familiar interface (Google Sheets)

**Setup Steps:**

1. Create Google Sheet with columns: `user_id`, `age`, `gender`, `location`, `timestamp`, `api_provider`, `food_name`, `success`, `response_time`

2. Create Google Apps Script:
   - In Google Sheet: Extensions → Apps Script
   - Paste this code:

```javascript
function doPost(e) {
  try {
    var sheet = SpreadsheetApp.getActiveSheet();
    var data = JSON.parse(e.postData.contents);

    // Append user profile
    sheet.appendRow([
      data.user_id,
      data.age || 'N/A',
      data.gender || 'N/A',
      data.location || 'N/A'
    ]);

    // Append API usage logs
    data.api_logs.forEach(function(log) {
      sheet.appendRow([
        data.user_id,
        log.timestamp,
        log.api_provider,
        log.success,
        log.response_time,
        log.food_name,
        log.error_message || ''
      ]);
    });

    return ContentService.createTextOutput(JSON.stringify({status: 'success'}))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (error) {
    return ContentService.createTextOutput(JSON.stringify({status: 'error', message: error.toString()}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
```

3. Deploy as Web App:
   - Click "Deploy" → "New deployment"
   - Type: Web app
   - Execute as: Me
   - Who has access: Anyone
   - Copy URL: `https://script.google.com/macros/s/ABC123/exec`

4. Add URL to Flutter app `.env`:
```env
ANALYTICS_UPLOAD_URL=https://script.google.com/macros/s/ABC123/exec
```

**Flutter Implementation:**

```dart
// lib/data/services/analytics_uploader.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalyticsUploader {
  final String uploadUrl = dotenv.env['ANALYTICS_UPLOAD_URL']!;

  Future<bool> uploadAnalytics({
    required String userId,
    int? age,
    String? gender,
    String? location,
    required List<Map<String, dynamic>> apiLogs,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'age': age,
          'gender': gender,
          'location': location,
          'api_logs': apiLogs,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Analytics upload failed: $e');
      return false;
    }
  }
}
```

---

### Option B: Supabase (Better for Scaling)

**Why this option:**
- ✅ Free up to 50K rows/month
- ✅ Built-in dashboard and analytics
- ✅ Real-time data
- ✅ Better for 10,000+ users

**Setup Steps:**

1. Create Supabase account at supabase.com
2. Create new project
3. Create tables (SQL Editor):

```sql
CREATE TABLE user_profiles (
  user_id UUID PRIMARY KEY,
  age INTEGER,
  gender TEXT,
  location TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE api_usage_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES user_profiles(user_id),
  timestamp TIMESTAMP NOT NULL,
  api_provider TEXT NOT NULL,
  success BOOLEAN NOT NULL,
  response_time FLOAT,
  food_name TEXT,
  error_message TEXT
);
```

4. Get API credentials:
   - Settings → API
   - Copy: `URL` and `anon public key`

5. Add to Flutter `pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

6. Configure in Flutter app:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

---

### Option C: Firebase Firestore

**Why this option:**
- ✅ Good if already using Firebase
- ✅ Free up to 50K writes/day
- ✅ Google integration

**Setup Steps:**

1. Create Firebase project at firebase.google.com
2. Add Flutter app to Firebase
3. Enable Firestore Database
4. Install package: `cloud_firestore`
5. Set security rules (allow writes, admin-only reads)

---

## User Flow

### First Launch: Profile Setup

```
1. User opens app for first time
2. App shows: "Welcome to FoodCal!"
3. Show optional profile form:
   - "How old are you?" (optional number input)
   - "Gender?" (optional: Male/Female/Other/Prefer not to say)
   - "Location?" (optional: auto-detected or dropdown)
4. Show disclaimer:
   "This data helps us improve FoodCal. All data stays on your device unless you choose to share it. You can skip this."
5. User taps "Continue" or "Skip"
6. Generate random user_id (UUID)
7. Save to local SQLite database
8. Proceed to camera
```

---

### Automatic Tracking: Every Photo Analysis

```
1. User takes photo of food
2. App calls Gemini API
3. BEFORE displaying result to user:
   - Save to SQLite:
     * timestamp = now
     * api_provider = "Gemini" (or "Qwen" if fallback)
     * success = true/false
     * response_time = API latency
     * food_name = recognized food
     * error_message = (if failed)
4. Display result to user
5. User doesn't see any analytics tracking (silent background operation)
```

---

### Data Export: User-Initiated

```
Option 1: Manual Export (Settings Button)

1. User opens Settings
2. Taps "Share Usage Data"
3. App shows preview:
   "You've analyzed 45 foods using FoodCal!
   - Gemini API: 42 calls (93%)
   - Qwen API: 3 calls (7%)
   - Average response time: 2.1s

   Your profile:
   - Age: 28
   - Gender: Male
   - Location: Hong Kong

   Share this data with FoodCal to help improve the app?"
4. User taps "Share" or "Cancel"
5. If Share: Upload to Google Sheets / Supabase
6. Show: "Thank you! Data shared successfully."

Option 2: Automatic Upload (After 1 Week)

1. App tracks: 7 days since first use OR 20+ API calls
2. Show notification: "Help improve FoodCal - share your usage data?"
3. User taps notification → same flow as Option 1
```

---

## Privacy & Compliance

### GDPR Compliance

✅ **User Consent Required:** Data only shared when user explicitly taps "Share"
✅ **Transparency:** Show preview of data before upload
✅ **Right to Access:** User can view their own analytics in-app
✅ **Right to Deletion:** Provide "Delete My Data" button in settings
✅ **Minimal Data:** Only collect what's necessary (no photos, no names, no emails)

### Best Practices

- **Anonymous by default:** User ID is random UUID, not linked to identity
- **Local-first:** All data stored on device until user shares
- **Opt-in, not opt-out:** User must actively choose to share
- **Clear language:** Avoid technical jargon in consent prompts
- **Deletable:** User can delete analytics data from device anytime

---

## What You'll Learn from the Data

### Sample Insights (After 1,000 Users)

**API Performance:**
```
Total API Calls: 45,000
- Gemini: 43,200 (96% success rate)
- Qwen: 1,800 (4% fallback rate)
- Average response time: 2.1s
```

**Demographics:**
```
Age Distribution:
- 18-25: 25%
- 26-35: 40%
- 36-45: 20%
- 46+: 15%

Gender:
- Male: 45%
- Female: 50%
- Other/Prefer not to say: 5%

Location:
- Hong Kong: 35%
- Singapore: 25%
- Taiwan: 15%
- Others: 25%
```

**Usage Patterns:**
```
Average photos per user: 45
Most analyzed foods:
1. Chicken Rice (2,300 times)
2. Salad (1,800 times)
3. Pasta (1,500 times)

Peak usage times:
- Lunch: 12pm-2pm (40%)
- Dinner: 6pm-8pm (35%)
- Other: 25%
```

---

## Implementation Checklist

### Phase 1: Local Tracking (Week 1-2)

- [ ] Create `analytics_log.dart` data model
- [ ] Create `analytics_database.dart` SQLite helper
- [ ] Create `analytics_service.dart` business logic
- [ ] Create `user_profile_setup_screen.dart` UI
- [ ] Add tracking to `api_service.dart` after every API call
- [ ] Test: Verify data saves to SQLite correctly
- [ ] Test: Verify profile setup flow works

### Phase 2: Export Feature (Week 3)

- [ ] Set up Google Sheet + Apps Script (OR Supabase)
- [ ] Create `analytics_uploader.dart` service
- [ ] Add "Share Usage Data" button to Settings screen
- [ ] Add export preview dialog
- [ ] Test: Upload to Google Sheets works
- [ ] Test: Handle upload failures gracefully

### Phase 3: Polish & Testing (Week 4)

- [ ] Add analytics summary screen (optional - show user their stats)
- [ ] Add "Delete Analytics Data" button in settings
- [ ] Test on real devices (iOS + Android)
- [ ] Test privacy: Verify no data leaks without user consent
- [ ] Write unit tests for analytics service
- [ ] Update app privacy policy

---

## Future Enhancements

### Phase 4: Nutrition Tracking (Later)

- Add columns: `calories`, `protein`, `carbs`, `fat` to SQLite
- Track nutrition data for each API call
- Enable insights: "Users eat avg 1,400 cal/day"

### Phase 5: Health Tracking (Much Later)

- Add user weight, goal weight
- Track weight progress over time
- Show trends: "You've lost 5kg in 2 months!"

### Phase 6: Real-Time Dashboard (If Scale to 10K+ Users)

- Migrate to Supabase for better analytics
- Build admin dashboard (web app)
- Real-time monitoring: "50 users active right now"
- Crash reporting integration (Sentry or Firebase Crashlytics)

---

## Cost Analysis

| Solution | Setup Time | Monthly Cost | Best For |
|----------|-----------|--------------|----------|
| **Google Sheets + Apps Script** | 5 mins | $0 | First 1,000 users (MVP) |
| **Supabase** | 30 mins | $0 (free tier) → $25 (pro) | 1,000-100,000 users |
| **Firebase Firestore** | 30 mins | $0 (free tier) → pay-as-you-go | If already using Firebase |

**Recommendation:** Start with Google Sheets, migrate to Supabase when you hit 10,000 users.

---

## Questions to Answer Before Implementation

1. **Profile setup required or optional?**
   - Recommended: **Optional** (higher completion rate)

2. **When to prompt user to share data?**
   - Recommended: After **1 week or 20 API calls**

3. **Location granularity?**
   - Recommended: **Country/region only** (e.g., "Hong Kong")
   - Auto-detect from device locale

4. **Should users see their own stats?**
   - Recommended: **Yes** - adds value, builds trust
   - Example: "You've analyzed 45 foods this month!"

5. **Export method?**
   - Recommended: **Google Sheets** for MVP

---

## Next Steps

When you're ready to implement:

1. Review this document
2. Answer the questions above
3. Choose export method (Google Sheets recommended)
4. Follow Phase 1 implementation checklist
5. Test thoroughly on real devices
6. Deploy to first 100 beta users
7. Collect feedback and iterate

---

**Document Status:** Ready for implementation
**Last Updated:** 2025-12-10
**Author:** Claude (AI Assistant)
