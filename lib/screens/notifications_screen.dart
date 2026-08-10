import 'package:flutter/material.dart';
import 'app_colors.dart';

import 'ai_chat_screen.dart';
import 'assignments_screen.dart';
import 'attendance_screen.dart';
import 'chats_screen.dart';
import 'students_list_screen.dart';

class _NotificationItem {
  _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    this.unread = false,
    this.destinationBuilder,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  bool unread;
  // Builds the screen this notification should open when tapped. Null
  // means there's nothing to navigate to (e.g. a purely informational item).
  final WidgetBuilder? destinationBuilder;
}

/// Notifications Screen — grouped Today / Earlier list with a "mark all
/// read" action. Matches the CampusZ purple theme.
///
/// NOTE: Pure UI with placeholder/sample data. Swap `_notifications` for a
/// real Firestore-backed notifications stream once wired up.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color primaryIndigo = Color(0xFF4A5AE8);

  late final List<_NotificationItem> _today = [
    _NotificationItem(
      icon: Icons.fact_check_outlined,
      title: 'New submission received',
      subtitle: 'Bilal Ahmed submitted "Binary Tree Implementation"',
      time: '9:20 AM',
      color: const Color(0xFF4F7DF3),
      unread: true,
      destinationBuilder: (_) => const AssignmentsScreen(),
    ),
    _NotificationItem(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'New message',
      subtitle: 'Ayesha Malik sent you a message',
      time: '9:12 AM',
      color: const Color(0xFF8B5CF6),
      unread: true,
      destinationBuilder: (_) => const ChatsScreen(),
    ),
    _NotificationItem(
      icon: Icons.smart_toy_outlined,
      title: 'AI Assistant',
      subtitle: '3 quizzes are ready to be generated',
      time: '8:00 AM',
      color: const Color(0xFF3CBF7F),
      unread: true,
      destinationBuilder: (_) => const AiChatScreen(),
    ),
  ];

  late final List<_NotificationItem> _earlier = [
    _NotificationItem(
      icon: Icons.checklist_rounded,
      title: 'Attendance report ready',
      subtitle: 'Monthly attendance report has been generated',
      time: 'Yesterday',
      color: const Color(0xFFF59E0B),
      destinationBuilder: (_) => const AttendanceScreen(),
    ),
    _NotificationItem(
      icon: Icons.event_outlined,
      title: 'Upcoming deadline',
      subtitle: '"ER Diagram Design" is due in 3 days',
      time: '2 days ago',
      color: const Color(0xFFEF4444),
      destinationBuilder: (_) => const AssignmentsScreen(),
    ),
    _NotificationItem(
      icon: Icons.groups_outlined,
      title: 'New student enrolled',
      subtitle: 'Hina Fatima joined Database Systems',
      time: '3 days ago',
      color: const Color(0xFF3D5AE0),
      destinationBuilder: (_) => const StudentsListScreen(className: 'Database Systems'),
    ),
  ];

  void _markAllRead() {
    setState(() {
      for (final n in _today) {
        n.unread = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  if (_today.isNotEmpty) ...[
                    _sectionLabel('Today'),
                    const SizedBox(height: 10),
                    ..._today.map(_buildTile),
                    const SizedBox(height: 20),
                  ],
                  if (_earlier.isNotEmpty) ...[
                    _sectionLabel('Earlier'),
                    const SizedBox(height: 10),
                    ..._earlier.map(_buildTile),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(context), size: 18),
          ),
          Expanded(
            child: Text('Notifications',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text(context))),
          ),
          TextButton(
            onPressed: _markAllRead,
            child: Text('Mark all read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryIndigo)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.text(context).withOpacity(0.4)),
  );

  Widget _buildTile(_NotificationItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() => item.unread = false);
          final destinationBuilder = item.destinationBuilder;
          if (destinationBuilder != null) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: destinationBuilder),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 8)],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: item.color.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text(context))),
                        ),
                        if (item.unread)
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(left: 6),
                            decoration: const BoxDecoration(color: primaryIndigo, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(item.subtitle, style: TextStyle(fontSize: 11.5, color: AppColors.text(context).withOpacity(0.5)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(item.time, style: TextStyle(fontSize: 10, color: AppColors.text(context).withOpacity(0.35))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}