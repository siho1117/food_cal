// lib/widgets/common/text_input_overlay.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../config/design_system/dialog_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// UNIVERSAL TEXT INPUT OVERLAY
// ═══════════════════════════════════════════════════════════════════════════════
//
// Overlay-based text input dialog for use in preview mode where z-index control is critical.
// Similar to cost_picker_overlay.dart but for text input.
//
// Why overlay instead of dialog?
//   - Guaranteed z-index control (appears above preview overlay)
//   - Direct overlay insertion bypasses Flutter's dialog system
//   - Consistent behavior across different UI contexts
//
// ═══════════════════════════════════════════════════════════════════════════════

/// Global overlay entry for text input (singleton pattern)
OverlayEntry? _textInputOverlay;

/// Shows a text input overlay on top of all UI elements.
///
/// **Parameters:**
/// - [title] - Title to display in the dialog
/// - [initialValue] - The starting text value
/// - [hintText] - Placeholder text when empty (optional)
/// - [maxLength] - Maximum character length (optional)
///
/// **Returns:**
/// - [Future<String?>] - The entered text, or null if cancelled
Future<String?> showTextInputOverlay({
  required String title,
  required String initialValue,
  String? hintText,
  int? maxLength,
}) async {
  try {
    // Get the overlay from the global navigator key
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('❌ [TextInput] Overlay state unavailable');
      return null;
    }

    // Remove any existing overlay first
    _textInputOverlay?.remove();
    _textInputOverlay = null;

    // Create completer for async result
    final completer = Completer<String?>();

    // Create new overlay entry with text input
    _textInputOverlay = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: _TextInputOverlayContent(
              title: title,
              initialValue: initialValue,
              hintText: hintText,
              maxLength: maxLength,
              onResult: (result) {
                completer.complete(result);
                _hideTextInputOverlay();
              },
            ),
          ),
        ),
      ),
    );

    // Insert overlay
    overlayState.insert(_textInputOverlay!);

    // Return future that completes when user makes selection
    return completer.future;
  } catch (e, stackTrace) {
    debugPrint('❌ [TextInput] Error showing overlay: $e');
    debugPrint('Stack trace: $stackTrace');
    return null;
  }
}

/// Removes the text input overlay from the screen.
void _hideTextInputOverlay() {
  try {
    if (_textInputOverlay != null) {
      _textInputOverlay?.remove();
      _textInputOverlay = null;
    }
  } catch (e) {
    debugPrint('❌ [TextInput] Error removing overlay: $e');
    _textInputOverlay = null;
  }
}

/// Internal widget for text input overlay content
class _TextInputOverlayContent extends StatefulWidget {
  final String title;
  final String initialValue;
  final String? hintText;
  final int? maxLength;
  final Function(String?) onResult;

  const _TextInputOverlayContent({
    required this.title,
    required this.initialValue,
    required this.hintText,
    required this.maxLength,
    required this.onResult,
  });

  @override
  State<_TextInputOverlayContent> createState() => _TextInputOverlayContentState();
}

class _TextInputOverlayContentState extends State<_TextInputOverlayContent> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onResult(null), // Tap outside to cancel
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent taps on dialog from dismissing
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: AppDialogTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppDialogTheme.borderRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Padding(
                    padding: AppDialogTheme.contentPadding,
                    child: Text(
                      widget.title,
                      style: AppDialogTheme.titleStyle,
                    ),
                  ),
                  // Text field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      maxLength: widget.maxLength,
                      style: AppDialogTheme.inputTextStyle,
                      decoration: AppDialogTheme.inputDecoration(hintText: widget.hintText),
                    ),
                  ),
                  // Buttons
                  Padding(
                    padding: AppDialogTheme.actionsPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => widget.onResult(null),
                          style: AppDialogTheme.cancelButtonStyle,
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () {
                            final value = _controller.text.trim();
                            widget.onResult(value.isEmpty ? null : value);
                          },
                          style: AppDialogTheme.primaryButtonStyle,
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
