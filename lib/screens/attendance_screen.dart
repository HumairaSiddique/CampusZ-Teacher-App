import 'package:flutter/material.dart';
import 'app_colors.dart';

import 'student_report_screen.dart';

enum _AttendanceStatus { present, absent, leave }

class _Student {
  _Student({required this.name, required this.roll, this.status = _AttendanceStatus.present});
  final String name;
  final String roll;
  _AttendanceStatus status;
}

/// Take Attendance Screen — pick a class, mark each student Present / Absent
/// / Leave, see a live summary, then submit. Matches the CampusZ purple
/// theme used across the rest of the app.
///
/// NOTE: Pure UI with placeholder/sample data. Once wired to Firebase,
/// replace `_studentsByClass` with a real roster stream from
/// FirestoreService and write the marked attendance back to Firestore in
/// `_submitAttendance()`.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);
  static const Color presentColor = Color(0xFF3CBF7F);
  static const Color absentColor = Color(0xFFEF4444);
  static const Color leaveColor = Color(0xFFF59E0B);

  final List<String> _classes = const [
    'Data Structures',
    'Database Systems',
    'Algorithms',
    'Operating Systems',
  ];
  int _selectedClass = 0;

  late Map<String, List<_Student>> _studentsByClass = {
    for (final c in _classes)
      c: List.generate(
        8,
            (i) => _Student(name: _sampleNames[i % _sampleNames.length], roll: 'BSCS-${21000 + i}'),
      ),
  };

  static const List<String> _sampleNames = [
    'Ayesha Malik', 'Bilal Ahmed', 'Sara Khan', 'Usman Tariq',
    'Hina Fatima', 'Zainab Riaz', 'Ahmed Raza', 'Mahnoor Iqbal',
  ];

  List<_Student> get _currentStudents => _studentsByClass[_classes[_selectedClass]]!;

  void _setStatus(_Student student, _AttendanceStatus status) {
    setState(() => student.status = status);
  }

  void _submitAttendance() {
    // TODO: write `_currentStudents` attendance to Firestore here.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Attendance submitted for ${_classes[_selectedClass]}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final present = _currentStudents.where((s) => s.status == _AttendanceStatus.present).length;
    final absent = _currentStudents.where((s) => s.status == _AttendanceStatus.absent).length;
    final leave = _currentStudents.where((s) => s.status == _AttendanceStatus.leave).length;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildClassSelector(),
            _buildSummaryRow(present, absent, leave),
            Expanded(child: _buildStudentList()),
            _buildSubmitBar(),
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
            child: Text(
              'Take Attendance',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text(context)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.06), blurRadius: 8)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined, size: 13, color: primaryIndigo),
                const SizedBox(width: 6),
                Text('Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryIndigo)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _classes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedClass;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _selectedClass = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [gradientStart, gradientEnd])
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: AppColors.text(context).withOpacity(0.08)),
              ),
              child: Text(
                _classes[index],
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.text(context).withOpacity(0.65),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(int present, int absent, int leave) {
    Widget chip(String label, int value, Color color) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text('$value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 10.5, color: color.withOpacity(0.8))),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          chip('Present', present, presentColor),
          chip('Absent', absent, absentColor),
          chip('Leave', leave, leaveColor),
        ],
      ),
    );
  }

  Widget _buildStudentList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      itemCount: _currentStudents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final student = _currentStudents[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 8)],
          ),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StudentReportScreen(
                      studentName: student.name,
                      className: _classes[_selectedClass],
                      rollNumber: student.roll,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: primaryIndigo.withOpacity(0.1), shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          student.name.split(' ').map((w) => w[0]).take(2).join(),
                          style: const TextStyle(color: primaryIndigo, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text(context))),
                        Text(student.roll, style: TextStyle(fontSize: 11, color: AppColors.text(context).withOpacity(0.5))),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _statusToggle(student),
            ],
          ),
        );
      },
    );
  }

  Widget _statusToggle(_Student student) {
    Widget dot(_AttendanceStatus status, IconData icon, Color color) {
      final isActive = student.status == status;
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _setStatus(student, status),
        child: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: isActive ? Colors.white : color),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot(_AttendanceStatus.present, Icons.check_rounded, presentColor),
        dot(_AttendanceStatus.absent, Icons.close_rounded, absentColor),
        dot(_AttendanceStatus.leave, Icons.info_outline_rounded, leaveColor),
      ],
    );
  }

  Widget _buildSubmitBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.06), blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _submitAttendance,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ).copyWith(
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [gradientStart, gradientEnd]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 48,
              child: const Text(
                'Submit Attendance',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}