import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';

/// Lets a teacher either:
///  - Create a brand-new Class (section) + its first Subject, or
///  - Add a Subject to a Class that already exists (found by name),
/// so multiple teachers can share one join code across a section.
class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

enum _Mode { newClass, existingClass }

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();

  _Mode _mode = _Mode.newClass;
  bool _isLoading = false;

  final _classNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _sectionController = TextEditingController();
  final _subjectController = TextEditingController();

  // Set once an existing class is found via _lookupExistingClass().
  ClassModel? _foundClass;
  bool _isSearching = false;

  @override
  void dispose() {
    _classNameController.dispose();
    _departmentController.dispose();
    _sectionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _lookupExistingClass() async {
    final name = _classNameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      final found = await ClassService.instance.findClassByName(name);
      if (!mounted) return;
      setState(() => _foundClass = found);
      if (found == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No class found with that exact name.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_mode == _Mode.existingClass && _foundClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please find the class first using the Search button.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_mode == _Mode.newClass) {
        final classId = await ClassService.instance.createClassWithSubject(
          className: _classNameController.text,
          department: _departmentController.text,
          section: _sectionController.text,
          firstSubjectName: _subjectController.text,
        );
        final created = await ClassService.instance.getClass(classId);
        if (!mounted) return;
        setState(() => _isLoading = false);
        if (created != null) await _showJoinCodeDialog(created.joinCode, created.name);
        if (mounted) Navigator.of(context).pop(true);
      } else {
        await ClassService.instance.addSubjectToClass(
          classId: _foundClass!.id,
          subjectName: _subjectController.text,
        );
        if (!mounted) return;
        setState(() => _isLoading = false);
        await _showJoinCodeDialog(_foundClass!.joinCode, _foundClass!.name);
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    }
  }

  Future<void> _showJoinCodeDialog(String joinCode, String className) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 26),
            SizedBox(width: 10),
            Text('Success!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share this code with students of "$className":'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryIndigo.withOpacity(0.25)),
              ),
              child: Text(
                joinCode,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 6,
                  color: AppColors.primaryIndigo,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: joinCode));
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                const SnackBar(content: Text('Code copied')),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryIndigo),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(context), size: 20),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Class / Subject',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text(context)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModeToggle(),
                        const SizedBox(height: 24),
                        if (_mode == _Mode.newClass) ..._buildNewClassFields() else ..._buildExistingClassFields(),
                        const SizedBox(height: 12),
                        _buildLabel('Subject Name'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _subjectController,
                          hint: 'e.g. Data Structures',
                          validatorMsg: 'Please enter the subject name',
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryIndigo,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                            )
                                : Text(
                              _mode == _Mode.newClass ? 'Create Class' : 'Add Subject',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Row(
        children: [
          Expanded(child: _modeButton('New Class', _Mode.newClass)),
          Expanded(child: _modeButton('Existing Class', _Mode.existingClass)),
        ],
      ),
    );
  }

  Widget _modeButton(String label, _Mode mode) {
    final isActive = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() {
        _mode = mode;
        _foundClass = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryIndigo : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppColors.text(context).withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNewClassFields() {
    return [
      _buildLabel('Class Name'),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _classNameController,
        hint: 'e.g. BSCS - 4th Semester',
        validatorMsg: 'Please enter the class name',
      ),
      const SizedBox(height: 16),
      _buildLabel('Department'),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _departmentController,
        hint: 'e.g. BSCS',
        validatorMsg: 'Please enter the department',
      ),
      const SizedBox(height: 16),
      _buildLabel('Section'),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _sectionController,
        hint: 'e.g. 4th Semester / Section A',
        validatorMsg: 'Please enter the section',
      ),
      const SizedBox(height: 16),
    ];
  }

  List<Widget> _buildExistingClassFields() {
    return [
      _buildLabel('Class Name'),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _classNameController,
              hint: 'Exact class name, e.g. BSCS - 4th Semester',
              validatorMsg: 'Please enter the class name',
              onChanged: (_) => setState(() => _foundClass = null),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isSearching ? null : _lookupExistingClass,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryIndigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isSearching
                  ? const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Icon(Icons.search_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
      if (_foundClass != null) ...[
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Found "${_foundClass!.name}" — join code ${_foundClass!.joinCode}',
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 16),
    ];
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text(context)),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String validatorMsg,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      style: TextStyle(color: AppColors.text(context), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.text(context).withOpacity(0.35), fontSize: 14),
        filled: true,
        fillColor: AppColors.surface(context),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryIndigo, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return validatorMsg;
        return null;
      },
    );
  }
}