import 'package:flutter/material.dart';
import '../theme/fish_theme.dart';

class CoinsNetWorthCard extends StatelessWidget {
  final int availableCoins, boughtFishCoins, totalCoins, ownedFishCount, userExp;

  const CoinsNetWorthCard(
      {super.key,
      required this.availableCoins,
      required this.boughtFishCoins,
      required this.totalCoins,
      required this.ownedFishCount,
      this.userExp = 0});

  Widget _col(IconData icon, Color color, String val, String label) =>
      Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(val,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: FishTheme.textSubtle, fontSize: 10))
      ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF04253A), Color(0xFF083D56)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: FishTheme.cyanAccent.withValues(alpha: 0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.stars_rounded, color: FishTheme.cyanAccent, size: 22),
            SizedBox(width: 8),
            Text('Explorer Stats & Net Worth',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _col(Icons.monetization_on_rounded, Colors.amber, '$availableCoins',
                'Coins'),
            Container(height: 36, width: 1, color: Colors.white24),
            _col(Icons.set_meal_rounded, const Color(0xFF00F5D4),
                '$boughtFishCoins', 'Fish ($ownedFishCount)'),
            Container(height: 36, width: 1, color: Colors.white24),
            _col(Icons.military_tech_rounded, const Color(0xFFFF70A6),
                '$totalCoins', 'Net Coins'),
            Container(height: 36, width: 1, color: Colors.white24),
            _col(Icons.star_rounded, FishTheme.cyanAccent,
                '$userExp', 'Total EXP'),
          ]),
          const SizedBox(height: 14),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12)),
              child: Text(
                  'Total Coins ($totalCoins) = Fish Bought ($boughtFishCoins) + Available Coins ($availableCoins)',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
