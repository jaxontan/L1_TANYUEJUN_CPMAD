import 'package:flutter/material.dart';
import '../../theme/fish_theme.dart';
import '../../widgets/aquarium_background.dart';
import '../../widgets/navigation.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _sec(String title, String body) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: FishTheme.oceanCard.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: FishTheme.cyanAccent.withValues(alpha: 0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: FishTheme.cyanAccent,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6)),
          const SizedBox(height: 10),
          Text(body,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, height: 1.6))
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
        body: AquariumBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF042033),
                          border:
                              Border.all(color: FishTheme.cyanAccent, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: FishTheme.cyanAccent.withValues(alpha: 0.35),
                                blurRadius: 24,
                                spreadRadius: 4)
                          ]),
                      child: const Text('🐠', style: TextStyle(fontSize: 54))),
                  const SizedBox(height: 16),
                  const Text('Temasek Fishes',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  Text('Version 1.0.0 • Temasek Marine Explorer Edition',
                      style: TextStyle(
                          color: FishTheme.cyanAccent.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 28),
                  _sec('Theme',
                      'Explore Singapore\'s local marine biodiversity. Collect native fish species, grow your net worth, and compete with fellow explorers on the reef.'),
                  const SizedBox(height: 20),
                  _sec('How to Play',
                      '1. Start with 50 coins.\n2. Buy fish from the Marketplace.\n3. View your collection in My Aquarium.\n4. Play Memory Game to earn Coins & EXP rewards based on difficulty (Easy: 5, Medium: 10, Hard: 15).\n5. Check Leaderboard for EXP rankings.'),
                  const SizedBox(height: 24),
                  Text('© 2026 Temasek Fishes • Made with 💙 for Sea Explorers',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      );
}
