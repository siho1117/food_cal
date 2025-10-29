// lib/widgets/settings/language_selector_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme_design.dart';
import '../../providers/language_provider.dart';

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    // Only show languages that have .arb files
    final availableLanguages = [
      'en',
      'zh_CN',
      'zh_TW',
    ];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
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
                    color: AppLegacyColors.coralAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: AppLegacyColors.coralAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppLegacyColors.primaryBlue,
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
              'Choose your preferred language',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Language List
            ...availableLanguages.map((languageCode) {
              final isSelected = languageProvider.isLanguageSelected(languageCode);
              final languageName = languageProvider.getLanguageName(languageCode);
              final languageFlag = languageProvider.getLanguageFlag(languageCode);
              
              return _LanguageTile(
                languageCode: languageCode,
                languageName: languageName,
                languageFlag: languageFlag,
                isSelected: isSelected,
                onTap: () async {
                  await languageProvider.changeLanguage(languageCode);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),

            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppLegacyColors.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppLegacyColors.primaryBlue.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppLegacyColors.primaryBlue.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Language will be saved and applied immediately',
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

class _LanguageTile extends StatefulWidget {
  final String languageCode;
  final String languageName;
  final String languageFlag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.languageCode,
    required this.languageName,
    required this.languageFlag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends State<_LanguageTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? AppLegacyColors.coralAccent.withOpacity(0.1)
                  : _isHovered
                      ? Colors.grey.withOpacity(0.05)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? AppLegacyColors.coralAccent
                    : Colors.grey.withOpacity(0.2),
                width: widget.isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Flag
                Text(
                  widget.languageFlag,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 16),
                
                // Language Name
                Expanded(
                  child: Text(
                    widget.languageName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: widget.isSelected 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      color: widget.isSelected
                          ? AppLegacyColors.primaryBlue
                          : Colors.grey[800],
                    ),
                  ),
                ),
                
                // Selected indicator
                if (widget.isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppLegacyColors.coralAccent,
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
          ),
        ),
      ),
    );
  }
}