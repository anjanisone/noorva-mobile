import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shared bottom chat input used by the Guide and Event creation screens.
///
/// Layout: text field on top; below it an attach button, a centred mode pill
/// (e.g. "Guide" / "Events"), and either mic + voice buttons or a send button.
class NoorvaChatInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final bool readOnly;
  final ValueChanged<String>? onSubmitted;

  /// Shows the send button in place of the mic / voice buttons.
  final bool showSend;
  final VoidCallback? onSend;

  final String pillIconAsset;
  final String pillLabel;
  final VoidCallback? onPillTap;

  final VoidCallback? onAttachTap;
  final VoidCallback? onMicTap;
  final VoidCallback? onVoiceTap;
  final bool isListening;

  final EdgeInsetsGeometry margin;

  const NoorvaChatInput({
    super.key,
    required this.controller,
    required this.pillIconAsset,
    required this.pillLabel,
    this.focusNode,
    this.hintText = 'Ask Noorva Anything',
    this.readOnly = false,
    this.onSubmitted,
    this.showSend = false,
    this.onSend,
    this.onPillTap,
    this.onAttachTap,
    this.onMicTap,
    this.onVoiceTap,
    this.isListening = false,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              onSubmitted: onSubmitted,
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 16),
                // Override the theme's filled/outlined field: this container
                // already provides the surface.
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _IconButton(asset: 'assets/icons/media.png', onTap: onAttachTap),
              const Spacer(),
              _ModePill(
                  asset: pillIconAsset, label: pillLabel, onTap: onPillTap),
              const Spacer(),
              if (showSend)
                _SendButton(onTap: onSend)
              else ...[
                // _IconButton(
                //   asset: 'assets/icons/mike.png',
                //   onTap: onMicTap,
                //   isActive: isListening,
                // ),
                // const SizedBox(width: 10),
                _IconButton(
                  asset: 'assets/icons/recording.png',
                  onTap: onVoiceTap ?? onMicTap,
                  isActive: isListening,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback? onTap;

  const _ModePill({required this.asset, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(asset, width: 15, height: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                color: Colors.white60, size: 16),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final String asset;
  final VoidCallback? onTap;
  final bool isActive;

  const _IconButton({required this.asset, this.onTap, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              isActive ? Colors.white24 : Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          asset,
          width: 20,
          height: 20,
          color: isActive ? AppColors.blueAccent : Colors.white70,
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _SendButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_upward_rounded,
            color: Colors.black, size: 20),
      ),
    );
  }
}
