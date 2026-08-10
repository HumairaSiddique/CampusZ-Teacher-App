import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Student Report Screen — tap any student (from Attendance, Grade
/// Management, or a class roster) to see their full profile: attendance %,
/// grade breakdown per assessment, assignment completion, and contact info.
/// Matches the CampusZ purple theme.
///
/// NOTE: Pure UI with placeholder/sample data. Once wired to Firebase,
/// replace the sample fields with a real StudentModel + aggregated
/// attendance/grades streams from FirestoreService, keyed by `studentId`.
class StudentReportScreen extends StatelessWidget {
  const StudentReportScreen({
    super.key,
    required this.studentName,
    required this.className,
    this.rollNumber = 'BSCS-21004',
    this.avatarColor = const Color(0xFF4A5AE8),
  });

  final String studentName;
  final String className;
  final String rollNumber;
  final Color avatarColor;

  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  // Sample data — replace with real aggregates once Firestore is wired up.
  static const double _attendancePercent = 0.86;
  static const double _averageGrade = 0.78;
  static const List<Map<String, Object>> _assessments = [
    {'title': 'Quiz 1', 'score': 85, 'max': 100},
    {'title': 'Assignment 1', 'score': 92, 'max': 100},
    {'title': 'Midterm', 'score': 74, 'max': 100},
    {'title': 'Quiz 2', 'score': 68, 'max': 100},
  ];
  static const List<Map<String, Object>> _attendanceHistory = [
    {'label': 'Mon', 'present': true},
    {'label': 'Tue', 'present': true},
    {'label': 'Wed', 'present': false},
    {'label': 'Thu', 'present': true},
    {'label': 'Fri', 'present': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildStatCards(context),
            _buildAttendanceStrip(context),
            _buildGradeBreakdown(context),
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
              const Expanded(
                child: Text(
                  'Student Report',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message this student here')),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                studentName.split(' ').map((w) => w[0]).take(2).join(),
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(studentName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('$className · $rollNumber', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5)),
        ],
      ),
    );
  }

  // ---------- Stat cards ----------
  Widget _buildStatCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _statCard(context, 'Attendance', '${(_attendancePercent * 100).round()}%', const Color(0xFF3CBF7F))),
          const SizedBox(width: 12),
          Expanded(child: _statCard(context, 'Avg. Grade', '${(_averageGrade * 100).round()}%', const Color(0xFF4F7DF3))),
          const SizedBox(width: 12),
          Expanded(child: _statCard(context, 'Assignments', '11/12', const Color(0xFF8B5CF6))),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.text(context).withOpacity(0.5))),
        ],
      ),
    );
  }

  // ---------- Attendance strip (last 5 days) ----------
  Widget _buildAttendanceStrip(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Attendance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text(context))),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _attendanceHistory.map((day) {
                final present = day['present'] as bool;
                return Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: present ? const Color(0xFF3CBF7F).withOpacity(0.12) : const Color(0xFFEF4444).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        present ? Icons.check_rounded : Icons.close_rounded,
                        size: 16,
                        color: present ? const Color(0xFF3CBF7F) : const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(day['label'] as String, style: TextStyle(fontSize: 10.5, color: AppColors.text(context).withOpacity(0.5))),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Grade breakdown ----------
  Widget _buildGradeBreakdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grade Breakdown', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.text(context))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(
              children: List.generate(_assessments.length, (index) {
                final item = _assessments[index];
                final score = item['score'] as int;
                final max = item['max'] as int;
                final ratio = score / max;
                final color = ratio >= 0.8
                    ? const Color(0xFF3CBF7F)
                    : ratio >= 0.6
                    ? primaryIndigo
                    : const Color(0xFFEF4444);
                final isLast = index == _assessments.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['title'] as String, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text(context))),
                          Text('$score/$max', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          backgroundColor: AppColors.text(context).withOpacity(0.06),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Contact / actions ----------
  Widget _buildContactSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          children: [
            _contactTile(
              context: context,
              icon: Icons.email_outlined,
              label: '${studentName.toLowerCase().replaceAll(' ', '.')}@campusz.edu',
              isLast: false,
            ),
            _contactTile(context: context, icon: Icons.phone_outlined, label: '+92 300 1234567', isLast: false),
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Open full submission history here')),
                );
              },
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
              child: _contactTile(context: context, icon: Icons.history_rounded, label: 'View full submission history', isLast: true, showChevron: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactTile({required BuildContext context, required IconData icon, required String label, required bool isLast, bool showChevron = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: AppColors.text(context).withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: primaryIndigo.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: primaryIndigo, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 12.5, color: AppColors.text(context), fontWeight: FontWeight.w600))),
          if (showChevron) Icon(Icons.chevron_right, size: 18, color: AppColors.text(context).withOpacity(0.3)),
        ],
      ),
    );
  }
}