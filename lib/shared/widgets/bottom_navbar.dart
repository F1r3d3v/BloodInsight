import 'dart:math' as math;

import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FloatingBottomNavBar extends StatelessWidget {
  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: Sizes.kPadd10,
      child: Stack(
        children: [
          Container(
            height: 65,
            margin: Sizes.kPaddH10,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: const MyBorderShape(notchMargin: 4),
              shadows: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Left side items
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavBarItem(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        isSelected: currentIndex == 0,
                        onTap: () => context.go('/dashboard'),
                      ),
                      _NavBarItem(
                        icon: Icons.history_outlined,
                        label: 'History',
                        isSelected: currentIndex == 1,
                        onTap: () => context.go('/bloodwork'),
                      ),
                    ],
                  ),
                ),
                // Space for FAB
                Sizes.kGap64,
                // Right side items
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavBarItem(
                        icon: Icons.analytics_outlined,
                        label: 'Insights',
                        isSelected: currentIndex == 2,
                        onTap: () => context.go('/insights'),
                      ),
                      _NavBarItem(
                        icon: Icons.map_outlined,
                        label: 'Map',
                        isSelected: currentIndex == 3,
                        onTap: () => context.go('/map'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor.withValues(alpha: 0.5),
            ),
            Sizes.kGap5,
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.withValues(alpha: 0.5),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyBorderShape extends ShapeBorder {
  const MyBorderShape({required this.notchMargin});

  final double notchMargin;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    // We build a path for the notch from 3 segments:
    // Segment A - a Bezier curve from the host's top edge to segment B.
    // Segment B - an arc with radius notchRadius.
    // Segment C - a Bezier curve from segment B back to the host's top edge.
    //
    // A detailed explanation and the derivation of the formulas below is
    // available at: https://goo.gl/Ufzrqn

    final guest = Rect.fromCenter(
      center: rect.center.translate(0, (-rect.height / 2) + 15),
      height: 64 + 2 * notchMargin,
      width: 64 + 2 * notchMargin,
    );

    final notchRadius = guest.width / 2;
    const s1 = 15.0;
    const s2 = 1.0;

    final r = notchRadius;
    final a = -1.0 * r - s2;
    final b = rect.top - guest.center.dy;

    final n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
    final p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final p2yA = math.sqrt(r * r - p2xA * p2xA);
    final p2yB = math.sqrt(r * r - p2xB * p2xB);

    final p = List<Offset>.filled(6, Offset.zero);

    // p0, p1, and p2 are the control points for segment A.
    p[0] = Offset(a - s1, b);
    p[1] = Offset(a, b);
    final cmp = b < 0 ? -1.0 : 1.0;
    p[2] = cmp * p2yA > cmp * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB);

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p[3] = Offset(-1.0 * p[2].dx, p[2].dy);
    p[4] = Offset(-1.0 * p[1].dx, p[1].dy);
    p[5] = Offset(-1.0 * p[0].dx, p[0].dy);

    // translate all points back to the absolute coordinate system.
    for (var i = 0; i < p.length; i += 1) {
      p[i] += guest.center;
    }

    return Path.combine(
      PathOperation.intersect,
      Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(p[0].dx, p[0].dy)
        ..quadraticBezierTo(p[1].dx, p[1].dy, p[2].dx, p[2].dy)
        ..arcToPoint(
          p[3],
          radius: Radius.circular(notchRadius),
          clockwise: false,
        )
        ..quadraticBezierTo(p[4].dx, p[4].dy, p[5].dx, p[5].dy)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.left, rect.bottom)
        ..close(),
      Path()
        ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(20)))
        ..close(),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
