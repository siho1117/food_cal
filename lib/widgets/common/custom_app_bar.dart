// lib/widgets/common/custom_app_bar.dart
import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/typography.dart'; // NEW: Import typography instead of text_styles

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function onSettingsTap;
  final String currentPage;

  const CustomAppBar({
    super.key,
    required this.onSettingsTap,
    this.currentPage = '',
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.secondaryBeige,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App name and sub-heading
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Main app title - UPDATED to use AppTypography
                      Text(
                        'FOOD LLM',
                        style: AppTypography.displayXLarge.copyWith(
                          fontSize: 38,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 2,
                        ),
                      ),
                      
                      // Sub-heading for current page - UPDATED to use AppTypography
                      if (currentPage.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          currentPage,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 16,
                            color: Colors.grey[800],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Settings icon button
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: AppTheme.primaryBlue,
                  size: 28,
                ),
                onPressed: () => onSettingsTap(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}