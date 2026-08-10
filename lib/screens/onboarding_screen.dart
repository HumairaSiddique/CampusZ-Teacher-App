import 'package:flutter/material.dart';

import 'login_screen.dart';

// Brand colors (CampusZ)
const Color kPrimary = Color(0xFF4A5AE8);
const Color kGradientStart = Color(0xFF6C4CE0);
const Color kGradientEnd = Color(0xFF3D5AE0);
const Color kBg = Color(0xFFF8F7FF);
const Color kTextDark = Color(0xFF1E1B2E);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _titles = [
    'Elevate Your Teaching',
    'Manage Your Time',
    'Empower Every Student',
  ];

  final List<String> _descriptions = [
    'Harness the power of AI to automate grading, planning, and insights.',
    'Stay ahead with real-time schedule updates and intelligent lecture reminders.',
    "Deep-dive into performance analytics that provide personalized support where it's needed most.",
  ];

  void _goToNextPage() {
    if (_currentPage < _titles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _onGetStarted();
    }
  }

  // FIX: was `Navigator.of(context).pushReplacementNamed('/login')`, which
  // requires a named-route table that this app doesn't define anywhere in
  // MaterialApp — so the call silently failed to navigate. We use the same
  // direct MaterialPageRoute push that every other screen in this app uses.
  void _onGetStarted() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _onSkip() {
    _onGetStarted();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _titles.length - 1;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 8),
                child: TextButton(
                  onPressed: isLastPage ? null : _onSkip,
                  child: Text(
                    isLastPage ? '' : 'Skip Onboarding',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _titles.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 300),
                              child: _buildVisual(index),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              _titles[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: kTextDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _descriptions[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _titles.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? kPrimary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goToNextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildVisual(int index) {
    switch (index) {
      case 0:
        return const _PhotoVisualCard();
      case 1:
        return const _ScheduleMockupCard();
      case 2:
        return const _AnalyticsMockupCard();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// PAGE 1 — "Elevate Your Teaching"
// Placeholder card. Replace the gradient+icon block below with:
//   Image.asset('assets/images/onboarding_ai_insights.png', fit: BoxFit.cover)
// once Humaira drops the real photo/illustration asset in.
// ---------------------------------------------------------------------------
class _PhotoVisualCard extends StatelessWidget {
  const _PhotoVisualCard();

  // NOTE: This is a fully illustrated (icon/shape-based) stand-in scene —
  // a teacher silhouette at a desk with floating AI panels — built entirely
  // from Flutter widgets, no image asset needed. Once a real photo/illustration
  // is ready, this whole Container can be swapped for:
  //   Image.asset('assets/images/onboarding_ai_insights.png', fit: BoxFit.cover)

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: double.infinity,
          height: 260,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/onboarding_ai_insights.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Falls back to the illustrated placeholder if the asset
              // isn't found yet (wrong path/name in pubspec.yaml).
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kGradientStart, kGradientEnd],
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_rounded,
                    size: 48, color: Colors.white70),
              );
            },
          ),
        ),

        // Floating "AI Grading Active" chip like the Figma reference
        Positioned(
          bottom: -18,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Grading Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kTextDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

// ---------------------------------------------------------------------------
// PAGE 2 — "Manage Your Time" (schedule mockup card)
// ---------------------------------------------------------------------------
class _ScheduleMockupCard extends StatelessWidget {
  const _ScheduleMockupCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 16, color: kPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'September 2024',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: kTextDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.chevron_left_rounded,
                      size: 18, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _scheduleRow(
            day: 'MON',
            date: '18',
            title: 'Computer Science 101',
            subtitle: '@ 08:00 AM',
            badge: 'Smart update! Room changed to B-12',
          ),
          const Divider(height: 24),
          _scheduleRow(
            day: 'MON',
            date: '18',
            title: 'Staff Meeting',
            subtitle: '@ Room 402, Block B',
          ),
          const Divider(height: 24),
          _scheduleRow(
            day: 'MON',
            date: '18',
            title: 'Lab: Robotics II',
            subtitle: '@ Lab Prep',
          ),
        ],
      ),
    );
  }

  Widget _scheduleRow({
    required String day,
    required String date,
    required String title,
    required String subtitle,
    String? badge,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                day,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: kPrimary,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              if (badge != null) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kGradientStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded,
                          size: 11, color: kGradientStart),
                      const SizedBox(width: 4),
                      Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: kGradientStart,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PAGE 3 — "Empower Every Student" (analytics mockup card)
// ---------------------------------------------------------------------------
class _AnalyticsMockupCard extends StatelessWidget {
  const _AnalyticsMockupCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column — Class Engagement (top) + Risk Alerts (bottom)
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _statCard(
                label: 'CLASS ENGAGEMENT',
                value: '94.2%',
                valueColor: kPrimary,
                subtitle: 'Avg. Student Participation',
                icon: Icons.trending_up_rounded,
                iconColor: Colors.green,
              ),
              const SizedBox(height: 12),
              _statCard(
                label: 'RISK ALERTS',
                value: '03',
                valueColor: kPrimary,
                subtitle: 'Students need review',
                icon: Icons.warning_rounded,
                iconColor: kPrimary,
                iconOnLeft: true,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Right column — Top Performer (top) + small action card (bottom)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _topPerformerCard(),
              const SizedBox(height: 12),
              _actionSquareCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required Color valueColor,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    bool iconOnLeft = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (iconOnLeft) ...[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 12, color: iconColor),
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              if (!iconOnLeft) Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _topPerformerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performer',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPrimary, width: 1.5),
                color: kPrimary.withOpacity(0.08),
              ),
              child: const Icon(Icons.person_rounded,
                  size: 22, color: kPrimary),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Alex Rivera',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          Text(
            'Biology 101',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _actionSquareCard() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kGradientStart, kGradientEnd],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.send_rounded, size: 22, color: Colors.white),
      ),
    );
  }
}