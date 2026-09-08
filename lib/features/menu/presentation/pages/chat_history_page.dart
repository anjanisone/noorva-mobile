import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/crystal_card.dart';
import '../../../../core/widgets/noorva_delete_dialog.dart';

class ChatHistoryPage extends StatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  State<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  // Single unified list containing all conversations
  final List<Map<String, dynamic>> _allChats = [
    {
      'title': 'Biological effects of dopamine fasting',
      'time': 'Monday, 9:00 AM',
      'starred': true,
      'category': 'recent',
    },
    {
      'title': 'The cognitive cost of context switching',
      'time': 'Monday, 9:00 AM',
      'starred': false,
      'category': 'recent',
    },
    {
      'title': 'PWA vs. Native architecture for productivity tools',
      'time': 'Monday, 9:00 AM',
      'starred': false,
      'category': 'recent',
    },
    {
      'title': 'Navigating project overwhelm',
      'time': 'Tuesday, 4:15 PM',
      'starred': false,
      'category': 'guide',
    },
    {
      'title': 'Finding inner peace with meditation',
      'time': 'Monday, 9:00 AM',
      'starred': false,
      'category': 'guide',
    },
    {
      'title': 'Afternoon energy reset plan',
      'time': '20 Apr 2026, 4:00 PM',
      'starred': false,
      'category': 'guide',
    },
  ];

  Widget _buildUnstarIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.star_border_rounded, color: Colors.white, size: 20),
        Transform.rotate(
          angle: -0.785, // ~45 degrees diagonal
          child: Container(
            width: 3,
            height: 18,
            color: const Color(0xFF1E1E22), // matches popup menu background color to mask
          ),
        ),
        Transform.rotate(
          angle: -0.785,
          child: Container(
            width: 1.2,
            height: 18,
            color: Colors.white, // slash line
          ),
        ),
      ],
    );
  }

  void _showContextMenu(BuildContext context, Offset tapPosition, Map<String, dynamic> chat) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final bool isStarred = chat['starred'] ?? false;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        tapPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      color: const Color(0xFF1E1E22),
      elevation: 8,
      items: [
        PopupMenuItem<String>(
          value: 'star',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              isStarred
                  ? _buildUnstarIcon()
                  : const Icon(Icons.star_border_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                isStarred ? 'Unstar' : 'Star',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'rename',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Image.asset(
                'assets/icons/edit.png',
                color: Colors.white,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Rename Conversation',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFFF5252), // coral/red deletion color from screenshot
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Delete',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFFF5252),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == null) return;
      if (value == 'star') {
        setState(() {
          chat['starred'] = !isStarred;
        });
      } else if (value == 'rename') {
        _showRenameDialog(chat);
      } else if (value == 'delete') {
        _showDeleteDialog(chat);
      }
    });
  }

  void _showRenameDialog(Map<String, dynamic> chat) {
    final TextEditingController renameController = TextEditingController(text: chat['title']);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF151517),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rename conversation',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: renameController,
                autofocus: true,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1C1C1E),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (renameController.text.trim().isNotEmpty) {
                          setState(() {
                            chat['title'] = renameController.text.trim();
                          });
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(
                        'Update',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> chat) {
    showDialog(
      context: context,
      builder: (context) {
        return NoorvaDeleteDialog(
          title: 'Delete Conversation',
          content: 'You have chosen to clear the memory of this dialogue. Once released, these words and the context we built here will return to the void permanently. Are you ready to close this chapter and move forward?',
          onConfirm: () {
            setState(() {
              _allChats.remove(chat);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtered lists based on search query
    final List<Map<String, dynamic>> filteredAll = _allChats
        .where((chat) => chat['title']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Grouping filtered items
    final List<Map<String, dynamic>> starredChats = filteredAll.where((chat) => chat['starred'] == true).toList();
    final List<Map<String, dynamic>> recentChats = filteredAll.where((chat) => chat['category'] == 'recent' && chat['starred'] != true).toList();
    final List<Map<String, dynamic>> noorvaGuideChats = filteredAll.where((chat) => chat['category'] == 'guide' && chat['starred'] != true).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Chat History',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Image.asset(
                      'assets/icons/edit.png',
                      color: Colors.white,
                      width: 22,
                      height: 22,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF151517),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      _isSearching = val.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 16,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    border: InputBorder.none,
                    suffixIcon: _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.white54),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _isSearching = false;
                              });
                            },
                          )
                        : Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Icon(
                              Icons.search,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 24,
                            ),
                          ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Chat List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  if (starredChats.isNotEmpty) ...[
                    _buildSectionHeader('Starred Chats'),
                    const SizedBox(height: 12),
                    _buildChatGroup(starredChats),
                    const SizedBox(height: 24),
                  ],
                  if (recentChats.isNotEmpty) ...[
                    _buildSectionHeader('Recent Chats'),
                    const SizedBox(height: 12),
                    _buildChatGroup(recentChats),
                    const SizedBox(height: 24),
                  ],
                  if (noorvaGuideChats.isNotEmpty) ...[
                    _buildSectionHeader('Noorva Guide Chats'),
                    const SizedBox(height: 12),
                    _buildChatGroup(noorvaGuideChats),
                    const SizedBox(height: 24),
                  ],
                  if (starredChats.isEmpty && recentChats.isEmpty && noorvaGuideChats.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      child: Column(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Colors.white.withValues(alpha: 0.2),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations found',
                            style: GoogleFonts.outfit(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildChatGroup(List<Map<String, dynamic>> chats) {
    return CrystalCard(
      padding: EdgeInsets.zero,
      borderRadius: 24.0, // smaller border radius as per screenshots
      child: Column(
        children: [
          ...chats.asMap().entries.map((entry) {
            final index = entry.key;
            final chat = entry.value;
            return Column(
              children: [
                _buildChatItem(chat),
                if (index < chats.length - 1)
                  Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              ],
            );
          }),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              onTap: () {
                // Click action
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                child: Text(
                  'View All',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    return ListTile(
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        chat['title']!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          chat['time']!,
          style: GoogleFonts.outfit(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      trailing: GestureDetector(
        onTapDown: (details) {
          _showContextMenu(context, details.globalPosition, chat);
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.transparent,
          child: Icon(
            Icons.more_horiz,
            color: Colors.white.withValues(alpha: 0.6),
            size: 24,
          ),
        ),
      ),
    );
  }
}
