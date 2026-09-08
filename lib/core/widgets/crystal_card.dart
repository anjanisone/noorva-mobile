import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'crystal_border_painter.dart';

class CrystalCard extends StatelessWidget {
  final String? title;
  final String? description;
  final Widget? child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final bool showBorder;
  final Color? borderColor;
  final double? width;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final double blurSigmaX;
  final double blurSigmaY;
  final Gradient? gradient;

  const CrystalCard({
    super.key,
    this.title,
    this.description,
    this.child,
    this.padding,
    this.borderRadius = 40.0,
    this.backgroundColor,
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.showBorder = true,
    this.borderColor,
    this.width,
    this.titleStyle,
    this.descriptionStyle,
    this.blurSigmaX = 16.0,
    this.blurSigmaY = 16.0,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: showBorder && borderColor == null
          ? CrystalBorderPainter(
              borderRadius: borderRadius,
              strokeWidth: 1.0,
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigmaX, sigmaY: blurSigmaY),
          child: Container(
            width: width ?? double.infinity,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: gradient == null && backgroundColor == null
                  ? const Color(0xCC18191D)
                  : null,
              gradient: gradient ?? (backgroundColor != null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        backgroundColor!.withValues(alpha: 0.25),
                        backgroundColor!.withValues(alpha: 0.1),
                      ],
                    )
                  : null),
              borderRadius: BorderRadius.circular(borderRadius),
              border: showBorder && borderColor != null
                  ? Border.all(color: borderColor!, width: 1.0)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: mainAxisSize,
              crossAxisAlignment: crossAxisAlignment,
              children: [
                if (title != null && title!.isNotEmpty)
                  Text(
                    title!,
                    style: titleStyle ??
                        GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.8,
                          height: 1.15,
                        ),
                  ),
                if (title != null &&
                    title!.isNotEmpty &&
                    ((description != null && description!.isNotEmpty) || child != null))
                  const SizedBox(height: 16),
                if (description != null && description!.isNotEmpty)
                  Text(
                    description!,
                    style: descriptionStyle ??
                        GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: 15,
                          height: 1.5,
                        ),
                  ),
                if (description != null && description!.isNotEmpty && child != null)
                  const SizedBox(height: 24),
                if (child != null) child!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
