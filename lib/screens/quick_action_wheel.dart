import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// A single action bubble on the wheel.
class QuickActionItem {
  const QuickActionItem({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF4A5AE8),
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
}

/// Reusable draggable circular carousel of quick-action bubbles.
///
/// Use this same widget on any screen (Dashboard, Classes, Attendance, etc.)
/// with a different `items` list and `hubTitle` so the whole app shares one
/// consistent "quick actions" design instead of mixing wheels, grids, and
/// cards on different screens.
///
/// IMPORTANT: drag-to-rotate and tap-an-item both live on a single
/// GestureDetector (not nested ones). Nesting a pan GestureDetector around
/// per-item tap GestureDetectors causes the drag recognizer to win the
/// gesture arena over the tap recognizer, so individual items silently stop
/// responding to taps. Keeping everything on one detector and manually
/// figuring out which item (if any) was tapped avoids that conflict.
///
/// Usage:
/// ```dart
/// QuickActionsWheel(
///   hubTitle: 'Class Actions',
///   items: [
///     QuickActionItem(icon: Icons.people_outline, label: 'Roster', onTap: () {}),
///     QuickActionItem(icon: Icons.grade_outlined, label: 'Grades', onTap: () {}),
///   ],
/// )
/// ```
class QuickActionsWheel extends StatefulWidget {
  const QuickActionsWheel({
    super.key,
    required this.items,
    this.hubTitle = 'Quick Actions',
    this.hubSubtitle = 'Everything at\nyour fingertips',
    this.wheelSize = 280,
    this.darkText = const Color(0xFF1E1B3A),
  });

  final List<QuickActionItem> items;
  final String hubTitle;
  final String hubSubtitle;
  final double wheelSize;
  final Color darkText;

  @override
  State<QuickActionsWheel> createState() => _QuickActionsWheelState();
}

class _QuickActionsWheelState extends State<QuickActionsWheel>
    with SingleTickerProviderStateMixin {
  double _rotation = 0; // current rotation, radians
  double _rotationAtDragStart = 0;
  double _dragStartAngle = 0;

  late final AnimationController _snapController;
  Animation<double>? _snapAnimation;

  double get _radius => widget.wheelSize / 2 - 40;
  Offset get _center => Offset(widget.wheelSize / 2, widget.wheelSize / 2);

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
      if (_snapAnimation != null) {
        setState(() => _rotation = _snapAnimation!.value);
      }
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  double _angleFromCenter(Offset localPosition) {
    final vector = localPosition - _center;
    return math.atan2(vector.dy, vector.dx);
  }

  void _onPanStart(DragStartDetails details) {
    _snapController.stop();
    _dragStartAngle = _angleFromCenter(details.localPosition);
    _rotationAtDragStart = _rotation;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final currentAngle = _angleFromCenter(details.localPosition);
    var delta = currentAngle - _dragStartAngle;
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    setState(() => _rotation = _rotationAtDragStart + delta);
  }

  void _onPanEnd(DragEndDetails details) {
    final n = widget.items.length;
    final slot = (2 * math.pi) / n;
    final nearestSlot = (_rotation / slot).round() * slot;
    _snapAnimation = Tween<double>(begin: _rotation, end: nearestSlot).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );
    _snapController.forward(from: 0);
  }

  // Figures out which bubble (if any) was tapped, based on the tap's angle
  // and distance from center, then fires that item's onTap.
  void _handleTapUp(TapUpDetails details) {
    final n = widget.items.length;
    if (n == 0) return;

    final vector = details.localPosition - _center;
    final tapRadius = vector.distance;
    final tapAngle = math.atan2(vector.dy, vector.dx);

    // Ignore taps on the center hub or outside the ring entirely.
    if (tapRadius < _radius - 40 || tapRadius > _radius + 40) return;

    int closestIndex = 0;
    double closestDiff = double.infinity;
    for (var i = 0; i < n; i++) {
      final baseAngle = (2 * math.pi * i / n) - math.pi / 2;
      final absoluteAngle = baseAngle + _rotation;
      var diff = (tapAngle - absoluteAngle) % (2 * math.pi);
      if (diff > math.pi) diff -= 2 * math.pi;
      if (diff < -math.pi) diff += 2 * math.pi;
      diff = diff.abs();
      if (diff < closestDiff) {
        closestDiff = diff;
        closestIndex = i;
      }
    }

    // Only fire if the tap landed reasonably close to that bubble's slice.
    if (closestDiff < (math.pi / n)) {
      widget.items[closestIndex].onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.items.length;
    final size = widget.wheelSize;
    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onTapUp: _handleTapUp,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // faint outer track ring (purely decorative)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4A5AE8).withOpacity(0.10),
                  width: 1.4,
                ),
              ),
            ),
            // rotating ring of action bubbles (display only — no gesture
            // detectors here; tap handling happens on the outer detector)
            Transform.rotate(
              angle: _rotation,
              child: Stack(
                alignment: Alignment.center,
                children: List.generate(n, (i) {
                  final baseAngle = (2 * math.pi * i / n) - math.pi / 2;
                  final dx = _radius * math.cos(baseAngle);
                  final dy = _radius * math.sin(baseAngle);
                  final item = widget.items[i];
                  return Transform.translate(
                    offset: Offset(dx, dy),
                    // counter-rotate so each bubble + its label stays upright
                    // while it swings around the circle
                    child: Transform.rotate(
                      angle: -_rotation,
                      child: _wheelItem(item),
                    ),
                  );
                }),
              ),
            ),
            // center hub
            Container(
              width: 118,
              height: 118,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface(context),
                boxShadow: [
                  BoxShadow(
                    color: widget.darkText.withOpacity(0.08),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.hubTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: widget.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.hubSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.darkText.withOpacity(0.6),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wheelItem(QuickActionItem item) {
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              shape: BoxShape.circle,
              border: Border.all(color: item.color.withOpacity(0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: widget.darkText.withOpacity(0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 66,
            child: Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: widget.darkText,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}