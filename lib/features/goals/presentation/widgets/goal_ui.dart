import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared visual tokens and building blocks for the Goals screens.
class GoalUi {
  GoalUi._();

  static const Color card = Color(0xFF1A1B1E);
  static const Color cardBorder = Color(0xFF2E2F33);
  static const Color inset = Color(0xFF111214);
  static const Color secondaryButton = Color(0xFF2E2F33);
  static const Color progressTrack = Color(0xFF2E2F33);
  static const Color progressFill = Color(0xFF4CC35A);
  static const Color danger = Color(0xFFF08080);

  static const Color textBody = Color(0xFFCFCFD1);
  static const Color textMuted = Color(0xFFA5A5A8);

  static const TextStyle cardTitle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static const TextStyle body = TextStyle(
    color: textBody,
    fontSize: 15,
    height: 1.3,
  );

  static BoxDecoration cardDecoration({double radius = 20}) => BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: cardBorder),
      );

  // Tag colours as (background, border).
  static const (Color, Color) tagRed = (Color(0xFF7A2424), Color(0xFFA53A3A));
  static const (Color, Color) tagAmber = (Color(0xFF5E3C12), Color(0xFF8C5E24));
  static const (Color, Color) tagBlue = (Color(0xFF1B4D66), Color(0xFF2C7196));
  static const (Color, Color) tagGreen = (Color(0xFF2F5A35), Color(0xFF4C8A55));

  /// Tag colours for a 'high' / 'medium' / 'low' priority.
  static (Color, Color) priorityColors(String priority) {
    final p = priority.toLowerCase();
    if (p.contains('high')) return tagRed;
    if (p.contains('low')) return tagBlue;
    return tagAmber;
  }
}

/// Small filled pill tag, e.g. "High Priority" or "Completed".
class GoalTag extends StatelessWidget {
  final String label;
  final (Color, Color) colors;

  const GoalTag({super.key, required this.label, required this.colors});

  /// Tag for a priority label such as "High Priority".
  GoalTag.priority(String priority, {super.key})
      : label = priority,
        colors = GoalUi.priorityColors(priority);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.$2),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Color(0xFFF2F2F2), fontSize: 12.5),
      ),
    );
  }
}

class GoalCircleButton extends StatelessWidget {
  final String asset;
  final double size;
  final VoidCallback? onTap;

  const GoalCircleButton({
    super.key,
    required this.asset,
    this.size = 40,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: GoalUi.card,
          border: Border.all(color: GoalUi.cardBorder),
        ),
        child: Center(
          child: Image.asset(
            asset,
            width: size * 0.48,
            height: size * 0.48,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Back button on the left, optional centred title, edit button on the right.
class GoalAppBar extends StatelessWidget {
  final String? title;
  final VoidCallback? onEdit;
  final bool showEdit;

  const GoalAppBar({
    super.key,
    this.title,
    this.onEdit,
    this.showEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SizedBox(
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: GoalCircleButton(
                asset: 'assets/icons/back_arrow.png',
                size: 36,
                onTap: () => Navigator.pop(context),
              ),
            ),
            if (showEdit)
              Align(
                alignment: Alignment.centerRight,
                child: GoalCircleButton(
                  asset: 'assets/icons/edit.png',
                  onTap: onEdit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Thin rounded progress bar that animates to [progress] (0–100).
class GoalProgressBar extends StatelessWidget {
  final int progress;

  const GoalProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 5,
        child: Stack(
          children: [
            Container(color: GoalUi.progressTrack),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: (progress / 100).clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: GoalUi.progressFill,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress bar with the percentage label on its right.
class GoalProgressRow extends StatelessWidget {
  final int progress;

  const GoalProgressRow({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: GoalProgressBar(progress: progress)),
        const SizedBox(width: 22),
        Text(
          '$progress%',
          style: const TextStyle(color: Color(0xFFE5E5E7), fontSize: 13),
        ),
      ],
    );
  }
}

/// Pill segmented control with a sliding outlined indicator.
class GoalSegmentControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const GoalSegmentControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: GoalUi.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GoalUi.cardBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / labels.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: segmentWidth * selectedIndex,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4A4B50)),
                  ),
                ),
              ),
              Row(
                children: List.generate(labels.length, (i) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            labels[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Full-width capsule button (white primary or dark secondary).
class GoalPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final double height;

  const GoalPillButton({
    super.key,
    required this.label,
    this.onTap,
    this.primary = true,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? Colors.white : GoalUi.secondaryButton,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: primary ? const Color(0xFF111113) : Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
