import 'package:flutter/material.dart';
import '../theme/fish_theme.dart';
import 'aquarium_background.dart';

class AuthLayout extends StatelessWidget {
  final String title, subtitle, badgeText, bottomText, bottomLinkText;
  final String? emoji, imageAsset;
  final IconData badgeIcon;
  final Color badgeColor;
  final Widget formChild;
  final VoidCallback onBottomLinkTap;
  final bool showBackButton;

  const AuthLayout(
      {super.key,
      required this.title,
      required this.subtitle,
      this.emoji,
      this.imageAsset = 'assets/image.png',
      required this.badgeText,
      required this.badgeIcon,
      required this.badgeColor,
      required this.formChild,
      required this.bottomText,
      required this.bottomLinkText,
      required this.onBottomLinkTap,
      this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquariumBackground(
        showTopNav: false,
        child: SafeArea(
          child: Column(
            children: [
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                          decoration: BoxDecoration(
                              color: FishTheme.oceanCard.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:
                                      FishTheme.cyanAccent.withValues(alpha: 0.3))),
                          child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: FishTheme.cyanAccent),
                              onPressed: () => Navigator.pop(context)))),
                ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                                width: 104,
                                height: 104,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(colors: [
                                      badgeColor,
                                      FishTheme.cyanAccent,
                                      FishTheme.oceanBlue
                                    ]),
                                    boxShadow: [
                                      BoxShadow(
                                          color: badgeColor.withValues(alpha: 0.4),
                                          blurRadius: 22,
                                          spreadRadius: 3)
                                    ])),
                            Container(
                                width: 90,
                                height: 90,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF042033)),
                                child: Center(
                                    child: imageAsset != null
                                        ? ClipOval(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(imageAsset!,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (_, _, _) =>
                                                        Text(emoji ?? '🐟',
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        44)))))
                                        : Text(emoji ?? '🐟',
                                            style: const TextStyle(
                                                fontSize: 44)))),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: badgeColor.withValues(alpha: 0.4),
                                    width: 1)),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(badgeIcon, size: 16, color: badgeColor),
                              const SizedBox(width: 6),
                              Text(badgeText,
                                  style: TextStyle(
                                      color: badgeColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2))
                            ])),
                        const SizedBox(height: 12),
                        Text(title,
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.8,
                                shadows: [
                                  Shadow(color: badgeColor, blurRadius: 15)
                                ])),
                        const SizedBox(height: 6),
                        Text(subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 14, color: FishTheme.textSubtle)),
                        const SizedBox(height: 28),
                        Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                                color: FishTheme.oceanCard.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                    color:
                                        FishTheme.cyanAccent.withValues(alpha: 0.3),
                                    width: 1.2),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.35),
                                      blurRadius: 25,
                                      offset: const Offset(0, 12))
                                ]),
                            child: formChild),
                        const SizedBox(height: 24),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(bottomText,
                                  style: const TextStyle(
                                      color: FishTheme.textSubtle,
                                      fontSize: 14)),
                              GestureDetector(
                                  onTap: onBottomLinkTap,
                                  child: Text(bottomLinkText,
                                      style: const TextStyle(
                                          color: FishTheme.cyanAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              FishTheme.cyanAccent)))
                            ]),
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
}
