import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Full-screen image viewer page.
///
/// Returns a [String] result via [Navigator.pop]:
///   - `'copied'`     → caller shows "Image Copied" grey toast
///   - `'failed'`     → caller shows red error toast (download failed)
///   - `'reported'`   → no toast, just logs
///   - `null`         → user pressed back without action
class ImageViewerPage extends StatefulWidget {
  final String imagePath;

  const ImageViewerPage({super.key, required this.imagePath});

  static Future<String?> push(BuildContext context, String imagePath) {
    return Navigator.push<String>(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ImageViewerPage(imagePath: imagePath),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  static bool _shouldFailDownload = true;
  // ── 3-dot popup key for positioning ──────────────────────────────────────
  final GlobalKey _menuKey = GlobalKey();

  void _showContextMenu() async {
    final RenderBox box =
        _menuKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset buttonPos = box.localToGlobal(Offset.zero, ancestor: overlay);
    final RelativeRect position = RelativeRect.fromLTRB(
      buttonPos.dx - 160, // menu opens to the left of the button
      buttonPos.dy + box.size.height + 4,
      overlay.size.width - buttonPos.dx - box.size.width,
      0,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      color: const Color(0xFF1E1E21),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      elevation: 12,
      items: [
        PopupMenuItem<String>(
          value: 'copy',
          padding: EdgeInsets.zero,
          child: _buildPopupItem(
            icon: Icons.copy_outlined,
            label: 'Copy Image',
          ),
        ),
        PopupMenuItem<String>(
          value: 'report',
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 1, color: AppColors.borderLight),
              _buildPopupItem(
                icon: Icons.flag_circle_outlined,
                label: 'Report an Issue',
              ),
            ],
          ),
        ),
      ],
    );

    if (!mounted) return;

    if (result == 'copy') {
      Navigator.pop(context, 'copied');
    } else if (result == 'report') {
      debugPrint('[ImageViewer] Issue reported for ${widget.imagePath}');
      Navigator.pop(context, 'reported');
    }
  }

  Widget _buildPopupItem({required IconData icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Full-screen image ─────────────────────────────────────────────
          Positioned(
            top: topPad + 72,
            left: 12,
            right: 12,
            bottom: 96 + bottomPad,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.selection,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white24,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Top bar: back + 3-dot ─────────────────────────────────────────
          Positioned(
            top: topPad + 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: _buildCircleButton(
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),

                // 3-dot menu button
                GestureDetector(
                  key: _menuKey,
                  onTap: _showContextMenu,
                  child: _buildCircleButton(
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Download Image button ─────────────────────────────────────────
          Positioned(
            left: 12,
            right: 12,
            bottom: 20 + bottomPad,
            child: GestureDetector(
              onTap: () {
                if (_shouldFailDownload) {
                  _shouldFailDownload = false;
                  Navigator.pop(context, 'failed');
                } else {
                  _shouldFailDownload = true;
                  Navigator.pop(context, 'downloaded');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  'Download Image',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required Widget child}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(child: child),
    );
  }
}
