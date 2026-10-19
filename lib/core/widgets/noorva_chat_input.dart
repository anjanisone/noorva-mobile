import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'chat_attachments.dart';

/// Shared bottom chat input used by the Guide and Event creation screens.
///
/// Layout: text field on top; below it an attach button, a centred mode pill
/// (e.g. "Guide" / "Events"), and either mic + voice buttons or a send button.
///
/// With [homeStyle], it matches the Home page input instead: dark filled
/// buttons and the mode pill sitting next to the attach button.
///
/// With [attachments], picked images and files show as chips above the text
/// field and the attach button opens the picker (unless [onAttachTap] is set).
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
  final ChatAttachmentController? attachments;
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
    this.attachments,
    this.onMicTap,
    this.onVoiceTap,
    this.isListening = false,
    this.margin,
    this.homeStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final onAttach = onAttachTap ??
        (attachments == null ? null : () => attachments!.pick(context));
    return Container(
      margin: margin ??
          (homeStyle
              ? const EdgeInsets.fromLTRB(16, 8, 16, 16)
              : const EdgeInsets.fromLTRB(16, 0, 16, 24)),
      padding: homeStyle
          ? const EdgeInsets.all(16)
          : const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: homeStyle ? const Color(0xFF161618) : AppColors.card,
        borderRadius: BorderRadius.circular(homeStyle ? 24 : 32),
        border: Border.all(
          color: homeStyle
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.borderLight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (attachments != null)
            ChatAttachmentStrip(controller: attachments!),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: homeStyle ? 2 : 8),
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
                hintStyle: TextStyle(
                  color: homeStyle ? Colors.white30 : Colors.white38,
                  fontSize: 16,
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
          SizedBox(height: homeStyle ? 20 : 10),
          homeStyle ? _buildHomeRow(onAttach) : _buildRow(onAttach),
        ],
      ),
    );
  }

  Widget _buildRow(VoidCallback? onAttach) {
    return Row(
      children: [
        _IconButton(asset: 'assets/icons/media.png', onTap: onAttach),
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

  Widget _buildHomeRow(VoidCallback? onAttach) {
    return Row(
      children: [
        _IconButton(
          icon: Icons.attach_file_rounded,
          onTap: onAttach,
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
              const SizedBox(width: 8),
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
        height: homeStyle ? 48 : null,
        padding: homeStyle
            ? const EdgeInsets.symmetric(horizontal: 12)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: homeStyle
              ? const Color(0xFF2A2A2E)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: homeStyle
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
                      fontSize: 17,
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
                color: homeStyle ? Colors.white : Colors.white60,
                size: homeStyle ? 22 : 16),
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
    final color = isActive ? AppColors.blueAccent : Colors.white70;
    final Color background;
    if (homeStyle) {
      background = isActive ? Colors.white10 : const Color(0xFF2A2A2E);
    } else {
      background =
          isActive ? Colors.white24 : Colors.white.withValues(alpha: 0.08);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: homeStyle ? 48 : null,
        height: homeStyle ? 48 : null,
        padding: homeStyle ? null : const EdgeInsets.all(10),
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Center(
          widthFactor: homeStyle ? null : 1,
          heightFactor: homeStyle ? null : 1,
          child: icon != null
              ? Icon(icon, color: color, size: size)
              : Image.asset(asset!, width: size, height: size, color: color),
        ),
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
