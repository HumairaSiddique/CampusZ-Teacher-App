import 'package:flutter/material.dart';
import 'app_colors.dart';

import 'student_chat_screen.dart';

/// Chat with Students — list of conversations. Tapping a conversation opens
/// StudentChatScreen for that student. Matches the CampusZ purple theme.
///
/// NOTE: Pure UI with placeholder/sample data. Swap `_conversations` for a
/// FirestoreService stream once chat is wired to the backend.
class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  static const List<Map<String, Object>> _conversations = [
    {
      'name': 'Ayesha Malik',
      'initials': 'AM',
      'lastMessage': 'The traversal part — inorder vs preorder.',
      'time': '9:16 AM',
      'unread': 2,
      'color': Color(0xFF4F7DF3),
    },
    {
      'name': 'Bilal Ahmed',
      'initials': 'BA',
      'lastMessage': 'Sir, assignment 3 ki deadline extend ho sakti hai?',
      'time': 'Yesterday',
      'unread': 0,
      'color': Color(0xFF3CBF7F),
    },
    {
      'name': 'Sara Khan',
      'initials': 'SK',
      'lastMessage': 'Thank you for the feedback on my quiz!',
      'time': 'Yesterday',
      'unread': 0,
      'color': Color(0xFF8B5CF6),
    },
    {
      'name': 'Usman Tariq',
      'initials': 'UT',
      'lastMessage': 'Can we reschedule the project meeting?',
      'time': 'Mon',
      'unread': 1,
      'color': Color(0xFFF59E0B),
    },
    {
      'name': 'Hina Fatima',
      'initials': 'HF',
      'lastMessage': 'Got it, will submit by tonight.',
      'time': 'Mon',
      'unread': 0,
      'color': Color(0xFFEF4444),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg(context),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: _conversations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _conversations[index];
                  return _buildConversationTile(context, item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (Navigator.of(context).canPop())
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(context), size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (Navigator.of(context).canPop()) const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Messages',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text(context)),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.06), blurRadius: 8)],
            ),
            child: Icon(Icons.search_rounded, color: AppColors.text(context).withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(BuildContext context, Map<String, Object> item) {
    final unread = item['unread'] as int;
    final color = item['color'] as Color;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StudentChatScreen(
              studentName: item['name'] as String,
              studentInitials: item['initials'] as String,
              avatarColor: color,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Center(
                child: Text(
                  item['initials'] as String,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text(context)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['lastMessage'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.text(context).withOpacity(unread > 0 ? 0.75 : 0.5),
                      fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item['time'] as String,
                  style: TextStyle(fontSize: 10.5, color: AppColors.text(context).withOpacity(0.4)),
                ),
                const SizedBox(height: 6),
                if (unread > 0)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(color: primaryIndigo, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '$unread',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}