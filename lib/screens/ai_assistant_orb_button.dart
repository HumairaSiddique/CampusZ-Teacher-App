import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Floating AI Assistant orb — the glowing bot bubble that sits centered
/// above the bottom navigation bar, matching the CampusZ Figma design.
///
/// It has a soft breathing glow, a tiny twinkle accent, and a gentle
/// press-scale animation. Wire `onTap` to open your AI chat screen.
///
/// --- How to use it inside MainNavigationScreen ---
/// Wrap your existing bottom bar in a Stack so the orb can float above it:
///
/// ```dart
/// Scaffold(
///   body: yourCurrentScreen,
///   bottomNavigationBar: SizedBox(
///     height: 78, // a bit taller so the orb has room to overlap upward
///     child: Stack(
///       clipBehavior: Clip.none,
///       alignment: Alignment.bottomCenter,
///       children: [
///         // your existing BottomNavigationBar / custom nav bar
///         Positioned(
///           left: 0,
///           right: 0,
///           bottom: 0,
///           child: yourBottomNavBar,
///         ),
///         // the floating AI orb, raised above the bar
///         Positioned(
///           bottom: 26,
///           child: AiAssistantOrbButton(
///             onTap: () {
///               // e.g. Navigator.pushNamed(context, '/ai-chat');
///             },
///           ),
///         ),
///       ],
///     ),
///   ),
/// )
/// ```
///
/// If your bottom bar already has a notch cut out for a center FAB (e.g.
/// via `Scaffold.bottomNavigationBar` + `floatingActionButtonLocation:
/// FloatingActionButtonLocation.centerDocked`), you can drop this widget in
/// as the `floatingActionButton` directly instead of using a Stack.
class AiAssistantOrbButton extends StatefulWidget {
  const AiAssistantOrbButton({
    super.key,
    required this.onTap,
    this.size = 64,
  });

  /// Called when the orb is tapped — hook up navigation to your AI chat here.
  final VoidCallback onTap;

  /// Diameter of the core orb (the glow ring adds extra space around it).
  final double size;

  @override
  State<AiAssistantOrbButton> createState() => _AiAssistantOrbButtonState();
}

class _AiAssistantOrbButtonState extends State<AiAssistantOrbButton>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _tapController;

  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) => _tapController.reverse(),
      onTapCancel: () => _tapController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowController, _tapController]),
        builder: (context, child) {
          final glow = _glowController.value; // 0..1 breathing cycle
          final scale = 1 - _tapController.value;
          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: widget.size + 44,
              height: widget.size + 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // outer breathing glow
                  Container(
                    width: widget.size + 30 + (glow * 12),
                    height: widget.size + 30 + (glow * 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          gradientStart.withOpacity(0.35 - glow * 0.12),
                          gradientEnd.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  // ring so the orb separates cleanly from the nav bar
                  Container(
                    width: widget.size + 10,
                    height: widget.size + 10,
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // core gradient orb
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [gradientStart, gradientEnd],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradientEnd.withOpacity(0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: widget.size * 0.42,
                    ),
                  ),
                  // twinkle accent
                  Positioned(
                    top: 6,
                    right: 8,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: Colors.white.withOpacity(0.35 + glow * 0.65),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}