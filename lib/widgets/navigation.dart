import 'package:flutter/material.dart';
import '../theme/fish_theme.dart';
import '../screen/Marketplace/marketplace_screen.dart';
import '../screen/Games/memory_game_screen.dart';
import '../screen/FishTank/fish_tank_screen.dart';
import '../screen/About/about_screen.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback? onAboutTap;

  const AppBottomNavBar(
      {super.key, required this.currentIndex, this.onAboutTap});

  static Widget aboutFab(BuildContext context) => FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AboutScreen())),
        heroTag: 'about_fab',
        backgroundColor: FishTheme.cyanAccent,
        child: const Icon(Icons.info, color: Colors.white),
      );

  static Widget? buildAboutFab(VoidCallback? onAboutTap) => onAboutTap == null
      ? null
      : FloatingActionButton(
          onPressed: onAboutTap,
          heroTag: 'about_fab',
          backgroundColor: FishTheme.cyanAccent,
          child: const Icon(Icons.info, color: Colors.white));

  static const List<Widget> _screens = [
    MarketplaceScreen(),
    MemoryGameScreen(),
    FishTankScreen()
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex || index < 0 || index >= _screens.length) return;
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (_, _, _) => _screens[index],
            transitionDuration: Duration.zero));
  }

  @override
  Widget build(BuildContext context) {
    final isNone = currentIndex < 0;
    return Container(
      decoration: const BoxDecoration(
          color: Color(0xFF031926),
          border:
              Border(top: BorderSide(color: Color(0xFF00F5D4), width: 1.2))),
      child: BottomNavigationBar(
        currentIndex: isNone ? 0 : currentIndex.clamp(0, 2),
        onTap: (index) => _onTap(context, index),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: isNone ? FishTheme.textSubtle : FishTheme.cyanAccent,
        unselectedItemColor: FishTheme.textSubtle,
        selectedFontSize: isNone ? 11 : 12,
        unselectedFontSize: 11,
        selectedLabelStyle:
            TextStyle(fontWeight: isNone ? FontWeight.normal : FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.storefront_rounded),
              activeIcon: Icon(Icons.storefront_rounded,
                  color: Color(0xFFFF70A6), size: 26),
              label: 'Marketplace'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports_rounded),
              activeIcon: Icon(Icons.sports_esports_rounded,
                  color: FishTheme.cyanGlow, size: 26),
              label: 'Game'),
          BottomNavigationBarItem(
              icon: Icon(Icons.waves_rounded),
              activeIcon: Icon(Icons.waves_rounded,
                  color: FishTheme.cyanAccent, size: 26),
              label: 'Fish Tank'),
        ],
      ),
    );
  }
}
