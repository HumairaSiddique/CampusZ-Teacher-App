import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Edit Profile Screen — a simple form to update the teacher's personal
/// details. Matches the CampusZ purple theme.
///
/// NOTE: Pure UI, pre-filled with placeholder data. Wire `_saveProfile()`
/// to update the TeacherModel document in Firestore once the backend is
/// ready, and load the initial values from AuthService.instance.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  final _nameController = TextEditingController(text: 'Humaira Khan');
  final _emailController = TextEditingController(text: 'humaira.khan@campusz.edu');
  final _phoneController = TextEditingController(text: '+92 300 1234567');
  final _departmentController = TextEditingController(text: 'Computer Science');
  final _bioController = TextEditingController(text: 'Passionate about teaching data structures and algorithms.');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // TODO: update the TeacherModel document in Firestore via
    // FirestoreService using AuthService.instance.currentUser.uid.
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
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
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [gradientStart, gradientEnd]),
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 44),
                        ),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              shape: BoxShape.circle,
                              border: Border.all(color: gradientEnd, width: 1.5),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: primaryIndigo, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _label('Full Name'),
                  _buildTextField(_nameController),
                  const SizedBox(height: 16),
                  _label('Email'),
                  _buildTextField(_emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _label('Phone'),
                  _buildTextField(_phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _label('Department / Subject'),
                  _buildTextField(_departmentController),
                  const SizedBox(height: 16),
                  _label('Bio'),
                  _buildTextField(_bioController, maxLines: 3),
                ],
              ),
            ),
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
            child: Text('Edit Profile', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text(context))),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text(context))),
  );

  Widget _buildTextField(TextEditingController controller, {TextInputType? keyboardType, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: 13, color: AppColors.text(context)),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
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
          onPressed: _saveProfile,
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
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}