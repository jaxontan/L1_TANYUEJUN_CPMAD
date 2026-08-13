import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screen/Leaderboard/leaderboard_screen.dart';
import '../screen/Profile/profile.dart';

class AquariumBackground extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLeaderboardTap, onProfileTap;
  final bool isLeaderboardActive, isProfileActive, showTopNav;
  final Widget? centerWidget;

  const AquariumBackground(
      {super.key,
      required this.child,
      this.onLeaderboardTap,
      this.onProfileTap,
      this.isLeaderboardActive = false,
      this.isProfileActive = false,
      this.centerWidget,
      this.showTopNav = true});

  @override
  State<AquariumBackground> createState() => _AquariumBackgroundState();
}

class _AquariumBackgroundState extends State<AquariumBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _seagrassController;

  @override
  void initState() {
    super.initState();
    _seagrassController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _seagrassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lbAction = widget.onLeaderboardTap ??
        (widget.isLeaderboardActive
            ? () {}
            : () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen())));
    final profAction = widget.onProfileTap ??
        (widget.isProfileActive
            ? () {}
            : () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen())));

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color(0xFF031926),
            Color(0xFF083D56),
            Color(0xFF0C597C),
            Color(0xFF063A52)
          ],
              stops: [
            0.0,
            0.4,
            0.75,
            1.0
          ])),
      child: Stack(
        children: [
          Positioned.fill(
              child: CustomPaint(painter: _AquariumBubblesPainter())),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _seagrassController,
              builder: (context, _) => CustomPaint(
                painter:
                    _SeagrassPainter(animationValue: _seagrassController.value),
              ),
            ),
          ),
          Positioned(
              top: -60,
              right: -60,
              child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00F5D4).withValues(alpha: 0.12),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF00F5D4).withValues(alpha: 0.2),
                            blurRadius: 100,
                            spreadRadius: 40)
                      ]))),
          Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF70A6).withValues(alpha: 0.1),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFFFF70A6).withValues(alpha: 0.15),
                            blurRadius: 120,
                            spreadRadius: 50)
                      ]))),
          SafeArea(child: widget.child),
          if (widget.showTopNav)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _FloatingNavPill(
                          label: '🏆 Leaderboard',
                          onTap: lbAction,
                          isActive: widget.isLeaderboardActive),
                      if (widget.centerWidget != null)
                        widget.centerWidget!
                      else
                        const SizedBox(width: 1),
                      _FloatingNavPill(
                          label: '👤 Profile',
                          onTap: profAction,
                          isActive: widget.isProfileActive,
                          activeBorderColor: const Color(0xFF00F5D4),
                          activeTextColor: const Color(0xFF00F5D4)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AquariumBubblesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF80EED3).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final bubbles = [
      Offset(size.width * 0.15, size.height * 0.18),
      Offset(size.width * 0.85, size.height * 0.25),
      Offset(size.width * 0.25, size.height * 0.45),
      Offset(size.width * 0.75, size.height * 0.60),
      Offset(size.width * 0.10, size.height * 0.78),
      Offset(size.width * 0.90, size.height * 0.82),
      Offset(size.width * 0.50, size.height * 0.10),
      Offset(size.width * 0.35, size.height * 0.88)
    ];
    final radii = [14.0, 22.0, 9.0, 18.0, 26.0, 12.0, 8.0, 16.0];

    for (int i = 0; i < bubbles.length; i++) {
      final pos = bubbles[i];
      final r = radii[i % radii.length];
      canvas.drawCircle(pos, r, bubblePaint);
      canvas.drawCircle(pos, r, borderPaint);
      canvas.drawCircle(
          Offset(pos.dx - r * 0.35, pos.dy - r * 0.35), r * 0.22, shinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SeagrassPainter extends CustomPainter {
  final double animationValue;
  _SeagrassPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final blades = [
      const _SeagrassBlade(
          xRatio: 0.05,
          height: 120,
          baseWidth: 16,
          swayMax: 18,
          color: Color(0x6600E676),
          phase: 0.0),
      const _SeagrassBlade(
          xRatio: 0.12,
          height: 160,
          baseWidth: 20,
          swayMax: 24,
          color: Color(0x7300F5D4),
          phase: 0.5),
      const _SeagrassBlade(
          xRatio: 0.20,
          height: 110,
          baseWidth: 14,
          swayMax: 15,
          color: Color(0x591DE9B6),
          phase: 1.0),
      const _SeagrassBlade(
          xRatio: 0.35,
          height: 140,
          baseWidth: 18,
          swayMax: 20,
          color: Color(0x6600B0FF),
          phase: 1.5),
      const _SeagrassBlade(
          xRatio: 0.45,
          height: 170,
          baseWidth: 22,
          swayMax: 28,
          color: Color(0x7300E676),
          phase: 2.0),
      const _SeagrassBlade(
          xRatio: 0.60,
          height: 130,
          baseWidth: 16,
          swayMax: 18,
          color: Color(0x661DE9B6),
          phase: 0.7),
      const _SeagrassBlade(
          xRatio: 0.75,
          height: 180,
          baseWidth: 24,
          swayMax: 30,
          color: Color(0x8000F5D4),
          phase: 2.5),
      const _SeagrassBlade(
          xRatio: 0.85,
          height: 125,
          baseWidth: 15,
          swayMax: 16,
          color: Color(0x5900B0FF),
          phase: 1.2),
      const _SeagrassBlade(
          xRatio: 0.94,
          height: 150,
          baseWidth: 19,
          swayMax: 22,
          color: Color(0x7300E676),
          phase: 3.0),
    ];

    for (final blade in blades) {
      final xBase = size.width * blade.xRatio;
      final yBase = size.height;
      final bladeSway =
          math.sin((animationValue * 2 * math.pi) + blade.phase) * blade.swayMax;

      final path = Path();
      path.moveTo(xBase - blade.baseWidth / 2, yBase);
      path.quadraticBezierTo(
        xBase + bladeSway * 0.5 - blade.baseWidth / 4,
        yBase - blade.height * 0.5,
        xBase + bladeSway,
        yBase - blade.height,
      );
      path.quadraticBezierTo(
        xBase + bladeSway * 0.5 + blade.baseWidth / 4,
        yBase - blade.height * 0.5,
        xBase + blade.baseWidth / 2,
        yBase,
      );
      path.close();

      final paint = Paint()
        ..color = blade.color
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SeagrassPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class _SeagrassBlade {
  final double xRatio, height, baseWidth, swayMax, phase;
  final Color color;

  const _SeagrassBlade({
    required this.xRatio,
    required this.height,
    required this.baseWidth,
    required this.swayMax,
    required this.color,
    required this.phase,
  });
}

class _FloatingNavPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isActive;
  final Color activeBorderColor, activeTextColor;

  const _FloatingNavPill(
      {required this.label,
      this.onTap,
      this.isActive = false,
      this.activeBorderColor = const Color(0xFFFF70A6),
      this.activeTextColor = const Color(0xFFFF70A6)});

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isActive ? activeBorderColor : const Color(0xFF00F5D4).withValues(alpha: 0.8);
    final textColor = isActive ? activeTextColor : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: const Color(0xFF042033).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6)
            ]),
        child: Text(label,
            style: TextStyle(
                color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
