// lib/widgets/common/user_avatar_widget.dart
import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../data/models/user_profile.dart';
import 'slow_animated_emoji.dart';

/// Reusable user avatar widget that displays either:
/// - Animated emoji avatar (if user has selected one)
/// - Gradient letter avatar (first letter of name)
/// - Person icon (if no name set)
class UserAvatarWidget extends StatelessWidget {
  final UserProfile? profile;
  final double size;
  final bool isInteractive; // Whether to show tap feedback
  final VoidCallback? onTap;
  final bool useAnimation; // Whether to animate emoji (false for static reports)

  const UserAvatarWidget({
    super.key,
    required this.profile,
    this.size = 68.0,
    this.isInteractive = false,
    this.onTap,
    this.useAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);
    final userName = profile?.name;
    final hasName = userName != null && userName.isNotEmpty;

    final avatarWidget = _buildAvatar(
      context,
      userName,
      hasName,
      themeProvider,
      textColor,
    );

    if (isInteractive && onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildAvatar(
    BuildContext context,
    String? userName,
    bool hasName,
    ThemeProvider themeProvider,
    Color textColor,
  ) {
    // Get solid avatar color based on theme
    final solidAvatarColor = AppWidgetTheme.getAvatarColor(
      themeProvider.selectedGradient,
    );

    // Check if user has emoji avatar enabled
    final useEmoji = profile?.useEmojiAvatar ?? false;
    final emojiId = profile?.profileEmojiId;
    final hasEmoji = useEmoji && emojiId != null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // Solid white background for emoji avatars, theme color for letter avatars
        color: hasEmoji
            ? Colors.white
            : (hasName
                ? solidAvatarColor
                : textColor.withValues(alpha: 0.25)),
        shape: BoxShape.circle,
        boxShadow: [AppWidgetTheme.standardBoxShadow],
      ),
      child: Center(
        child: hasEmoji
            ? _buildEmojiAvatar(emojiId, size)
            : (hasName
                ? _buildGradientLetter(context, userName!, themeProvider, size)
                : Icon(
                    Icons.person,
                    size: size * 0.5, // Scale icon with avatar size
                    color: textColor,
                  )),
      ),
    );
  }

  Widget _buildEmojiAvatar(String emojiId, double avatarSize) {
    // Find the emoji data by ID
    final emojiData = AnimatedEmojis.values.firstWhere(
      (emoji) => emoji.id == emojiId,
      orElse: () => AnimatedEmojis.dog, // Fallback to dog emoji
    );

    // Emoji size: ~70% of container
    final emojiSize = avatarSize * 0.7;

    if (useAnimation) {
      // Using SlowAnimatedEmoji for controllable animation speed
      return SlowAnimatedEmoji(
        emoji: emojiData,
        size: emojiSize,
        speedFactor: 0.6, // 60% speed - slower, more subtle animation
        errorWidget: Icon(
          Icons.pets,
          size: emojiSize * 0.7,
          color: Colors.grey,
        ),
      );
    } else {
      // Static emoji for reports/exports
      return AnimatedEmoji(
        emojiData,
        size: emojiSize,
        repeat: false, // No animation
        errorWidget: Icon(
          Icons.pets,
          size: emojiSize * 0.7,
          color: Colors.grey,
        ),
      );
    }
  }

  Widget _buildGradientLetter(
    BuildContext context,
    String userName,
    ThemeProvider themeProvider,
    double avatarSize,
  ) {
    // Get first character and uppercase it
    final letter = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    // Get gradient from theme provider
    final gradient = themeProvider.getCurrentGradient();

    // Font size: ~50% of container
    final fontSize = avatarSize * 0.5;

    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white, // This color gets replaced by gradient
        ),
      ),
    );
  }
}
