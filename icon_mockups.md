# Summary Screen Icon Replacement Options

## Current Implementation
```dart
// Daily: Icons.today
// Weekly: Icons.calendar_view_month
// Monthly: Icons.calendar_month
```

---

## 🎨 VISUAL MOCKUPS

### **OPTION 1: Time-Based Icons (RECOMMENDED)**
**Theme:** Natural time progression (Sun → Week Range → Month)

```
┌─────────────────────────────────────────────────────────┐
│  Summary Controls                                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   ┌──────────────────────────────────────────┐  ⬇️     │
│   │ ┌──────────┬──────────┬──────────┐      │         │
│   │ │ ☀️ Daily │ 📅 Weekly│ 📆 Monthly│  ⚙️  │         │
│   │ └──────────┴──────────┴──────────┘      │         │
│   └──────────────────────────────────────────┘         │
│                                                          │
└─────────────────────────────────────────────────────────┘

Icons Used:
• Daily:   Icons.wb_sunny (or Icons.sunny)        ☀️
• Weekly:  Icons.date_range                        📅
• Monthly: Icons.calendar_month                    📆

PROS:
✅ Intuitive metaphor (sun = day, range = week, month = month)
✅ Clear visual distinction between all three
✅ Modern and friendly appearance
✅ Works well with your glass morphism design

CONS:
❌ Sun icon might seem unrelated to calendar/summary at first glance
```

---

### **OPTION 2: View-Based Calendar Icons**
**Theme:** Different calendar view modes

```
┌─────────────────────────────────────────────────────────┐
│  Summary Controls                                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   ┌──────────────────────────────────────────┐  ⬇️     │
│   │ ┌──────────┬──────────┬──────────┐      │         │
│   │ │ 📅 Daily │ 📊 Weekly│ 📆 Monthly│  ⚙️  │         │
│   │ └──────────┴──────────┴──────────┘      │         │
│   └──────────────────────────────────────────┘         │
│                                                          │
└─────────────────────────────────────────────────────────┘

Icons Used:
• Daily:   Icons.calendar_today                   📅
• Weekly:  Icons.view_week                         📊
• Monthly: Icons.calendar_month                    📆

PROS:
✅ All calendar-related, consistent family
✅ view_week clearly shows 7-day columns
✅ Professional and business-like

CONS:
❌ calendar_today and calendar_month look similar
❌ Less visual variety
```

---

### **OPTION 3: Minimal Event Icons**
**Theme:** Event granularity (single → multiple → full month)

```
┌─────────────────────────────────────────────────────────┐
│  Summary Controls                                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   ┌──────────────────────────────────────────┐  ⬇️     │
│   │ ┌──────────┬──────────┬──────────┐      │         │
│   │ │ 📌 Daily │ 📋 Weekly│ 📆 Monthly│  ⚙️  │         │
│   │ └──────────┴──────────┴──────────┘      │         │
│   └──────────────────────────────────────────┘         │
│                                                          │
└─────────────────────────────────────────────────────────┘

Icons Used:
• Daily:   Icons.event                            📌
• Weekly:  Icons.calendar_view_week               📋
• Monthly: Icons.calendar_month                   📆

PROS:
✅ Simple and clean
✅ Icons get progressively more complex (day → week → month)
✅ Good semantic meaning

CONS:
❌ Icons.event is very simple, might be too minimal
```

---

### **OPTION 4: Numeric Representation**
**Theme:** Number of days (1 → 7 → 30)

```
┌─────────────────────────────────────────────────────────┐
│  Summary Controls                                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   ┌──────────────────────────────────────────┐  ⬇️     │
│   │ ┌──────────┬──────────┬──────────┐      │         │
│   │ │ 1️⃣ Daily │ 7️⃣ Weekly│ 📆 Monthly│  ⚙️  │         │
│   │ └──────────┴──────────┴──────────┘      │         │
│   └──────────────────────────────────────────┘         │
│                                                          │
└─────────────────────────────────────────────────────────┘

Icons Used:
• Daily:   Icons.looks_one (or filter_1)          1️⃣
• Weekly:  Icons.looks_7 (or filter_7)            7️⃣
• Monthly: Icons.calendar_month                   📆

PROS:
✅ Very clear numeric representation
✅ Unique and memorable
✅ Educational (7 days in a week)

CONS:
❌ Mixing numbers with calendar breaks visual consistency
❌ Might look odd in some themes
❌ Numbers might be too literal/obvious
```

