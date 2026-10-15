import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_mascot.dart';

class RateNoorvaPage extends StatefulWidget {
  const RateNoorvaPage({super.key});

  @override
  State<RateNoorvaPage> createState() => _RateNoorvaPageState();
}

class _RateNoorvaPageState extends State<RateNoorvaPage> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Rate Noorva',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Spacer to balance back button
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Character
                    const NoorvaMascot(mood: MascotMood.hello, height: 280),
                    const SizedBox(height: 32),
                    Text(
                      'Enjoying Noorva?',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your feedback helps us improve\nand reach more people.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Rating Card
                    CrystalCard(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Text(
                            'Tap a star to rate',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return GestureDetector(
                                onTap: () => setState(() => _rating = index + 1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    index < _rating ? Icons.star : Icons.star_border,
                                    color: index < _rating ? Colors.amber : Colors.white.withValues(alpha: 0.6),
                                    size: 32,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Items
                    CrystalCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _buildActionItem(
                            icon: Icons.chat_bubble_outline,
                            title: 'Write a review',
                            onTap: () {
                              // Handle review
                            },
                          ),
                          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                          _buildActionItem(
                            icon: Icons.share_outlined,
                            title: 'Share Noorva',
                            onTap: () => _showShareSheet(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.4), size: 24),
          ],
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _MockShareSheet(),
    );
  }
}

class _MockShareSheet extends StatelessWidget {
  const _MockShareSheet();

  static const String _shareText = 'Discover Noorva: your premium companion! Download the app at: https://noorva.app/download';

  Future<void> _shareDirect(BuildContext context, String appName) async {
    // Close the sheet first
    Navigator.pop(context);

    try {
      if (appName == 'WhatsApp') {
        final whatsappUrl = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(_shareText)}');
        final whatsappWebUrl = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(_shareText)}');
        
        if (await canLaunchUrl(whatsappUrl)) {
          await launchUrl(whatsappUrl);
        } else {
          await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
        }
      } else if (appName == 'Mail') {
        final emailUrl = Uri.parse('mailto:?subject=${Uri.encodeComponent('Enjoying Noorva?')}&body=${Uri.encodeComponent(_shareText)}');
        if (await canLaunchUrl(emailUrl)) {
          await launchUrl(emailUrl);
        } else {
          await Share.share(_shareText);
        }
      } else if (appName == 'Messages') {
        final smsUrl = Uri.parse('sms:?body=${Uri.encodeComponent(_shareText)}');
        if (await canLaunchUrl(smsUrl)) {
          await launchUrl(smsUrl);
        } else {
          await Share.share(_shareText);
        }
      } else {
        await Share.share(_shareText);
      }
    } catch (e) {
      await Share.share(_shareText);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color sheetBgColor = Color(0xFF2C2C2E);

    return Container(
      decoration: const BoxDecoration(
        color: sheetBgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 20),

          // Contacts horizontal scrolling list
          SizedBox(
            height: 88,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShareContact(
                    context,
                    name: 'Sandy Wild...',
                    avatar: Image.asset(
                      'assets/images/sandy_wild.png',
                      fit: BoxFit.cover,
                    ),
                    sheetBgColor: sheetBgColor,
                  ),
                  _buildShareContact(
                    context,
                    name: 'Kevin Leong',
                    avatar: Image.asset(
                      'assets/images/kevin_leong.png',
                      fit: BoxFit.cover,
                    ),
                    sheetBgColor: sheetBgColor,
                  ),
                  _buildShareContact(
                    context,
                    name: 'Sandy and...',
                    avatar: const GroupAvatar(
                      backImage: 'assets/images/sandy_wild.png',
                      frontImage: 'assets/images/kevin_leong.png',
                      sheetBgColor: sheetBgColor,
                    ),
                    sheetBgColor: sheetBgColor,
                  ),
                  _buildShareContact(
                    context,
                    name: 'Juliana Mejia',
                    avatar: Image.asset(
                      'assets/images/juliana_mejia.png',
                      fit: BoxFit.cover,
                    ),
                    sheetBgColor: sheetBgColor,
                  ),
                  _buildShareContact(
                    context,
                    name: 'Gr...',
                    avatar: Image.asset(
                      'assets/images/gregory.png',
                      fit: BoxFit.cover,
                    ),
                    sheetBgColor: sheetBgColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Apps horizontal scrolling list
          SizedBox(
            height: 88,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShareApp(
                    name: 'AirDrop',
                    iconWidget: const AirDropIcon(),
                    onTap: () => _shareDirect(context, 'AirDrop'),
                  ),
                  _buildShareApp(
                    name: 'Messages',
                    iconWidget: const MessagesIcon(),
                    onTap: () => _shareDirect(context, 'Messages'),
                  ),
                  _buildShareApp(
                    name: 'WhatsApp',
                    iconWidget: const WhatsAppIcon(),
                    onTap: () => _shareDirect(context, 'WhatsApp'),
                  ),
                  _buildShareApp(
                    name: 'Gmail',
                    iconWidget: const GmailIcon(),
                    onTap: () => _shareDirect(context, 'Mail'),
                  ),
                  _buildShareApp(
                    name: 'Notes',
                    iconWidget: const NotesIcon(),
                    onTap: () => _shareDirect(context, 'Notes'),
                  ),
                  _buildShareApp(
                    name: 'Remi...',
                    iconWidget: const RemindersIcon(),
                    onTap: () => _shareDirect(context, 'Reminders'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Copy link action card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: 'https://noorva.app/download'));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Link copied to clipboard',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    backgroundColor: const Color(0xFF1C1C1E),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Copy link',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.copy_rounded,
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareContact(
    BuildContext context, {
    required String name,
    required Widget avatar,
    required Color sheetBgColor,
  }) {
    return GestureDetector(
      onTap: () => _shareDirect(context, 'SystemShare'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1C1C1E),
                    ),
                    child: ClipOval(child: avatar),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759),
                        shape: BoxShape.circle,
                        border: Border.all(color: sheetBgColor, width: 2),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareApp({
    required String name,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupAvatar extends StatelessWidget {
  final String backImage;
  final String frontImage;
  final Color sheetBgColor;

  const GroupAvatar({
    super.key,
    required this.backImage,
    required this.frontImage,
    required this.sheetBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          // Back avatar
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: sheetBgColor, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  backImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Front avatar
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: sheetBgColor, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  frontImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AirDropIcon extends StatelessWidget {
  const AirDropIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(36, 36),
          painter: _AirDropPainter(),
        ),
      ),
    );
  }
}

class _AirDropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF007AFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    // Center dot
    final dotPaint = Paint()
      ..color = const Color(0xFF007AFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.2, dotPaint);

    paint.style = PaintingStyle.stroke;

    final radii = [6.5, 11.5, 16.5];

    for (var r in radii) {
      // Left arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        115 * 3.1415926535 / 180,
        130 * 3.1415926535 / 180,
        false,
        paint,
      );

      // Right arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -65 * 3.1415926535 / 180,
        130 * 3.1415926535 / 180,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MessagesIcon extends StatelessWidget {
  const MessagesIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF34C759), Color(0xFF30D158)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(13.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.chat_bubble_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class WhatsAppIcon extends StatelessWidget {
  const WhatsAppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF25D366),
        borderRadius: BorderRadius.circular(13.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.call,
          color: Colors.white,
          size: 36,
        ),
      ),
    );
  }
}

class GmailIcon extends StatelessWidget {
  const GmailIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(28, 20),
          painter: _GmailPainter(),
        ),
      ),
    );
  }
}

