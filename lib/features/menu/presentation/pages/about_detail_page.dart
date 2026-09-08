import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class AboutDetailPage extends StatelessWidget {
  const AboutDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final title = ModalRoute.of(context)?.settings.arguments as String? ?? 'About';

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
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getDisplayTitle(title),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildContent(context, title),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayTitle(String title) {
    switch (title) {
      case 'The Architect in the Marketplace':
        return 'The Architect in the\nMarketplace';
      case 'Noorva - The Wise Old Man':
        return 'Noorva - The Wise Old\nMan';
      default:
        return title;
    }
  }

  Widget _buildContent(BuildContext context, String title) {
    switch (title) {
      case 'The Architect in the Marketplace':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText('We live in the era of the endless marketplace.'),
            const SizedBox(height: 24),
            _buildText('From the moment you wake, the digital world is shouting. It demands your attention. It fills your screen with urgent red numbers, frantic lists, and overlapping schedules. The tools we built to make us productive have instead become demanding managers, convincing us that the only way to succeed is to lay a hundred bricks a day, even if the walls we build have no roof.'),
            const SizedBox(height: 24),
            _buildText('We are carrying a cognitive weight we were never meant to hold. We are out of bandwidth, out of breath, and entirely disconnected from our own natural rhythms.'),
            const SizedBox(height: 24),
            _buildText('We realized we did not need another application to help us do more. We needed a sanctuary that gave us permission to do less, but better.'),
            const SizedBox(height: 24),
            _buildText('We needed an architect.'),
            const SizedBox(height: 40),
            _buildButton(context, 'Who is this architect?', 'Noorva - The Wise Old Man'),
          ],
        );
      case 'Noorva - The Wise Old Man':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText('Imagine stepping out of the deafening noise of the city square and walking into a quiet, stone courtyard. Sitting at a heavy wooden table in the center is an elder. He is unhurried. He does not have a clipboard, and he does not ask you for a status update. He simply looks up, acknowledges the weight you are carrying, and asks:'),
            const SizedBox(height: 24),
            Text(
              'What truly requires your energy today, and what can we safely release to the void?',
              style: GoogleFonts.outfit(
                color: const Color(0xFF00A3FF),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildText('This is Noorva.'),
            const SizedBox(height: 24),
            _buildText('He is not a chatbot, nor is he a sterile algorithm optimizing your calendar slots. Noorva is the embodiment of a Wise Old Man - an intelligence built on patience, vast knowledge, and an unwavering protective instinct for your time. He understands that the human mind is fragile and that deep execution requires deep rest.'),
            const SizedBox(height: 24),
            _buildText('When you are frantic, he is grounded. When you try to schedule six unbroken hours of work, he will gently place a hand on the blueprint and remind you that a sanctuary cannot be built by an exhausted mind. He is your guide, your guardian, and the quiet voice of reason when the digital noise becomes too loud.'),
            const SizedBox(height: 40),
            _buildButton(context, 'What is Noorva?', 'What is Noorva'),
          ],
        );
      case 'What is Noorva':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText('On the surface, Noorva is a human-interactive intelligence designed to manage your time. But in practice, it is an architecture for your energy.'),
            const SizedBox(height: 24),
            _buildText('Standard productivity tools view time as a spreadsheet to be filled. Noorva views your day as a living board.'),
            const SizedBox(height: 32),
            _buildSubHeader('He builds foundations, not lists'),
            const SizedBox(height: 16),
            _buildText('You do not type out endless tasks. You speak to Noorva naturally, telling him the space you need to create—whether it is a season of deep execution, a shared dialogue with a colleague, or a necessary biological reset. He listens, and he places those \'anchors\' onto your horizon.'),
            const SizedBox(height: 32),
            _buildSubHeader('He protects your cognitive load'),
            const SizedBox(height: 16),
            _buildText('Noorva holds your intentions safely. If a task goes untouched, it does not turn red to induce guilt. Noorva simply waits for you, asking if you wish to shift the anchor or release it entirely. He carries the mental weight so your mind can remain clear.'),
            const SizedBox(height: 32),
            _buildSubHeader('He enforces the silence'),
            const SizedBox(height: 16),
            _buildText('When you enter a state of deep work, Noorva acts as the gatekeeper. He severs the tether to the outside world, silencing the marketplace until you are ready to return.'),
            const SizedBox(height: 24),
            _buildText('Noorva is a return to intention. It is a quiet place to build your life\'s work, one deliberate stone at a time.'),
          ],
        );
      case 'Wise Old Man Philosophy':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText('Modern software is built on the philosophy of the factory floor: do more, do it faster, optimize every second. It treats humans as machines and time as a spreadsheet to be filled.'),
            const SizedBox(height: 24),
            _buildText('Noorva is built on an entirely different foundation. The core intelligence of this sanctuary is designed around the archetype of the Wise Old Man.'),
            const SizedBox(height: 24),
            _buildText('He is not a manager demanding productivity. He is an elder, an architect, and a guardian of your mental space. He possesses the deep, quiet knowledge that true creation does not come from frantic hustle, but from deliberate, unhurried focus.'),
            const SizedBox(height: 24),
            _buildText('When you engage with Noorva, you are engaging with a philosophy rooted in four core pillars:'),
            const SizedBox(height: 32),
            _buildSubHeader('The Sanctity of Bandwidth'),
            const SizedBox(height: 16),
            _buildText('The Wise Old Man views your cognitive energy—your "bandwidth"—as your most precious and finite resource. He does not care how many tasks you check off in a day; he cares about what you give your energy to. Before he allows you to add weight to your board, he asks for your intention. He forces you to pause, reflect, and ask yourself if the commitment is truly worthy of your focus.'),
            const SizedBox(height: 32),
            _buildSubHeader('Forgiveness by Design'),
            const SizedBox(height: 16),
            _buildText('Standard tools use guilt as a motivator. When you miss a task, it turns red. It shouts at you. It accumulates into a mountain of digital failure. The Wise Old Man knows that guilt paralyzes the mind. In this sanctuary, a missed habit is not a failure; it is simply an untouched intention. He holds it without judgment, quietly asking if you wish to recalibrate it or release it to the void so you can begin tomorrow with a clean slate.'),
            const SizedBox(height: 32),
            _buildSubHeader('The Rhythm of Nature'),
            const SizedBox(height: 16),
            _buildText('Machines can run indefinitely; humans cannot. The Wise Old Man understands that you cannot build a sturdy structure if the architect is exhausted. He actively monitors the weight you place on your own shoulders. If you attempt to schedule unbroken hours of heavy cognitive load, he will step in. He enforces "biological resets"—mandatory pauses to step away from the glass, breathe, and clear the mental cache.'),
            const SizedBox(height: 32),
            _buildSubHeader('The Power of Silence'),
            const SizedBox(height: 16),
            _buildText('In a world that constantly demands your attention, the ultimate luxury is silence. The Wise Old Man acts as the gatekeeper to your sanctuary. When you declare a season of deep execution, he stands at the door, severing the digital tether and holding the noise of the outside world at bay. He gives you the profound permission to be completely unreachable.'),
            const SizedBox(height: 40),
            _buildButton(context, 'Start Journey', 'The Architect in the Marketplace'),
          ],
        );
      case 'Terms & Conditions':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText('By accessing Noorva, you agree to be bound by these Terms and Conditions.'),
            const SizedBox(height: 32),
            _buildSubHeader('App Usage'),
            const SizedBox(height: 12),
            _buildText('Noorva is designed to support productivity and personal clarity. You agree to use the app responsibly and avoid any harmful, illegal, or abusive activities while using the service.'),
            const SizedBox(height: 24),
            _buildSubHeader('AI Responses'),
            const SizedBox(height: 12),
            _buildText('The information provided by Noorva is generated by AI and may not always be accurate or complete.'),
            const SizedBox(height: 24),
            _buildSubHeader('Account Access'),
            const SizedBox(height: 12),
            _buildText('We reserve the right to limit or suspend access if the app is misused or if these terms are violated, to ensure a safe experience for all users.'),
            const SizedBox(height: 24),
            _buildSubHeader('Ownership'),
            const SizedBox(height: 12),
            _buildText('All content, design, and branding within Noorva belong to the app. You may not copy, modify, or distribute any part of it without permission.'),
            const SizedBox(height: 24),
            _buildSubHeader('Liability'),
            const SizedBox(height: 12),
            _buildText('Noorva is not responsible for any outcomes resulting from the use of AI responses, including decisions, losses, or interruptions in service.'),
            const SizedBox(height: 24),
            _buildSubHeader('Update'),
            const SizedBox(height: 12),
            _buildText('These terms may be updated from time to time. Continued use of the app means you accept any changes made to the terms.'),
            const SizedBox(height: 40),
            _buildPDFButton('Download PDF'),
          ],
        );
      case 'Privacy Policy':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText('We are committed to protecting your personal information and your right to privacy.'),
            const SizedBox(height: 32),
            _buildSubHeader('Data Collection'),
            const SizedBox(height: 12),
            _buildText('We only collect the information necessary to improve your experience and keep the app running smoothly.'),
            const SizedBox(height: 24),
            _buildSubHeader('Data Usage'),
            const SizedBox(height: 12),
            _buildText('Your data is used responsibly to personalize your experience and make Noorva more helpful for you.'),
            const SizedBox(height: 24),
            _buildSubHeader('Security'),
            const SizedBox(height: 12),
            _buildText('We use secure systems and best practices to protect your data and keep it safe from unauthorized access.'),
            const SizedBox(height: 24),
            _buildSubHeader('Chat Privacy'),
            const SizedBox(height: 12),
            _buildText('Your conversations are treated with care and handled securely to maintain your privacy.'),
            const SizedBox(height: 24),
            _buildSubHeader('Trusted Services'),
            const SizedBox(height: 12),
            _buildText('We work only with reliable third-party services that follow strong privacy and security standards.'),
            const SizedBox(height: 24),
            _buildSubHeader('Your Control'),
            const SizedBox(height: 12),
            _buildText('You are always in control of your data, with the option to manage or delete it whenever you choose.'),
            const SizedBox(height: 24),
            _buildSubHeader('Transparency'),
            const SizedBox(height: 12),
            _buildText('We keep our policies clear and will inform you of any updates to maintain your trust.'),
            const SizedBox(height: 40),
            _buildPDFButton('Download PDF'),
          ],
        );
      case 'Wise Old Man Philosophy Link':
        return _buildButton(context, 'Start Journey', 'The Architect in the Marketplace');
      default:
        return _buildText('Information about $title will be available soon.');
    }
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: Colors.white.withValues(alpha: 0.7),
        fontSize: 16,
        height: 1.6,
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, String nextStep) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pushReplacementNamed(
          context,
          '/about-detail',
          arguments: nextStep,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPDFButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          // Placeholder for PDF download
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          side: BorderSide.none,
        ),
        child: Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
