import 'package:flutter/material.dart';
import 'app_colors.dart';

import 'upload_lecture_screen.dart';

class _Material {
  const _Material({required this.title, required this.type, required this.size, required this.date});
  final String title;
  final String type; // pdf, ppt, doc, video
  final String size;
  final String date;
}

IconData _iconFor(String type) {
  switch (type) {
    case 'pdf':
      return Icons.picture_as_pdf_rounded;
    case 'ppt':
      return Icons.slideshow_rounded;
    case 'video':
      return Icons.play_circle_outline_rounded;
    default:
      return Icons.description_rounded;
  }
}

Color _colorFor(String type) {
  switch (type) {
    case 'pdf':
      return const Color(0xFFEF4444);
    case 'ppt':
      return const Color(0xFFF59E0B);
    case 'video':
      return const Color(0xFF8B5CF6);
    default:
      return const Color(0xFF4F7DF3);
  }
}

/// Course Materials Screen — all uploaded lecture files for a class, with
/// an "Upload New" shortcut into UploadLectureScreen. Matches the CampusZ
/// purple theme.
///
/// NOTE: Pure UI with placeholder/sample data. Swap `_materials` for a real
/// Firebase Storage + Firestore-backed list once wired up.
class CourseMaterialsScreen extends StatelessWidget {
  const CourseMaterialsScreen({super.key, required this.className});

  final String className;

  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  static const List<_Material> _materials = [
    _Material(title: 'Lecture 09 - Binary Trees', type: 'pdf', size: '2.4 MB', date: 'Jul 28'),
    _Material(title: 'Lecture 08 - Linked Lists', type: 'ppt', size: '5.1 MB', date: 'Jul 21'),
    _Material(title: 'Lecture 07 - Recorded Session', type: 'video', size: '110 MB', date: 'Jul 18'),
    _Material(title: 'Course Outline', type: 'doc', size: '210 KB', date: 'Jul 1'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UploadLectureScreen()),
        ),
        backgroundColor: primaryIndigo,
        icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
        label: const Text('Upload New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                itemCount: _materials.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _buildTile(context, _materials[index]),
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
                Text('Course Materials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text(context))),
                Text(className, style: TextStyle(fontSize: 12, color: AppColors.text(context).withOpacity(0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, _Material item) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Open "${item.title}" here')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: _colorFor(item.type).withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
              child: Icon(_iconFor(item.type), color: _colorFor(item.type), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text(context))),
                  const SizedBox(height: 2),
                  Text('${item.size} · ${item.date}', style: TextStyle(fontSize: 11, color: AppColors.text(context).withOpacity(0.5))),
                ],
              ),
            ),
            Icon(Icons.file_download_outlined, size: 18, color: AppColors.text(context).withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}