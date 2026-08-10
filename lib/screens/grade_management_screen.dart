import 'package:flutter/material.dart';
import 'app_colors.dart';

import 'student_report_screen.dart';

class _StudentGrade {
  _StudentGrade({required this.name, required this.roll, this.marks});
  final String name;
  final String roll;
  int? marks;
}

String _letterFor(int? marks) {
  if (marks == null) return '-';
  if (marks >= 90) return 'A+';
  if (marks >= 80) return 'A';
  if (marks >= 70) return 'B';
  if (marks >= 60) return 'C';
  if (marks >= 50) return 'D';
  return 'F';
}

Color _colorFor(int? marks) {
  if (marks == null) return const Color(0xFF9CA3AF);
  if (marks >= 80) return const Color(0xFF3CBF7F);
  if (marks >= 60) return const Color(0xFF4A5AE8);
  if (marks >= 50) return const Color(0xFFF59E0B);
  return const Color(0xFFEF4444);
}

/// Grade Management Screen — pick a class + assessment, enter marks per
/// student, auto letter-grade + color, then save. Matches the CampusZ
/// purple theme used across the rest of the app.
///
/// NOTE: Pure UI with placeholder/sample data. Wire `_saveGrades()` to your
/// FirestoreService once the backend is ready.
class GradeManagementScreen extends StatefulWidget {
  const GradeManagementScreen({super.key});

  @override
  State<GradeManagementScreen> createState() => _GradeManagementScreenState();
}

class _GradeManagementScreenState extends State<GradeManagementScreen> {
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  final List<String> _classes = const ['Data Structures', 'Database Systems', 'Algorithms', 'Operating Systems'];
  final List<String> _assessments = const ['Quiz 1', 'Assignment 1', 'Midterm', 'Final Exam'];
  int _selectedClass = 0;
  int _selectedAssessment = 0;

  static const List<String> _sampleNames = [
    'Ayesha Malik', 'Bilal Ahmed', 'Sara Khan', 'Usman Tariq',
    'Hina Fatima', 'Zainab Riaz',
  ];

  late final Map<String, List<_StudentGrade>> _gradesByClass = {
    for (final c in _classes)
      c: List.generate(
        6,
            (i) => _StudentGrade(name: _sampleNames[i], roll: 'BSCS-${21000 + i}'),
      ),
  };

  List<_StudentGrade> get _current => _gradesByClass[_classes[_selectedClass]]!;

  void _saveGrades() {
    // TODO: write `_current` marks (for `_assessments[_selectedAssessment]`) to Firestore here.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Grades saved for ${_assessments[_selectedAssessment]}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSelectors(),
            Expanded(child: _buildGradeList()),
            _buildSaveBar(),
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
            child: Text('Grade Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectors() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _classes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedClass;
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => setState(() => _selectedClass = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? const LinearGradient(colors: [gradientStart, gradientEnd]) : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: isSelected ? null : Border.all(color: AppColors.text(context).withOpacity(0.08)),
                    ),
                    child: Text(
                      _classes[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.text(context).withOpacity(0.65),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _assessments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedAssessment;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _selectedAssessment = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryIndigo.withOpacity(0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? primaryIndigo : AppColors.text(context).withOpacity(0.1)),
                    ),
                    child: Text(
                      _assessments[index],
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? primaryIndigo : AppColors.text(context).withOpacity(0.55),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      itemCount: _current.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final student = _current[index];
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
              SizedBox(
                width: 60,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0-100',
                    hintStyle: const TextStyle(fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    filled: true,
                    fillColor: AppColors.bg(context),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                  style: TextStyle(fontSize: 13, color: AppColors.text(context), fontWeight: FontWeight.w600),
                  onChanged: (val) => setState(() => student.marks = int.tryParse(val)),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 40,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _colorFor(student.marks).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _letterFor(student.marks),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _colorFor(student.marks)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveBar() {
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
          onPressed: _saveGrades,
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
              child: const Text('Save Grades',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}