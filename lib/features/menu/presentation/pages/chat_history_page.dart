import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
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
            color: const Color(
                0xFF1E1E22), // matches popup menu background color to mask
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

  void _showContextMenu(
      BuildContext context, Offset tapPosition, Map<String, dynamic> chat) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
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
                  : const Icon(Icons.star_border_rounded,
                      color: Colors.white, size: 20),
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
                color: Color(
                    0xFFFF5252), // coral/red deletion color from screenshot
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
    final TextEditingController renameController =
        TextEditingController(text: chat['title']);
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
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.15)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
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
          content:
              'You have chosen to clear the memory of this dialogue. Once released, these words and the context we built here will return to the void permanently. Are you ready to close this chapter and move forward?',
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
        .where((chat) =>
            chat['title']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    // Grouping filtered items
    final List<Map<String, dynamic>> starredChats =
        filteredAll.where((chat) => chat['starred'] == true).toList();
    final List<Map<String, dynamic>> recentChats = filteredAll
        .where(
            (chat) => chat['category'] == 'recent' && chat['starred'] != true)
        .toList();
    final List<Map<String, dynamic>> noorvaGuideChats = filteredAll
        .where((chat) => chat['category'] == 'guide' && chat['starred'] != true)
        .toList();

    return PopScope(
      // Back leaves search first, then the page.
      canPop: !_isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _clearSearch();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header Area (collapses while searching)
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _isSearching
                    ? const SizedBox(width: double.infinity, height: 16)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Row(
                          children: [
                            _buildHeaderButton(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.chevron_left,
                                  color: Colors.white, size: 22),
                            ),
                            Expanded(
                              child: Text(
                                'Chat History',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            _buildHeaderButton(
                              child: Image.asset(
                                'assets/icons/edit.png',
                                color: Colors.white,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _borderColor),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: Colors.white,
                    style:
                        GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _isSearching = val.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                      isDense: true,
                      filled: false,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      suffixIcon: _isSearching
                          ? GestureDetector(
                              onTap: _clearSearch,
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 22),
                            )
                          : const Icon(Icons.search,
                              color: Colors.white, size: 24),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 52,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: _isSearching ? 16 : 18),

              // Chat List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Search results: one card per match, no sections.
                    if (_isSearching)
                      for (final chat in filteredAll) ...[
                        _buildSearchResult(chat),
                        const SizedBox(height: 16),
                      ]
                    else ...[
                      if (starredChats.isNotEmpty) ...[
                        _buildSectionHeader('Starred Chats'),
                        const SizedBox(height: 12),
                        _buildChatGroup(starredChats),
                        const SizedBox(height: 16),
                      ],
                      if (recentChats.isNotEmpty) ...[
                        _buildSectionHeader('Recent Chats'),
                        const SizedBox(height: 12),
                        _buildChatGroup(recentChats),
                        const SizedBox(height: 16),
                      ],
                      if (noorvaGuideChats.isNotEmpty) ...[
                        _buildSectionHeader('Noorva Guide Chats'),
                        const SizedBox(height: 12),
                        _buildChatGroup(noorvaGuideChats),
                        const SizedBox(height: 16),
                      ],
                    ],
                    if (starredChats.isEmpty &&
                        recentChats.isEmpty &&
                        noorvaGuideChats.isEmpty) ...[
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
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
  }

  Widget _buildSearchResult(Map<String, dynamic> chat) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat['title']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat['time']!,
                        style: GoogleFonts.outfit(
                          color: _mutedText,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const Color _cardColor = Color(0xFF1B1B1E);
  static final Color _borderColor = Colors.white.withValues(alpha: 0.14);
  static final Color _mutedText = Colors.white.withValues(alpha: 0.85);

  Widget _buildHeaderButton({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: _borderColor),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: _mutedText,
        fontSize: 12,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildChatGroup(List<Map<String, dynamic>> chats) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...chats.map(_buildChatItem),
              InkWell(
                onTap: () {
                  // Click action
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Text(
                    'View All',
                    style: GoogleFonts.outfit(
                      color: _mutedText,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['title']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat['time']!,
                    style: GoogleFonts.outfit(
                      color: _mutedText,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                _showContextMenu(context, details.globalPosition, chat);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Icon(Icons.more_horiz, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
