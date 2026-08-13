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
    with TickerProviderStateMixin {
  late AnimationController _seagrassController;
  late AnimationController _bubbleController;

  @override
  void initState() {
    super.initState();
    _seagrassController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _seagrassController.dispose();
    _bubbleController.dispose();
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
            child: AnimatedBuilder(
              animation: _bubbleController,
              builder: (context, _) => CustomPaint(
                painter: _AquariumBubblesPainter(progress: _bubbleController.value),
              ),
            ),
          ),
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
  final double progress;
  _AquariumBubblesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF80EED3).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final specs = [
      (xRatio: 0.10, speed: 1.0, radius: 14.0, phase: 0.0),
      (xRatio: 0.25, speed: 0.7, radius: 22.0, phase: 0.3),
      (xRatio: 0.40, speed: 1.3, radius: 9.0, phase: 0.6),
      (xRatio: 0.55, speed: 0.9, radius: 18.0, phase: 0.2),
      (xRatio: 0.70, speed: 1.1, radius: 26.0, phase: 0.5),
      (xRatio: 0.85, speed: 0.8, radius: 12.0, phase: 0.8),
      (xRatio: 0.18, speed: 1.4, radius: 8.0, phase: 0.1),
      (xRatio: 0.92, speed: 1.2, radius: 16.0, phase: 0.7),
    ];

    for (final spec in specs) {
      final yProgress = (progress * spec.speed + spec.phase) % 1.0;
      final y = size.height * (1.0 - yProgress);
      final x =
          size.width * spec.xRatio + math.sin(yProgress * 4 * math.pi) * 12.0;
      final pos = Offset(x, y);
      final r = spec.radius;

      canvas.drawCircle(pos, r, bubblePaint);
      canvas.drawCircle(pos, r, borderPaint);
      canvas.drawCircle(
          Offset(pos.dx - r * 0.35, pos.dy - r * 0.35), r * 0.22, shinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AquariumBubblesPainter oldDelegate) =>
      oldDelegate.progress != progress;
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
