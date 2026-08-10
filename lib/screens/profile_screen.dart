import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:provider/provider.dart';

import 'ai_chat_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'login_screen.dart';
import 'theme_provider.dart';
import '../services/auth_service.dart';

/// Teacher Profile Screen — matches the CampusZ purple/indigo brand theme.
///
/// NOTE: Pure UI with placeholder/sample data for now. Once wired to Firebase,
/// replace the sample fields (name, subject) with values from your
/// TeacherModel via AuthService.instance / FirestoreService streams. The
/// theme selector below reads/writes the real app-wide ThemeProvider, so
/// switching Light/Dark/System here actually changes the app.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  // UI order is Light, Dark, System — mapped to ThemeMode values in the
  // same order so the segmented selector index lines up with ThemeMode.
  static const List<ThemeMode> _themeModes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];

  bool _notificationsEnabled = true;

  void _onThemeChanged(int index) {
    context.read<ThemeProvider>().setThemeMode(_themeModes[index]);
  }

  void _onNotificationsChanged(bool value) {
    setState(() => _notificationsEnabled = value);
    // TODO: persist this to SharedPreferences / update FCM subscription here.
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = context.watch<ThemeProvider>().themeMode;
    final selectedTheme = _themeModes.indexOf(currentThemeMode);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildPreferencesCard(selectedTheme),
            const SizedBox(height: 20),
            _buildMenuSection(context),
            const SizedBox(height: 20),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  // ---------- Header: back button + avatar + name ----------
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).maybePop(),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const Expanded(
                child: Text(
                  'My Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // TODO: navigate to your Edit Profile screen
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 48),
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
                  child: const Icon(Icons.camera_alt_rounded,
                      color: primaryIndigo, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Humaira Khan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Computer Science Teacher',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Quick stats row ----------
  // ---------- Theme selector + notification toggle ----------
  Widget _buildPreferencesCard(int selectedTheme) {
    const themeOptions = [
      {'label': 'Light', 'icon': Icons.light_mode_outlined},
      {'label': 'Dark', 'icon': Icons.dark_mode_outlined},
      {'label': 'System', 'icon': Icons.brightness_auto_outlined},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text(context)),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(themeOptions.length, (index) {
                final isSelected = selectedTheme == index;
                final option = themeOptions[index];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == themeOptions.length - 1 ? 0 : 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _onThemeChanged(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: isSelected ? const LinearGradient(colors: [gradientStart, gradientEnd]) : null,
                          color: isSelected ? null : AppColors.bg(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              option['icon'] as IconData,
                              size: 18,
                              color: isSelected ? Colors.white : AppColors.text(context).withOpacity(0.55),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option['label'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.text(context).withOpacity(0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Container(height: 1, color: AppColors.text(context).withOpacity(0.06)),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: primaryIndigo.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
                  child: Icon(
                    _notificationsEnabled ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
                    color: primaryIndigo,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Notifications',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text(context)),
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  activeColor: primaryIndigo,
                  onChanged: _onNotificationsChanged,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Menu list ----------
  Widget _buildMenuSection(BuildContext context) {
    final items = [
      {
        'icon': Icons.person_outline_rounded,
        'title': 'Edit Profile',
        'subtitle': 'Update your personal details',
      },
      {
        'icon': Icons.lock_outline_rounded,
        'title': 'Change Password',
        'subtitle': 'Update your account password',
      },
      {
        'icon': Icons.menu_book_outlined,
        'title': 'My Classes',
        'subtitle': 'View classes you teach',
      },
      {
        'icon': Icons.notifications_none_rounded,
        'title': 'Notifications',
        'subtitle': 'Manage notification preferences',
      },
      {
        'icon': Icons.smart_toy_outlined,
        'title': 'AI Assistant',
        'subtitle': 'Chat with your teaching assistant',
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'Help & Support',
        'subtitle': 'FAQs and contact support',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isLast = index == items.length - 1;
            return InkWell(
              onTap: () => _handleMenuTap(context, item['title'] as String),
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
                    bottom: BorderSide(color: AppColors.text(context).withOpacity(0.05)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: primaryIndigo.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item['icon'] as IconData,
                          color: primaryIndigo, size: 18),
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
                    Icon(Icons.chevron_right,
                        size: 18, color: AppColors.text(context).withOpacity(0.3)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _handleMenuTap(BuildContext context, String title) {
    if (title == 'AI Assistant') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AiChatScreen()),
      );
      return;
    }
    if (title == 'Edit Profile') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
      );
      return;
    }
    if (title == 'Change Password') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
      );
      return;
    }
    if (title == 'Help & Support') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
      );
      return;
    }
    // TODO: wire the rest of these to your real screens, e.g.:
    // if (title == 'Settings & Theme') {
    //   Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
    // }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open "$title" screen here')),
    );
  }

  // ---------- Logout ----------
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () => _confirmLogout(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
          label: const Text(
            'Log Out',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await AuthService.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}