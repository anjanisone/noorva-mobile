import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shared bottom chat input used by the Guide and Event creation screens.
///
/// Layout: text field on top; below it an attach button, a centred mode pill
/// (e.g. "Guide" / "Events"), and either mic + voice buttons or a send button.
///
/// With [homeStyle], it matches the Home page input instead: larger text,
/// plain icon buttons and the mode pill sitting next to the attach button.
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

  final EdgeInsetsGeometry? margin;

  /// Uses the Home page input design.
  final bool homeStyle;

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
    this.margin,
    this.homeStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = homeStyle ? 18.0 : 16.0;
    return Container(
      margin: margin ??
          (homeStyle
              ? const EdgeInsets.fromLTRB(24, 8, 24, 24)
              : const EdgeInsets.fromLTRB(16, 0, 16, 24)),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: homeStyle ? const Color(0xFF141416) : AppColors.card,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: homeStyle
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: homeStyle ? 12 : 8),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              onSubmitted: onSubmitted,
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              style: TextStyle(color: Colors.white, fontSize: fontSize),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: homeStyle ? Colors.white24 : Colors.white38,
                  fontSize: fontSize,
                ),
                // Override the theme's filled/outlined field: this container
                // already provides the surface.
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: homeStyle ? 8 : 6),
              ),
            ),
          ),
          SizedBox(height: homeStyle ? 24 : 10),
          homeStyle ? _buildHomeRow() : _buildRow(),
        ],
      ),
    );
  }

  Widget _buildRow() {
    return Row(
      children: [
        _IconButton(asset: 'assets/icons/media.png', onTap: onAttachTap),
        const Spacer(),
        _ModePill(asset: pillIconAsset, label: pillLabel, onTap: onPillTap),
        const Spacer(),
        if (showSend)
          _SendButton(onTap: onSend)
        else ...[
          _IconButton(
            asset: 'assets/icons/mike.png',
            onTap: onMicTap,
            isActive: isListening,
          ),
          const SizedBox(width: 8),
          _IconButton(
            asset: 'assets/icons/recording.png',
            onTap: onVoiceTap ?? onMicTap,
            isActive: isListening,
          ),
        ],
      ],
    );
  }

  Widget _buildHomeRow() {
    return Row(
      children: [
        _IconButton(
          icon: Icons.attach_file_rounded,
          onTap: onAttachTap,
          homeStyle: true,
        ),
        const SizedBox(width: 8),
        _ModePill(
          asset: pillIconAsset,
          label: pillLabel,
          onTap: onPillTap,
          homeStyle: true,
        ),
        const Spacer(),
        if (showSend)
          _SendButton(onTap: onSend, homeStyle: true)
        else
          Row(
            children: [
              _IconButton(
                icon: Icons.mic_none,
                onTap: onVoiceTap ?? onMicTap,
                isActive: isListening,
                homeStyle: true,
              ),
              const SizedBox(width: 4),
              _IconButton(
                asset: 'assets/icons/recording.png',
                onTap: onVoiceTap ?? onMicTap,
                isActive: isListening,
                homeStyle: true,
              ),
            ],
          ),
      ],
    );
  }
}

class _ModePill extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback? onTap;
  final bool homeStyle;

  const _ModePill({
    required this.asset,
    required this.label,
    this.onTap,
    this.homeStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = homeStyle ? 20.0 : 15.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: homeStyle
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(asset,
                width: iconSize, height: iconSize, color: Colors.white),
            SizedBox(width: homeStyle ? 8 : 6),
            Text(
              label,
              style: homeStyle
                  ? const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    )
                  : const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
            ),
            SizedBox(width: homeStyle ? 6 : 4),
            Icon(Icons.keyboard_arrow_down,
                color: Colors.white60, size: homeStyle ? 20 : 16),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final String? asset;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isActive;
  final bool homeStyle;

  const _IconButton({
    this.asset,
    this.icon,
    this.onTap,
    this.isActive = false,
    this.homeStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = homeStyle ? 24.0 : 20.0;
    final idleColor = homeStyle ? Colors.white54 : Colors.white70;
    final color = isActive ? AppColors.blueAccent : idleColor;
    final Color background;
    if (homeStyle) {
      background = isActive ? Colors.white10 : Colors.transparent;
    } else {
      background =
          isActive ? Colors.white24 : Colors.white.withValues(alpha: 0.08);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: icon != null
            ? Icon(icon, color: color, size: size)
            : Image.asset(asset!, width: size, height: size, color: color),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool homeStyle;

  const _SendButton({this.onTap, this.homeStyle = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(homeStyle ? 12 : 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          homeStyle ? Icons.arrow_upward : Icons.arrow_upward_rounded,
          color: Colors.black,
          size: homeStyle ? 24 : 20,
        ),
      ),
    );
  }
}
