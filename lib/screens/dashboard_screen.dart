import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'app_colors.dart';
import 'analytics_screen.dart';
import 'assignments_screen.dart';
import 'attendance_screen.dart';
import 'ai_chat_screen.dart';
import 'calendar_screen.dart';
import 'chats_screen.dart';
import 'create_quize_screen.dart';
import 'grade_management_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'quick_action_wheel.dart';
import 'timetable_screen.dart';
import 'upload_lecture_screen.dart';

/// Dashboard (Home) Screen — matches CampusZ Figma design
/// Header + swipeable summary cards (Today's Classes / Student Performance /
/// AI Insights) + AI Suggestions strip + rotating Quick Actions wheel +
/// Recent Activity.
///
/// NOTE: Pure UI for now, using placeholder/sample data. Firestore streams
/// will replace the sample data once backend wiring is added back.
///
/// This screen assumes it's embedded inside your existing
/// MainNavigationScreen shell (bottom nav bar lives there), so no
/// Scaffold/bottom nav is included here — just the screen body.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  // Brand colors
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg(context),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSummaryCards()),
            SliverToBoxAdapter(child: _buildPageIndicator()),
            SliverToBoxAdapter(child: _buildAiSuggestions()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildRecentActivity()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning,',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.text(context).withOpacity(0.55),
                  ),
                ),
                Text(
                  'Teacher 👋',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => _openScreen(context, 'Notifications'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.text(context).withOpacity(0.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(Icons.notifications_none_rounded,
                      color: AppColors.text(context).withOpacity(0.7)),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                    const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [gradientStart, gradientEnd],
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: primaryIndigo.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Swipeable Summary Cards ----------
  Widget _buildSummaryCards() {
    final cards = [
      _buildTodaysClassesCard(),
      _buildStudentPerformanceCard(),
      _buildAiInsightsCard(),
    ];

    return SizedBox(
      height: 224,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back card 1 — rotated left, peeks from the top-left corner
          Positioned(
            top: 14,
            left: 2,
            right: 22,
            child: Transform.rotate(
              angle: -0.055,
              child: Container(
                height: 190,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3CBF7F), Color(0xFF1E9C63)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          // Back card 2 — rotated right, peeks from the bottom-right corner
          Positioned(
            top: 14,
            left: 22,
            right: 2,
            child: Transform.rotate(
              angle: 0.055,
              child: Container(
                height: 190,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8B5CF6), Color(0xFF6C4CE0)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          // Front card — the actual swipeable content, sits straight on top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 200,
              child: ScrollConfiguration(
                behavior: _DragScrollBehavior(),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: cards,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardWrapper({required Widget child, required List<Color> colors, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colors.last.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysClassesCard() {
    return _cardWrapper(
      colors: const [Color(0xFF4F7DF3), Color(0xFF3D5AE0)],
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TimetableScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                'May 28, 2025',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  "Today's Classes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _buildCircularStat('82%', 'Attendance'),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next: Data Structures',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '10:30 - 11:30 AM',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentPerformanceCard() {
    return _cardWrapper(
      colors: const [Color(0xFF3CBF7F), Color(0xFF1E9C63)],
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Performance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Overall\nPerformance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              _buildCircularStat('78%', 'This Week'),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final heights = [10.0, 18.0, 14.0, 24.0, 20.0, 30.0, 26.0];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 8,
                    height: heights[i],
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightsCard() {
    return _cardWrapper(
      colors: const [Color(0xFF8B5CF6), Color(0xFF6C4CE0)],
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AiChatScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '4',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'New Insights',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'View All',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularStat(String value, String label) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: double.tryParse(value.replaceAll('%', '')) != null
                  ? double.parse(value.replaceAll('%', '')) / 100
                  : 0,
              strokeWidth: 5,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? primaryIndigo
                  : primaryIndigo.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }

  // ---------- AI Suggestions Strip ----------
  Widget _buildAiSuggestions() {
    final suggestions = [
      {
        'icon': Icons.smart_toy_outlined,
        'title': '2 Quizzes',
        'subtitle': 'Can be generated',
        'color': primaryIndigo,
      },
      {
        'icon': Icons.description_outlined,
        'title': '3 Assignments',
        'subtitle': 'Need review',
        'color': primaryIndigo,
      },
      {
        'icon': Icons.groups_outlined,
        'title': '5 Students',
        'subtitle': 'Need attention',
        'color': primaryIndigo,
      },
      {
        'icon': Icons.bar_chart_rounded,
        'title': 'Attendance',
        'subtitle': 'Report ready',
        'color': primaryIndigo,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: primaryIndigo, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'AI Suggestions for You',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text(context),
                  ),
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AiChatScreen()),
                ),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryIndigo.withOpacity(0.8),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: primaryIndigo.withOpacity(0.8)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 74,
            child: ScrollConfiguration(
              behavior: _DragScrollBehavior(),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = suggestions[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AiChatScreen()),
                    ),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryIndigo.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(item['icon'] as IconData,
                              color: primaryIndigo, size: 18),
                          const Spacer(),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context),
                            ),
                          ),
                          Text(
                            item['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.text(context).withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Quick Actions Wheel (drag to rotate, like a carousel) ----------
  // All 10 quick-launch destinations live here now — nothing is duplicated
  // in a separate "feature cards" row, so the whole dashboard has one
  // consistent quick-actions pattern.
  void _openScreen(BuildContext context, String label) {
    // TODO: replace the remaining cases with real Navigator.push calls once
    // those screens exist, e.g.:
    // if (label == 'Attendance') {
    //   Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceScreen()));
    // }
    if (label == 'Reports') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
      );
      return;
    }
    if (label == 'Chat with Students') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChatsScreen()),
      );
      return;
    }
    if (label == 'Attendance') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AttendanceScreen()),
      );
      return;
    }
    if (label == 'Timetable') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const TimetableScreen()),
      );
      return;
    }
    if (label == 'Grade\nManagement' || label == 'Grade Management') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GradeManagementScreen()),
      );
      return;
    }
    if (label == 'Calendar') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CalendarScreen()),
      );
      return;
    }
    if (label == 'Upload\nLecture' || label == 'Upload Lecture') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const UploadLectureScreen()),
      );
      return;
    }
    if (label == 'Create\nQuiz' || label == 'Create Quiz') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
      );
      return;
    }
    if (label == 'Assignments') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AssignmentsScreen()),
      );
      return;
    }
    if (label == 'Notifications') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open "$label" screen here')),
    );
  }

  Widget _buildQuickActions() {
    final actions = <QuickActionItem>[
      QuickActionItem(
        icon: Icons.calendar_month_outlined,
        label: 'Timetable',
        color: primaryIndigo,
        onTap: () => _openScreen(context, 'Timetable'),
      ),
      QuickActionItem(
        icon: Icons.checklist_rounded,
        label: 'Attendance',
        color: primaryIndigo,
        onTap: () => _openScreen(context, 'Attendance'),
      ),
      QuickActionItem(
        icon: Icons.workspace_premium_outlined,
        label: 'Grade\nManagement',
        color: primaryIndigo,
        onTap: () => _openScreen(context, 'Grade Management'),
      ),
      QuickActionItem(
        icon: Icons.bar_chart_rounded,
        label: 'Reports',
        color: primaryIndigo,
        onTap: () => _openScreen(context, 'Reports'),
      ),
      QuickActionItem(
        icon: Icons.calendar_today_rounded,
        label: 'Calendar',
        color: primaryIndigo,
        onTap: () => _openScreen(context, 'Calendar'),
      ),
      QuickActionItem(
        icon: Icons.forum_outlined,
        label: 'Chat with\nStudents',
        color: primaryIndigo,
        onTap: () => _openScreen(context, 'Chat with Students'),
      ),
      QuickActionItem(
        icon: Icons.cloud_upload_rounded,
        label: 'Upload\nLecture',
        color: primaryIndigo,
        onTap: () => _openScreen(context, 'Upload Lecture'),
      ),
      QuickActionItem(
        icon: Icons.fact_check_rounded,
        label: 'Create\nQuiz',
        color: primaryIndigo,
        onTap: () => _openScreen(context, 'Create Quiz'),
      ),
      QuickActionItem(
        icon: Icons.edit_note_rounded,
        label: 'Assignments',
        color: primaryIndigo,
        onTap: () => _openScreen(context, 'Assignments'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text(context),
                ),
              ),
              Row(
                children: [
                  Text(
                    'Drag to spin',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryIndigo.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.touch_app_outlined,
                      size: 14, color: primaryIndigo.withOpacity(0.75)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(child: QuickActionsWheel(items: actions, wheelSize: 300)),
        ],
      ),
    );
  }

  // ---------- Recent Activity ----------
  Widget _buildRecentActivity() {
    final activities = [
      {
        'icon': Icons.checklist_rounded,
        'color': const Color(0xFF3D5AE0),
        'title': 'Attendance Taken',
        'subtitle': 'Data Structures • 9:30 AM',
        'badge': 'Today',
      },
      {
        'icon': Icons.description_outlined,
        'color': const Color(0xFF8B5CF6),
        'title': 'New Assignment Created',
        'subtitle': 'Algorithms • 8:45 AM',
        'badge': 'Today',
      },
      {
        'icon': Icons.help_outline_rounded,
        'color': const Color(0xFFF59E0B),
        'title': 'Quiz Published',
        'subtitle': 'Database Systems • Yesterday',
        'badge': 'Yesterday',
      },
      {
        'icon': Icons.bar_chart_rounded,
        'color': const Color(0xFF3CBF7F),
        'title': 'Report Generated',
        'subtitle': 'Monthly Attendance Report',
        'badge': '2 Days Ago',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text(context),
                ),
              ),
              InkWell(
                onTap: () => _openScreen(context, 'Recent Activity'),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryIndigo.withOpacity(0.8),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: primaryIndigo.withOpacity(0.8)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10),
              ],
            ),
            child: Column(
              children: List.generate(activities.length, (index) {
                final item = activities[index];
                final isLast = index == activities.length - 1;
                return InkWell(
                  onTap: () => _openScreen(context, item['title'] as String),
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(18) : Radius.zero,
                    bottom: isLast ? const Radius.circular(18) : Radius.zero,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(
                        bottom: BorderSide(
                          color: AppColors.text(context).withOpacity(0.05),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: (item['color'] as Color).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item['icon'] as IconData,
                              color: item['color'] as Color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text(context),
                                ),
                              ),
                              Text(
                                item['subtitle'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.text(context).withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryIndigo.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['badge'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: primaryIndigo.withOpacity(0.85),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.chevron_right,
                            size: 16, color: AppColors.text(context).withOpacity(0.3)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}