---

### **OPTION 5: Modern Abstract Icons (BOLD CHOICE)**
**Theme:** Abstract time blocks and modules

```
┌─────────────────────────────────────────────────────────┐
│  Summary Controls                                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   ┌──────────────────────────────────────────┐  ⬇️     │
│   │ ┌──────────┬──────────┬──────────┐      │         │
│   │ │ ◉  Daily │ ▦ Weekly │ 📆 Monthly│  ⚙️  │         │
│   │ └──────────┴──────────┴──────────┘      │         │
│   └──────────────────────────────────────────┘         │
│                                                          │
└─────────────────────────────────────────────────────────┘

Icons Used:
• Daily:   Icons.circle (or brightness_5)         ◉
• Weekly:  Icons.view_module (or grid_view)       ▦
• Monthly: Icons.calendar_month                   📆

PROS:
✅ Modern and minimalist
✅ Clear progression: single → multiple → calendar
✅ Stands out from typical calendar apps

CONS:
❌ Most abstract, might confuse users initially
❌ Less obvious connection to time periods
```

---

## 🏆 MY TOP RECOMMENDATION: **OPTION 2 (View-Based)**

### Recommended Implementation:
```dart
IconData _getPeriodIcon(SummaryPeriod period) {
  switch (period) {
    case SummaryPeriod.daily:
      return Icons.calendar_today;     // Single day focus
    case SummaryPeriod.weekly:
      return Icons.view_week;          // 7-day columns (most distinct!)
    case SummaryPeriod.monthly:
      return Icons.calendar_month;     // Full month view
  }
}
```

### Why Option 2?
1. **`Icons.view_week`** is the star here - it clearly shows 7 vertical columns representing a week
2. All icons stay within the calendar/time family
3. Each icon has a distinct shape:
   - `calendar_today`: Rectangle with emphasis on ONE date
   - `view_week`: Seven vertical bars (very recognizable)
   - `calendar_month`: Grid of dates
4. Professional and fits fitness/health app aesthetics

---

## 🎨 Alternative Top Choice: **OPTION 1 (Time-Based)**

If you want something more playful/friendly:
```dart
IconData _getPeriodIcon(SummaryPeriod period) {
  switch (period) {
    case SummaryPeriod.daily:
      return Icons.wb_sunny;           // Sunshine for daily
    case SummaryPeriod.weekly:
      return Icons.date_range;         // Date range picker
    case SummaryPeriod.monthly:
      return Icons.calendar_month;     // Full month
  }
}
```

---

## 📋 Complete Material Icons Options Available

### For DAILY:
- `Icons.today` (current)
- `Icons.calendar_today` ⭐ Recommended
- `Icons.event`
- `Icons.wb_sunny` ⭐ Creative choice
- `Icons.sunny`
- `Icons.brightness_5`
- `Icons.circle`
- `Icons.looks_one`
- `Icons.filter_1`

### For WEEKLY:
- `Icons.calendar_view_month` (current)
- `Icons.view_week` ⭐⭐ BEST CHOICE
- `Icons.calendar_view_week`
- `Icons.date_range` ⭐ Good alternative
- `Icons.view_module`
- `Icons.grid_view`
- `Icons.looks_7`
- `Icons.filter_7`
- `Icons.view_column`

### For MONTHLY (keep as is):
- `Icons.calendar_month` ⭐ Perfect, no change needed

---

## 🧪 How to Test These

You can preview these icons easily by temporarily changing line 237-245 in:
[summary_controls_widget.dart:237-245](lib/widgets/summary/summary_controls_widget.dart#L237-L245)

Just replace the icon names and hot reload to see the differences!

---

## ✅ FINAL RECOMMENDATION

**Go with Option 2:**
- Daily: `Icons.calendar_today`
- Weekly: `Icons.view_week` ← This is the key improvement!
- Monthly: `Icons.calendar_month` (no change)

The `view_week` icon is perfect because it literally shows 7 columns, making it instantly recognizable as "weekly view" to users.
