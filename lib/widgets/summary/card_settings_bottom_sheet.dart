// lib/widgets/summary/card_settings_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/typography.dart';
import '../../providers/theme_provider.dart';
import '../../data/models/summary_card_config.dart';
import '../../l10n/generated/app_localizations.dart';

/// Bottom sheet for customizing which summary cards are visible
class CardSettingsBottomSheet extends StatefulWidget {
  final List<SummaryCardConfig> cardConfigs;
  final Function(SummaryCardType, bool) onVisibilityChanged;
  final Function(int, int)? onReorder;

  const CardSettingsBottomSheet({
    super.key,
    required this.cardConfigs,
    required this.onVisibilityChanged,
    this.onReorder,
  });

  @override
  State<CardSettingsBottomSheet> createState() => _CardSettingsBottomSheetState();
}

class _CardSettingsBottomSheetState extends State<CardSettingsBottomSheet> {
  late List<SummaryCardConfig> _localCardConfigs;

  @override
  void initState() {
    super.initState();
    _localCardConfigs = List.from(widget.cardConfigs);
  }

  void _handleVisibilityChanged(SummaryCardType cardType, bool isVisible) {
    // Update local state immediately for instant UI feedback
    setState(() {
      final index = _localCardConfigs.indexWhere((c) => c.type == cardType);
      if (index != -1) {
        _localCardConfigs[index] = _localCardConfigs[index].copyWith(isVisible: isVisible);
      }
    });

    // Also call the parent's callback to persist the change
    widget.onVisibilityChanged(cardType, isVisible);
  }

  void _handleReorder(int oldIndex, int newIndex) {
    // Update local state immediately for instant UI feedback
    setState(() {
      // Adjust newIndex if moving down the list
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Reorder the list
      final item = _localCardConfigs.removeAt(oldIndex);
      _localCardConfigs.insert(newIndex, item);

      // Update order values
      for (int i = 0; i < _localCardConfigs.length; i++) {
        _localCardConfigs[i] = _localCardConfigs[i].copyWith(order: i);
      }
    });

    // Also call the parent's callback to persist the change
    widget.onReorder?.call(oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          AppWidgetTheme.cardBorderOpacity,
        );

        return Container(
          decoration: BoxDecoration(
            color: AppWidgetTheme.colorPrimaryDark,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppWidgetTheme.borderRadiusXL),
              topRight: Radius.circular(AppWidgetTheme.borderRadiusXL),
            ),
          ),
          padding: EdgeInsets.only(
            top: AppWidgetTheme.spaceLG,
            left: AppWidgetTheme.spaceXL,
            right: AppWidgetTheme.spaceXL,
            bottom: MediaQuery.of(context).padding.bottom + AppWidgetTheme.spaceXL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: Colors.white,
                    size: AppWidgetTheme.iconSizeLarge,
                  ),
                  const SizedBox(width: AppWidgetTheme.spaceMD),
                  Expanded(
                    child: Text(
                      l10n.customizeSummaryCards,
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: AppWidgetTheme.fontSizeLG,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: AppWidgetTheme.spaceSM),

              Text(
                l10n.chooseCardsToShow,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: AppWidgetTheme.fontSizeSM,
                  color: Colors.white.withValues(alpha: AppWidgetTheme.opacityHigher),
                ),
              ),

              const SizedBox(height: AppWidgetTheme.spaceLG),

              // Reorderable card list
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: _handleReorder,
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Material(
                        color: Colors.transparent,
                        elevation: 0,
                        child: Opacity(
                          opacity: 0.8,
                          child: child,
                        ),
                      );
                    },
                    child: child,
                  );
                },
                children: _localCardConfigs.map((config) {
                  return _buildCardToggle(
                    config,
                    borderColor,
                    key: ValueKey(config.type.id),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppWidgetTheme.spaceMD),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardToggle(
    SummaryCardConfig config,
    Color borderColor, {
    Key? key,
  }) {
    return Builder(
      key: key,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          margin: const EdgeInsets.only(bottom: AppWidgetTheme.spaceMD),
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusMD),
          ),
          child: Row(
            children: [
              // Drag handle icon
              Padding(
                padding: const EdgeInsets.only(
                  left: AppWidgetTheme.spaceXS,
                  right: AppWidgetTheme.spaceXS,
                ),
                child: Icon(
                  Icons.drag_handle,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: AppWidgetTheme.iconSizeMedium,
                ),
              ),

              // Card icon
              Padding(
                padding: const EdgeInsets.only(
                  left: AppWidgetTheme.spaceXS,
                  right: AppWidgetTheme.spaceSM,
                ),
                child: AnimatedEmoji(
                  config.type.icon,
                  size: 26,
                ),
              ),

              // Card info and toggle
              Expanded(
                child: SwitchListTile(
                  title: Text(
                    config.type.getDisplayName(l10n),
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: AppWidgetTheme.fontSizeMD,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: config.isVisible
                      ? null
                      : Text(
                          l10n.hiddenFromSummary,
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: AppWidgetTheme.fontSizeXS,
                            color: Colors.white.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                  value: config.isVisible,
                  onChanged: (value) {
                    _handleVisibilityChanged(config.type, value);
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.white.withValues(alpha: 0.5),
                  inactiveThumbColor: Colors.white.withValues(alpha: 0.3),
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppWidgetTheme.spaceSM,
                    vertical: AppWidgetTheme.spaceXS,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
