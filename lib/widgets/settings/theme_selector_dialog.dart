// lib/widgets/settings/theme_selector_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../providers/theme_provider.dart';

class ThemeSelectorDialog extends StatelessWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final brightness = Theme.of(context).brightness;
    
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
                    color: AppTheme.coralAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: AppTheme.coralAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select Theme',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your color scheme',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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
                    final gradientColors = AppTheme.getGradientColors(gradientName, brightness);
                    
                    return _ThemeTile(
                      gradientName: gradientName,
                      displayName: displayName,
                      description: description,
                      emoji: emoji,
                      gradientColors: gradientColors,
                      isSelected: isSelected,
                      brightness: brightness,
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
                color: AppTheme.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.primaryBlue.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Theme will be applied to all screens',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
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
  final Brightness brightness;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.gradientName,
    required this.displayName,
    required this.description,
    required this.emoji,
    required this.gradientColors,
    required this.isSelected,
    required this.brightness,
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
                  ? AppTheme.coralAccent.withOpacity(0.1)
                  : _isHovered
                      ? Colors.grey.withOpacity(0.05)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? AppTheme.coralAccent
                    : Colors.grey.withOpacity(0.2),
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
                                  ? AppTheme.primaryBlue
                                  : Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
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
                          color: AppTheme.coralAccent,
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