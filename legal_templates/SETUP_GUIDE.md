# Legal Documents Setup Guide

This guide will help you set up Privacy Policy and Terms of Service for your food tracking app.

## ✅ What We've Done

We've created:
1. ✅ **App Integration** - Settings page now has Privacy Policy & Terms of Service links
2. ✅ **Legal Templates** - Ready-to-customize HTML documents
3. ✅ **Localization** - Support for English, Chinese (Simplified & Traditional)

## 📝 Step 1: Customize the Legal Documents

### Files to Edit:
- `legal_templates/privacy_policy.html`
- `legal_templates/terms_of_service.html`

### What to Replace (marked with `[BRACKETS]`):

| Placeholder | Replace With | Example |
|------------|--------------|---------|
| `[YOUR APP NAME]` | Your app name | "OptiMate" or "FoodCal" |
| `[DATE]` | Today's date | "December 20, 2025" |
| `[YOUR CONTACT EMAIL]` | Your support email | "support@yourapp.com" |
| `[YOUR COMPANY/NAME]` | Your name/company | "OptiMate Inc." or "John Smith" |
| `[YEAR]` | Current year | "2025" |
| `[YOUR COUNTRY/STATE]` | Your jurisdiction | "United States" or "California, USA" |

### Important Decisions to Make:

#### Privacy Policy:

1. **Data Storage** (Line ~90):
   - Choose: "stored locally on your device" or "uploaded to our servers for AI analysis"
   - If using Google Vertex AI, choose "uploaded"

2. **AI Service** (Line ~65):
   - If using Google Vertex AI: "We use Google Vertex AI to analyze food photos"
   - Add link: https://cloud.google.com/privacy
   - If not using AI: Remove this section

3. **Cloud Backup** (Line ~98):
   - If you sync data: "Some data may be stored in the cloud for backup and sync purposes"
   - If local only: "All data is stored locally on your device"

4. **Data Deletion** (Line ~108):
   - If no account system: "You can delete all data by uninstalling the app"
   - If you add accounts: "You can delete all data using the Delete Account feature in Settings"

#### Terms of Service:

1. **Cloud Storage** (Line ~37):
   - Add if you use cloud: "and in our secure cloud servers"
   - Remove if local only

2. **Dispute Resolution** (Line ~136):
   - Choose: "binding arbitration" or "the courts of YOUR JURISDICTION"
   - Consult a lawyer if unsure

3. **Free vs Paid** (Line ~120):
   - Keep section if app is free
   - Modify if you plan to charge

## 📤 Step 2: Host on GitHub Pages (FREE)

### Option A: Use Your Personal GitHub Account

1. **Create a new repository:**
   ```bash
   # Go to GitHub.com and create a new public repository named:
   food-cal-legal
   # or
   optimate-legal
   ```

2. **Upload your files:**
   ```bash
   cd /Users/simonho/development/projects/food_cal/legal_templates
   git init
   git add privacy_policy.html terms_of_service.html
   git commit -m "Add legal documents"
   git branch -M main
   git remote add origin https://github.com/YOUR-USERNAME/food-cal-legal.git
   git push -u origin main
   ```

3. **Enable GitHub Pages:**
   - Go to repository Settings
   - Scroll to "Pages" section
   - Source: Select "main" branch
   - Folder: Select "/ (root)"
   - Click "Save"

4. **Your URLs will be:**
   ```
   https://YOUR-USERNAME.github.io/food-cal-legal/privacy_policy.html
   https://YOUR-USERNAME.github.io/food-cal-legal/terms_of_service.html
   ```

### Option B: Create Company GitHub Account (More Professional)

1. Create new GitHub account with email like: legal@yourapp.com or info@yourapp.com
2. Username: `optimate-app` or `foodcal-app`
3. Follow same steps as Option A
4. URLs: `https://optimate-app.github.io/legal/privacy_policy.html`

## 🔗 Step 3: Update App URLs

Once your documents are hosted:

1. **Open file:**
   ```
   lib/widgets/settings/legal_documents_widget.dart
   ```

2. **Replace URLs on lines 14-15:**
   ```dart
   // OLD:
   static const String privacyPolicyUrl = 'https://YOUR-USERNAME.github.io/YOUR-REPO/privacy.html';
   static const String termsOfServiceUrl = 'https://YOUR-USERNAME.github.io/YOUR-REPO/terms.html';

   // NEW (example):
   static const String privacyPolicyUrl = 'https://yourusername.github.io/food-cal-legal/privacy_policy.html';
   static const String termsOfServiceUrl = 'https://yourusername.github.io/food-cal-legal/terms_of_service.html';
   ```

## ▶️ Step 4: Install Dependencies & Test

```bash
# Install the url_launcher package
flutter pub get

# Generate localization files
flutter gen-l10n

# Run the app
flutter run

# Test the links:
# 1. Go to Settings page
# 2. Scroll to bottom
# 3. Tap "Privacy Policy" - should open in browser
# 4. Tap "Terms of Service" - should open in browser
```

## 📱 Step 5: App Store Requirements

### Apple App Store:
- ✅ Add Privacy Policy URL in App Store Connect
- ✅ Fill out "App Privacy" questionnaire
- ✅ Declare data collection practices

### Google Play Store:
- ✅ Add Privacy Policy URL in Play Console
- ✅ Complete Data Safety form
- ✅ Declare permissions and data usage

### Both Stores Need:
- Valid, accessible Privacy Policy URL
- Contact email for legal/privacy inquiries

## ⚠️ Important Notes

### Legal Disclaimer:
- ✅ These templates are based on common practices
- ✅ They cover basic food tracking app scenarios
- ⚠️ **NOT legal advice** - consult a lawyer for:
  - Complex health data handling
  - Selling user data
  - Accepting payments
  - Operating in multiple countries

### What's Covered:
- ✅ Basic data collection (food logs, weight, photos)
- ✅ AI analysis disclosure
- ✅ Local storage
- ✅ GDPR/CCPA basics
- ✅ Medical disclaimer

### Regular Updates:
- Update dates when you make changes
- Notify users of material changes
- Keep a version history

## 🔄 Updating Legal Documents

When you need to update:

1. Edit the HTML files on your computer
2. Commit and push to GitHub:
   ```bash
   git add privacy_policy.html terms_of_service.html
   git commit -m "Update legal documents"
   git push
   ```
3. Changes appear on GitHub Pages within ~1 minute
4. No app update needed!

## ✨ That's It!

Your app now has:
- ✅ Professional legal documents
- ✅ Compliant with app store requirements
- ✅ Free hosting on GitHub Pages
- ✅ Easy to update anytime
- ✅ Multi-language support in the app

## 🆘 Troubleshooting

### Links don't open?
- Check internet connection
- Verify URLs are correct in `legal_documents_widget.dart`
- Make sure GitHub Pages is enabled

### 404 Error?
- Wait 1-2 minutes for GitHub Pages to deploy
- Check file names match exactly (case-sensitive)
- Verify repository is public

### App won't compile?
```bash
flutter clean
flutter pub get
flutter gen-l10n
flutter run
```

## 📧 Need Help?

If you have questions:
1. Check GitHub Pages documentation: https://pages.github.com/
2. Review Flutter url_launcher docs: https://pub.dev/packages/url_launcher
3. Use the app's feedback feature once live

---

**Good luck with your app launch! 🚀**
