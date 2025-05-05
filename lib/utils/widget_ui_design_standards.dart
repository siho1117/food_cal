// lib/config/widget_ui_design_standards.dart

/// This file contains standards for widget UI design in the FOOD LLM app
/// Use as a reference when creating or updating widgets to maintain consistency

class WidgetUIStandards {
  // Private constructor to prevent instantiation
  WidgetUIStandards._();

  /// CONTAINER STYLING
  ///
  /// All main content widgets should use these container standards
  static const double containerBorderRadius = 16.0;
  static const double containerShadowOpacity = 0.05;
  static const double containerShadowBlur = 10.0;
  static const double containerShadowYOffset = 2.0;

  /// HEADER STYLING
  ///
  /// Standard styling for widget headers
  static const double headerVerticalPadding = 14.0;
  static const double headerHorizontalPadding = 20.0;
  static const double headerIconSize = 20.0;
  static const double headerIconSpacing = 8.0;
  static const double headerFontSize = 16.0;
  static const double headerBackgroundOpacity = 0.02;

  /// CONTENT PADDING
  ///
  /// Standard padding for widget content areas
  static const double contentPadding = 20.0;
  static const double contentVerticalSpacing = 15.0;

  /// TEXT STYLING
  ///
  /// Text size standards for different elements
  static const double primaryLargeTextSize = 34.0;  // Main numbers (e.g., calories)
  static const double primaryMediumTextSize = 16.0; // Important values
  static const double secondaryTextSize = 14.0;     // Supporting text
  static const double labelTextSize = 15.0;         // Section labels
  static const double captionTextSize = 13.0;       // Small captions
  static const double microTextSize = 11.0;         // Very small text

  /// SPACING
  ///
  /// Standard spacing between elements
  static const double elementSpacing = 6.0;         // Between related elements
  static const double sectionSpacing = 15.0;        // Between logical sections
  static const double majorSectionSpacing = 20.0;   // Between major sections

  /// INDICATOR STYLING
  ///
  /// Standards for visual indicators
  static const double indicatorSize = 10.0;         // Size of color indicators
  static const double indicatorSpacing = 6.0;       // Spacing after indicators

  /// CHART DIMENSIONS
  ///
  /// Standard sizes for chart elements
  static const double chartSize = 145.0;           // Size of circular charts
  static const double progressBarHeight = 12.0;    // Height of progress bars
  static const double progressThumbSize = 12.0;    // Size of progress thumbs

  /// CALORIE SUMMARY WIDGET
  ///
  /// Specific standards for CalorieSummaryWidget
  static const double calorieNumberSize = 34.0;
  static const double calorieGoalSize = 18.0;
  
  /// MACRONUTRIENT WIDGET
  ///
  /// Specific standards for MacronutrientWidget
  static const double macroRingWidth = 0.18;       // As percentage of radius
  static const double macroLabelFontSize = 15.0;
  static const double macroValueFontSize = 16.0;
  static const double macroUnitFontSize = 14.0;
  
  /// PILL STYLING
  ///
  /// Standards for pill-shaped elements
  static const double pillBorderRadius = 20.0;
  static const double pillVerticalPadding = 6.0;
  static const double pillHorizontalPadding = 12.0;
  static const double pillIconSize = 16.0;
  static const double pillIconSpacing = 6.0;
  
  /// BUTTON STYLING
  ///
  /// Standards for buttons
  static const double buttonBorderRadius = 8.0;
  static const double buttonVerticalPadding = 12.0;
  static const double buttonHorizontalPadding = 16.0;
  static const double buttonIconSize = 16.0;
  static const double buttonIconSpacing = 8.0;
  
  /// COMMON COLOR USAGE
  ///
  /// Guidelines for consistent color application
  /// (Note: actual colors are defined in AppTheme)
  ///
  /// primaryBlue: Primary UI elements, headers, buttons
  /// coralAccent: Protein indicators, accent elements
  /// goldAccent: Carbs indicators, warning states
  /// accentColor: Fat indicators, interactive elements
  /// Grey (200): Backgrounds, dividers, inactive states
  /// Green (600): Positive indicators, under/at target metrics
  /// Red (500): Negative indicators, over target metrics, warnings
}