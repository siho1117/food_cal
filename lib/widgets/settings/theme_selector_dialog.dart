// lib/widgets/settings/theme_selector_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme_design.dart';  // ✅ NEW: Using theme_design
import '../../config/design_system/theme_background.dart';  // ✅ NEW: Using theme_background for gradients
import '../../providers/theme_provider.dart';

class ThemeSelectorDialog extends StatelessWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Get all available gradients from provider (01-09)
    final availableGradients = themeProvider.availableGradients;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),  // ✅ Using coral color inline
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: Color(0xFFFF6B6B),  // ✅ Coral accent
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Theme',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,  // ✅ Using AppColors
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: AppColors.textGrey,  // ✅ Using AppColors
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your color scheme',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,  // ✅ Using AppColors
              ),
            ),
            const SizedBox(height: 24),

            // Theme List (scrollable if needed)
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: availableGradients.map((gradientName) {
                    final isSelected = themeProvider.selectedGradient == gradientName;
                    final displayName = themeProvider.getGradientDisplayName(gradientName);
                    final description = themeProvider.getGradientDescription(gradientName);
                    final emoji = themeProvider.getGradientEmoji(gradientName);
                    final gradientColors = ThemeBackground.gradients[gradientName]!;  // ✅ Using ThemeBackground
                    
                    return _ThemeTile(
                      gradientName: gradientName,
                      displayName: displayName,
                      description: description,
                      emoji: emoji,
                      gradientColors: gradientColors,
                      isSelected: isSelected,
                      onTap: () async {
                        await themeProvider.setGradient(gradientName);
                        if (context.mounted) {
                          // Don't close immediately - let user see the change
                          await Future.delayed(const Duration(milliseconds: 300));
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.textDark.withValues(alpha: 0.05),  // ✅ Using AppColors
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.textDark.withValues(alpha: 0.1),  // ✅ Using AppColors
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textDark.withValues(alpha: 0.7),  // ✅ Using AppColors
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Theme will be applied to all screens',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,  // ✅ Using AppColors
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

class _ThemeTile extends StatefulWidget {
  final String gradientName;
  final String displayName;
  final String description;
  final String emoji;
  final List<Color> gradientColors;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.gradientName,
    required this.displayName,
    required this.description,
    required this.emoji,
    required this.gradientColors,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ThemeTile> createState() => _ThemeTileState();
}

class _ThemeTileState extends State<_ThemeTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFFFF6B6B).withValues(alpha: 0.1)  // ✅ Coral accent
                  : _isHovered
                      ? Colors.grey.withValues(alpha: 0.05)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? const Color(0xFFFF6B6B)  // ✅ Coral accent
                    : Colors.grey.withValues(alpha: 0.2),
                width: widget.isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient Preview Bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: widget.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Theme Name and Selection Indicator
                Row(
                  children: [
                    // Emoji
                    Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: widget.isSelected 
                                  ? FontWeight.bold 
                                  : FontWeight.w600,
                              color: widget.isSelected
                                  ? AppColors.textDark  // ✅ Using AppColors
                                  : AppColors.textGrey.withValues(alpha: 0.9),  // ✅ Using AppColors
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textGrey,  // ✅ Using AppColors
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Selected indicator
                    if (widget.isSelected)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B),  // ✅ Coral accent
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}