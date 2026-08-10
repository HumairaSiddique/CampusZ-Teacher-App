import 'package:flutter/material.dart';
import 'app_colors.dart';

import 'student_report_screen.dart';

class _RosterStudent {
  const _RosterStudent({required this.name, required this.roll, required this.email, required this.color});
  final String name;
  final String roll;
  final String email;
  final Color color;
}

/// Students List (Roster) Screen — all students in a given class, tap any
/// student to open their full StudentReportScreen. Matches the CampusZ
/// purple theme.
///
/// NOTE: Pure UI with placeholder/sample data. Swap `_students` for a real
/// roster stream from FirestoreService keyed by `className` once wired up.
class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key, required this.className});

  final String className;

  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  static const List<_RosterStudent> _students = [
    _RosterStudent(name: 'Ayesha Malik', roll: 'BSCS-21000', email: 'ayesha.malik@campusz.edu', color: Color(0xFF4F7DF3)),
    _RosterStudent(name: 'Bilal Ahmed', roll: 'BSCS-21001', email: 'bilal.ahmed@campusz.edu', color: Color(0xFF3CBF7F)),
    _RosterStudent(name: 'Sara Khan', roll: 'BSCS-21002', email: 'sara.khan@campusz.edu', color: Color(0xFF8B5CF6)),
    _RosterStudent(name: 'Usman Tariq', roll: 'BSCS-21003', email: 'usman.tariq@campusz.edu', color: Color(0xFFF59E0B)),
    _RosterStudent(name: 'Hina Fatima', roll: 'BSCS-21004', email: 'hina.fatima@campusz.edu', color: Color(0xFFEF4444)),
    _RosterStudent(name: 'Zainab Riaz', roll: 'BSCS-21005', email: 'zainab.riaz@campusz.edu', color: Color(0xFF4F7DF3)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: _students.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _buildTile(context, _students[index]),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Students', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text(context))),
                Text(className, style: TextStyle(fontSize: 12, color: AppColors.text(context).withOpacity(0.5))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: primaryIndigo.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text('${_students.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primaryIndigo)),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, _RosterStudent student) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StudentReportScreen(
            studentName: student.name,
            className: className,
            rollNumber: student.roll,
            avatarColor: student.color,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: student.color.withOpacity(0.15), shape: BoxShape.circle),
              child: Center(
                child: Text(
                  student.name.split(' ').map((w) => w[0]).take(2).join(),
                  style: TextStyle(color: student.color, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.text(context))),
                  const SizedBox(height: 2),
                  Text(student.roll, style: TextStyle(fontSize: 11, color: AppColors.text(context).withOpacity(0.5))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: AppColors.text(context).withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}