class _GmailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;

    // Draw left bar (blue)
    final leftPath = Path()
      ..moveTo(0, 2)
      ..lineTo(0, h - 2)
      ..lineTo(4, h - 2)
      ..lineTo(4, 5)
      ..close();
    canvas.drawPath(leftPath, paintBlue);

    // Draw right bar (green)
    final rightPath = Path()
      ..moveTo(w, 2)
      ..lineTo(w, h - 2)
      ..lineTo(w - 4, h - 2)
      ..lineTo(w - 4, 5)
      ..close();
    canvas.drawPath(rightPath, paintGreen);

    // Draw middle V fold (red)
    final redPath = Path()
      ..moveTo(0, 2)
      ..lineTo(w / 2, h / 2 + 1)
      ..lineTo(w, 2)
      ..lineTo(w - 4, 2)
      ..lineTo(w / 2, h / 2 - 2)
      ..lineTo(4, 2)
      ..close();
    canvas.drawPath(redPath, paintRed);

    // Draw top corners
    final yellowLeft = Path()
      ..moveTo(0, 2)
      ..lineTo(4, 2)
      ..lineTo(4, 5)
      ..close();
    canvas.drawPath(yellowLeft, paintYellow);

    final yellowRight = Path()
      ..moveTo(w, 2)
      ..lineTo(w - 4, 2)
      ..lineTo(w - 4, 5)
      ..close();
    canvas.drawPath(yellowRight, paintYellow);

    // Draw bottom bar connecting (red)
    final bottomPath = Path()
      ..moveTo(0, h - 2)
      ..lineTo(w, h - 2)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(bottomPath, paintRed);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MailIcon extends StatelessWidget {
  const MailIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B9BF4), Color(0xFF1D74E7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(13.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.mail_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class NotesIcon extends StatelessWidget {
  const NotesIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13.5),
        child: Column(
          children: [
            Container(
              height: 14,
              color: const Color(0xFFFFCC00),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 1.5, color: const Color(0xFFE5E5EA)),
                    Container(height: 1.5, color: const Color(0xFFE5E5EA)),
                    Container(height: 1.5, color: const Color(0xFFE5E5EA)),
                    Container(height: 1.5, color: const Color(0xFFE5E5EA)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RemindersIcon extends StatelessWidget {
  const RemindersIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildRow(const Color(0xFF007AFF)),
          _buildRow(const Color(0xFFFF3B30)),
          _buildRow(const Color(0xFFFF9500)),
        ],
      ),
    );
  }

  Widget _buildRow(Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    );
  }
}
