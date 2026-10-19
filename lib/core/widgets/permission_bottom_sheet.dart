import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'noorva_mascot.dart';

class PermissionBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final List<PermissionAction> actions;

  const PermissionBottomSheet ({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF111113),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Content Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NoorvaMascot(
                mood: MascotMood.explaining,
                height: 120,
                fallbackAsset: imagePath,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  description,
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 18,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // Actions
          ...actions.map((action) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: action.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: action.isPrimary
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.1),
                  foregroundColor:
                      action.isPrimary ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  action.label,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  static void show({
    required BuildContext context,
    required String title,
    required String description,
    required String imagePath,
    required List<PermissionAction> actions,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => PermissionBottomSheet(
        title: title,
        description: description,
        imagePath: imagePath,
        actions: actions,
      ),
    );
  }
}

class PermissionAction {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  PermissionAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });
}
