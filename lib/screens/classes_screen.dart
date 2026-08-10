import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:flutter/gestures.dart';
import 'attendance_screen.dart';
import 'course_materials_screen.dart';
import 'create_class_screen.dart';
import 'grade_management_screen.dart';
import 'quick_action_wheel.dart';
import 'students_list_screen.dart';
import 'timetable_screen.dart';

/// Classes Screen — list of the teacher's classes + a class-specific
/// Quick Actions wheel, matching the same CampusZ design language as the
/// Dashboard (purple/indigo cards + the reusable QuickActionsWheel).
///
/// NOTE: Pure UI for now with placeholder/sample data. Swap the sample
/// `_classes` list for your CourseModel stream from FirestoreService once
/// this is wired to the backend.
class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _DragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class _ClassesScreenState extends State<ClassesScreen> {
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  final List<Map<String, String>> _classes = const [
    {
      'title': 'Data Structures',
      'section': 'BSCS - 4th Semester',
      'students': '45',
      'time': '10:30 - 11:30 AM',
    },
    {
      'title': 'Database Systems',
      'section': 'BSCS - 5th Semester',
      'students': '38',
      'time': '12:00 - 1:00 PM',
    },
    {
      'title': 'Algorithms',
      'section': 'BSCS - 6th Semester',
      'students': '41',
      'time': '2:00 - 3:00 PM',
    },
    {
      'title': 'Operating Systems',
      'section': 'BSCS - 5th Semester',
      'students': '39',
      'time': '3:30 - 4:30 PM',
    },
  ];

  void _openScreen(String label) {
    if (label == 'Add New Class' || label == 'Add Class') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateClassScreen()),
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
    if (label == 'Grades') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GradeManagementScreen()),
      );
      return;
    }

    if (label == 'Students') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => StudentsListScreen(className: _classes[0]['title']!)),
      );
      return;
    }
    if (label == 'Course Materials') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CourseMaterialsScreen(className: _classes[0]['title']!)),
      );
      return;
    }
    // TODO: replace with a real Navigator.push once each screen exists, e.g.:
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open "$label" screen here')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg(context),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildClassActionsWheel()),
            SliverToBoxAdapter(child: _buildClassList()),
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
              'My Classes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.text(context),
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.text(context).withOpacity(0.06), blurRadius: 8),
              ],
            ),
            child: Icon(Icons.search_rounded, color: AppColors.text(context).withOpacity(0.7)),
          ),
          const SizedBox(width: 12),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => _openScreen('Add New Class'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [gradientStart, gradientEnd]),
                boxShadow: [
                  BoxShadow(color: primaryIndigo.withOpacity(0.3), blurRadius: 10),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Class-specific Quick Actions wheel ----------
  Widget _buildClassActionsWheel() {
    final actions = <QuickActionItem>[
      QuickActionItem(
        icon: Icons.add_circle_outline_rounded,
        label: 'Add\nClass',
        color: primaryIndigo,
        onTap: () => _openScreen('Add Class'),
      ),
      QuickActionItem(
        icon: Icons.checklist_rounded,
        label: 'Attendance',
        color: primaryIndigo,
        onTap: () => _openScreen('Attendance'),
      ),
      QuickActionItem(
        icon: Icons.groups_outlined,
        label: 'Students',
        color: primaryIndigo,
        onTap: () => _openScreen('Students'),
      ),
      QuickActionItem(
        icon: Icons.workspace_premium_outlined,
        label: 'Grades',
        color: primaryIndigo,
        onTap: () => _openScreen('Grades'),
      ),
      QuickActionItem(
        icon: Icons.folder_outlined,
        label: 'Course\nMaterials',
        color: primaryIndigo,
        onTap: () => _openScreen('Course Materials'),
      ),
      QuickActionItem(
        icon: Icons.calendar_month_outlined,
        label: 'Timetable',
        color: primaryIndigo,
        onTap: () => _openScreen('Timetable'),
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
                'Class Actions',
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
          Center(
            child: QuickActionsWheel(
              items: actions,
              hubTitle: 'Class Actions',
              hubSubtitle: 'Manage your\nclasses fast',
              wheelSize: 260,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Class list ----------
  Widget _buildClassList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Classes',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_classes.length, (index) {
            final item = _classes[index];
            final colorPairs = [
              const [Color(0xFF4F7DF3), Color(0xFF3D5AE0)],
              const [Color(0xFF3CBF7F), Color(0xFF1E9C63)],
              const [Color(0xFF8B5CF6), Color(0xFF6C4CE0)],
              const [Color(0xFFF59E0B), Color(0xFFD97706)],
            ];
            final colors = colorPairs[index % colorPairs.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StudentsListScreen(className: item['title']!),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: colors),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.menu_book_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['section']!,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.text(context).withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.people_outline,
                                    size: 13, color: AppColors.text(context).withOpacity(0.4)),
                                const SizedBox(width: 4),
                                Text(
                                  '${item['students']} students',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.text(context).withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(Icons.access_time_rounded,
                                    size: 13, color: AppColors.text(context).withOpacity(0.4)),
                                const SizedBox(width: 4),
                                Text(
                                  item['time']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.text(context).withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          size: 20, color: AppColors.text(context).withOpacity(0.3)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}