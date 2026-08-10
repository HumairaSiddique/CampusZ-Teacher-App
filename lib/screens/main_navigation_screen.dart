import 'package:flutter/material.dart';

import 'ai_assistant_orb_button.dart';
import 'ai_chat_screen.dart';
import 'analytics_screen.dart';
import 'app_colors.dart';
import 'chats_screen.dart';
import 'classes_screen.dart';
import 'dashboard_screen.dart';

/// The app shell: bottom navigation bar with a notch for the floating
/// AI assistant orb, matching the CampusZ Figma design.
///
/// Swap the placeholder tab screens below (Classes / Chat / Analytics) for
/// your real screens whenever they're ready — Home already points at your
/// real DashboardScreen.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const Color primaryIndigo = Color(0xFF4A5AE8);

  // Replace these placeholders with your real screens as you build them.
  final List<Widget> _tabs = const [
    DashboardScreen(),
    ClassesScreen(),
    ChatsScreen(),
    AnalyticsScreen(),
  ];

  void _openAiAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AiChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AiAssistantOrbButton(onTap: _openAiAssistant),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: AppColors.surface(context),
        elevation: 8,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navItem(0, Icons.home_rounded, 'Home'),
              _navItem(1, Icons.menu_book_rounded, 'Classes'),
              const SizedBox(width: 56), // space reserved for the notch/orb
              _navItem(2, Icons.chat_bubble_outline_rounded, 'Chat'),
              _navItem(3, Icons.bar_chart_rounded, 'Analytics'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    final color = isActive ? primaryIndigo : AppColors.text(context).withOpacity(0.38);
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}