import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A file or image the user attached to a chat message before sending it.
class ChatAttachment {
  final String path;
  final String name;
  final bool isImage;

  const ChatAttachment({
    required this.path,
    required this.name,
    required this.isImage,
  });

  static const _imageExtensions = {
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'bmp', //
  };

  factory ChatAttachment.fromPath(String path, {String? name}) {
    final fileName = name ?? path.split(RegExp(r'[\\/]')).last;
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';
    return ChatAttachment(
      path: path,
      name: fileName,
      isImage: _imageExtensions.contains(ext),
    );
  }
}

/// Holds the attachments waiting to be sent with the next message.
///
/// Shared by the Home, Guide and Event creation inputs so they all pick,
/// show and remove attachments the same way.
class ChatAttachmentController extends ValueNotifier<List<ChatAttachment>> {
  ChatAttachmentController() : super(const []);

  static const maxAttachments = 10;

  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  void addAll(Iterable<ChatAttachment> items) {
    final known = value.map((a) => a.path).toSet();
    final fresh = items.where((a) => known.add(a.path));
    value = [...value, ...fresh].take(maxAttachments).toList();
  }

  void remove(ChatAttachment attachment) {
    value = value.where((a) => a != attachment).toList();
  }

  void clear() => value = const [];

  /// Asks whether to pick from the gallery or files, then adds the picks.
  Future<void> pick(BuildContext context) async {
    final source = await showModalBottomSheet<_AttachSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _AttachSourceSheet(),
    );
    if (source == null) return;

    try {
      switch (source) {
        case _AttachSource.gallery:
          final images = await ImagePicker().pickMultiImage();
          addAll(images.map((x) => ChatAttachment(
                path: x.path,
                name: x.name,
                isImage: true,
              )));
        case _AttachSource.files:
          final result = await FilePicker.pickFiles(allowMultiple: true);
          if (result == null) return;
          addAll(result.files
              .where((f) => f.path != null)
              .map((f) => ChatAttachment.fromPath(f.path!, name: f.name)));
      }
    } catch (e) {
      debugPrint('Attachment pick failed: $e');
    }
  }
}

/// Horizontal row of attachment chips shown above the chat text field.
/// Renders nothing while there are no attachments.
class ChatAttachmentStrip extends StatelessWidget {
  final ChatAttachmentController controller;

  const ChatAttachmentStrip({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ChatAttachment>>(
      valueListenable: controller,
      builder: (context, attachments, _) => AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topLeft,
        child: attachments.isEmpty
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: ChatAttachmentChip.height,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: attachments.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final attachment = attachments[index];
                      return ChatAttachmentChip(
                        key: ValueKey(attachment.path),
                        attachment: attachment,
                        onRemove: () => controller.remove(attachment),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}

/// Pill for one attachment: an image thumbnail, or the file name, each with
/// a remove button.
class ChatAttachmentChip extends StatelessWidget {
  final ChatAttachment attachment;
  final VoidCallback? onRemove;

  static const double height = 52;

  const ChatAttachmentChip({
    super.key,
    required this.attachment,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return attachment.isImage ? _buildImage() : _buildFile();
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        width: 104,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(attachment.path),
              fit: BoxFit.cover,
              cacheWidth: 312,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF2A2A2E),
                child: const Icon(Icons.image_outlined,
                    color: Colors.white54, size: 22),
              ),
            ),
            if (onRemove != null)
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFile() {
    return Container(
      height: height,
      padding: EdgeInsets.only(left: 16, right: onRemove != null ? 8 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2E),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            shortenFileName(attachment.name),
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Color(0xFF2A2A2E), size: 15),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }

  /// Trims the middle of long names but keeps the start and the extension,
  /// e.g. "Meditation Progress Report.pdf" -> "Meditat ... Report.pdf".
  static String shortenFileName(String name, {int maxLength = 20}) {
    if (name.length <= maxLength) return name;
    final dot = name.lastIndexOf('.');
    final ext = dot > 0 ? name.substring(dot) : '';
    final base = dot > 0 ? name.substring(0, dot) : name;
    const head = 7;
    if (base.length <= head + 3) return name;
    final tail = (maxLength - head - ext.length).clamp(3, base.length - head);
    return '${base.substring(0, head).trimRight()} ... '
        '${base.substring(base.length - tail).trimLeft()}$ext';
  }
}

enum _AttachSource { gallery, files }

class _AttachSourceSheet extends StatelessWidget {
  const _AttachSourceSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141416),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 32, left: 24, right: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select an option',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _option(context, Icons.image_outlined, 'Gallery',
              _AttachSource.gallery),
          _option(context, Icons.description_outlined, 'Files',
              _AttachSource.files),
        ],
      ),
    );
  }

  Widget _option(
      BuildContext context, IconData icon, String title, _AttachSource source) {
    return InkWell(
      onTap: () => Navigator.pop(context, source),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
