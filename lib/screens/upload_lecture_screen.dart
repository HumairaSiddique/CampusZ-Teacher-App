import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Upload Lecture Screen — pick a class, add a title/description, attach a
/// file (mocked — wire to file_picker + Firebase Storage later), then
/// upload. Matches the CampusZ purple theme.
class UploadLectureScreen extends StatefulWidget {
  const UploadLectureScreen({super.key});

  @override
  State<UploadLectureScreen> createState() => _UploadLectureScreenState();
}

class _UploadLectureScreenState extends State<UploadLectureScreen> {
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  final List<String> _classes = const ['Data Structures', 'Database Systems', 'Algorithms', 'Operating Systems'];
  int _selectedClass = 0;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _pickedFileName;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _pickFile() {
    // TODO: replace with a real file_picker call, e.g.:
    // final result = await FilePicker.platform.pickFiles();
    setState(() => _pickedFileName = 'Lecture_09_BinaryTrees.pdf');
  }

  void _upload() {
    if (_titleController.text.trim().isEmpty || _pickedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title and attach a file first')),
      );
      return;
    }
    // TODO: upload `_pickedFileName` to Firebase Storage and save a
    // LectureModel document to Firestore for `_classes[_selectedClass]`.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${_titleController.text}" uploaded to ${_classes[_selectedClass]}')),
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  _label('Class'),
                  _buildClassDropdown(),
                  const SizedBox(height: 18),
                  _label('Lecture Title'),
                  _buildTextField(_titleController, 'e.g. Binary Trees & Traversals'),
                  const SizedBox(height: 18),
                  _label('Description'),
                  _buildTextField(_descController, 'Brief description for students...', maxLines: 4),
                  const SizedBox(height: 18),
                  _label('Attachment'),
                  _buildFilePicker(),
                ],
              ),
            ),
            _buildUploadBar(),
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
            child: Text('Upload Lecture',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text(context))),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text(context))),
  );

  Widget _buildClassDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _selectedClass,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryIndigo),
          items: List.generate(
            _classes.length,
                (i) => DropdownMenuItem(value: i, child: Text(_classes[i], style: TextStyle(fontSize: 13, color: AppColors.text(context)))),
          ),
          onChanged: (val) => setState(() => _selectedClass = val ?? 0),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontSize: 13, color: AppColors.text(context)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12.5, color: Colors.black38),
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _pickedFileName != null ? primaryIndigo.withOpacity(0.3) : AppColors.text(context).withOpacity(0.08),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: primaryIndigo.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(
                _pickedFileName != null ? Icons.description_rounded : Icons.cloud_upload_outlined,
                color: primaryIndigo,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _pickedFileName ?? 'Tap to select a file (PDF, PPT, DOCX)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: _pickedFileName != null ? FontWeight.w700 : FontWeight.w500,
                  color: _pickedFileName != null ? AppColors.text(context) : AppColors.text(context).withOpacity(0.4),
                ),
              ),
            ),
            if (_pickedFileName != null)
              Icon(Icons.check_circle_rounded, color: const Color(0xFF3CBF7F), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBar() {
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
          onPressed: _upload,
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
              child: const Text('Upload Lecture',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}