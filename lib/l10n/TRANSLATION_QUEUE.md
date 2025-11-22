# Translation Queue for Food Cal App

> **Purpose**: Track strings that need translation during UI refinement
> **Last Updated**: 2025-11-22
> **Workflow**: English strings are added here first, then translated to zh, zh_CN, zh_TW when ready

---

## 🔴 Pending Translations

### CalorieSummaryWidget

#### `caloriesOver`
- **English**: "Calories over"
- **Context**: Displayed when user exceeds their daily calorie goal
- **Previous value**: "Over budget" (❌ rejected - too financial)
- **UI Example**:
  ```
  🔥 Calories Intake 🔥
       2,300
    / 2,000 cal

  Calories over +300
  ```
- **Status**: 🔴 Needs translation to zh, zh_CN, zh_TW

---

## ✅ Already Translated

### CalorieSummaryWidget
- ✅ `caloriesToday` - "Calories Intake"
- ✅ `cal` - "cal"
- ✅ `remainingCalories` - "Remaining calories"

### WeekNavigationWidget
- ✅ `today` - "Today"
- ✅ `yesterday` - "Yesterday"

### Settings Screen
- ✅ `settingsTitle` - "Settings"
- ✅ `language` - "Language"
- ✅ `selectLanguage` - "Select Language"
- ✅ `preferences` - "Preferences"
- ✅ `units` - "Units"
- ✅ `metric` - "Metric"
- ✅ `imperial` - "Imperial"

### Common Actions
- ✅ `save` - "Save"
- ✅ `cancel` - "Cancel"
- ✅ `retry` - "Retry"
- ✅ `close` - "Close"

### Error Messages
- ✅ `errorLoadingData` - "Error Loading Data"
- ✅ `unknownError` - "An unknown error occurred"
- ✅ `settingsSavedSuccess` - "Settings saved successfully!"

### Common Labels
- ✅ `name` - "Name"
- ✅ `tapToEdit` - "Tap to edit"

---

## 📝 Translation Guidelines

1. **Tone**: Keep neutral and informative, avoid judgment
2. **Consistency**: Match existing app voice and terminology
3. **Context**: Consider how the text appears in the UI
4. **Brevity**: Mobile screens are small - keep translations concise
5. **User-first**: Prioritize clarity over literal translation

---

## 🔄 How to Use This File

### For Developers:
When adding new UI strings:
1. Add English text to appropriate `.arb` file
2. Add entry to this file under "🔴 Pending Translations"
3. Group by widget/feature
4. Include context and UI example

### For Translators:
1. Find entries marked 🔴 (needs translation)
2. Translate to zh, zh_CN, zh_TW
3. Update all `.arb` files
4. Run `flutter gen-l10n`
5. Move entry to "✅ Already Translated" section
