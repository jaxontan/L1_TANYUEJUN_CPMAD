import 'package:flutter/material.dart';
import '../theme/fish_theme.dart';

class CoinsDisplay extends StatelessWidget {
  final int availableCoins;
  final int? totalCoins;
  final bool showTotal;
  final double iconSize, fontSize;
  final EdgeInsetsGeometry padding;

  const CoinsDisplay(
      {super.key,
      required this.availableCoins,
      this.totalCoins,
      this.showTotal = true,
      this.iconSize = 15,
      this.fontSize = 12,
      this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6)});

  Widget _badge(IconData icon, Color color, String text) => Container(
        padding: padding,
        decoration: BoxDecoration(
            color: const Color(0xFF041926),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.6))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: iconSize),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize))
        ]),
      );

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        _badge(Icons.monetization_on_rounded, Colors.amber, '$availableCoins'),
        if (showTotal && totalCoins != null) ...[
          const SizedBox(width: 6),
          _badge(Icons.stars_rounded, FishTheme.cyanAccent, '$totalCoins Total')
        ]
      ]);
}
