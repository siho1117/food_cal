// lib/widgets/common/search_by_name_dialog.dart
import 'package:flutter/material.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../food/food_card.dart';

/// Simple text input dialog for food name search
///
/// Matches the food card color scheme and provides a clean interface
/// for users to enter a food name to search for nutritional information.
class SearchByNameDialog extends StatefulWidget {
  const SearchByNameDialog({super.key});

  @override
  State<SearchByNameDialog> createState() => _SearchByNameDialogState();
}

class _SearchByNameDialogState extends State<SearchByNameDialog> {
  final TextEditingController _textController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final foodName = _textController.text.trim();
    if (foodName.isEmpty) {
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Return the food name to the caller
    Navigator.of(context).pop(foodName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cardColor = FoodCardWidget.getCardColor(context);
    final canSearch = _textController.text.trim().isNotEmpty && !_isSearching;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with food card color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppWidgetTheme.spaceLG),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: AppWidgetTheme.spaceSM),
                  Text(
                    l10n.searchByName,
                    style: AppTypography.displayMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content area
            Padding(
              padding: const EdgeInsets.all(AppWidgetTheme.spaceLG),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Text input field
                  TextField(
                    controller: _textController,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 100,
                    style: AppTypography.bodyMedium,
                    decoration: InputDecoration(
                      counterText: '', // Hide character counter
                      hintText: l10n.enterFoodName,
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: Colors.grey.shade400,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: cardColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppWidgetTheme.spaceMD,
                        vertical: AppWidgetTheme.spaceMD,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        // Trigger rebuild to update button state
                      });
                    },
                    onSubmitted: (value) {
                      if (canSearch) {
                        _handleSearch();
                      }
                    },
                  ),

                  const SizedBox(height: AppWidgetTheme.spaceLG),

                  // Search button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: canSearch ? _handleSearch : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cardColor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.searchFood,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: AppWidgetTheme.spaceSM),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
