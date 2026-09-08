import 'package:flutter/material.dart';

class SourcesWebViewPage extends StatelessWidget {
  final String title;
  final String url;

  const SourcesWebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mock Browser content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // APA website mock header
                    if (title.contains('Psychological')) ...[
                      _buildApaHeader(),
                      _buildApaArticleContent(),
                    ] else if (title.contains('Harvard')) ...[
                      _buildHarvardHeader(),
                      _buildHarvardArticleContent(),
                    ] else ...[
                      _buildForbesHeader(),
                      _buildForbesArticleContent(),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            _buildBottomBrowserBar(context),
          ],
        ),
      ),
    );
  }

  // ── APA Page ──────────────────────────────────────────────────────────────

  Widget _buildApaHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F4C81),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'Ψ',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AMERICAN',
                    style: TextStyle(color: Color(0xFF0F4C81), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  Text(
                    'PSYCHOLOGICAL',
                    style: TextStyle(color: Color(0xFF0F4C81), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  Text(
                    'ASSOCIATION',
                    style: TextStyle(color: Color(0xFF0F4C81), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
          const Row(
            children: [
              Icon(Icons.search, color: Colors.black87, size: 28),
              SizedBox(width: 16),
              Icon(Icons.menu, color: Colors.black87, size: 28),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApaArticleContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/personalization.png', // Fallback or existing image
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 200,
                color: const Color(0xFFF5F5F5),
                child: const Icon(Icons.image, color: Colors.grey, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mental health in uncertain times:\n5 key takeaways',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'APA CEO Arthur C. Evans Jr. and APHA CEO Georges C. Benjamin discuss how chronic societal stress can "get under the skin," harming mental and physical health.',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'RELATED: LISTEN TO THE FULL CONVERSATION >',
            style: TextStyle(
              color: Color(0xFF0F4C81),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Raising the bar for digital mental health',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Research demonstrating how regular mindfulness meditation strengthens neural pathways, significantly improving the brain\'s ability to refocus attention after distractions.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Harvard Page ──────────────────────────────────────────────────────────

  Widget _buildHarvardHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF8C1D40), // Crimson
        border: Border(bottom: BorderSide(color: Color(0xFF7A1535))),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'HARVARD MEDICAL SCHOOL',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          Icon(Icons.menu, color: Colors.white, size: 24),
        ],
      ),
    );
  }

  Widget _buildHarvardArticleContent() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mindfulness & Health',
            style: TextStyle(
              color: Color(0xFF8C1D40),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'What meditation does to your brain and body',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Clinical findings detailing how daily meditation physically lowers resting cortisol levels, shifting the body\'s baseline response from anxiety to clarity.',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Harvard researchers study how mindfulness may change brain structures, showing substantial increases in gray matter density in the hippocampus, known to be important for learning and memory.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Forbes Page ───────────────────────────────────────────────────────────

  Widget _buildForbesHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: const Center(
        child: Text(
          'Forbes',
          style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'serif'),
        ),
      ),
    );
  }

  Widget _buildForbesArticleContent() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leadership & Mindfulness',
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Why top executives are adopting daily meditation routines',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'In today\'s hyper-connected business environment, the ability to focus and maintain psychological resilience is a competitive advantage. Forbes explores how structured mindfulness programs improve executive decision-making and decrease workplace stress.',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Browser Bottom Bar ────────────────────────────────────────────────────

  Widget _buildBottomBrowserBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(Icons.arrow_back_ios_new, color: Colors.black45, size: 20),
          const Icon(Icons.arrow_forward_ios, color: Colors.black45, size: 20),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.ios_share, color: Colors.black87, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link shared successfully!')),
              );
            },
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.open_in_browser, color: Colors.black87, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening in system browser...')),
              );
            },
          ),
        ],
      ),
    );
  }
}
