import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/fish_model.dart';
import '../../services/firebaseauth_service.dart';
import '../../theme/fish_theme.dart';
import '../../widgets/navigation.dart';
import '../../widgets/aquarium_background.dart';

class FishTankScreen extends StatefulWidget {
  const FishTankScreen({super.key});
  @override
  State<FishTankScreen> createState() => _FishTankScreenState();
}

class _FishTankScreenState extends State<FishTankScreen>
    with TickerProviderStateMixin {
  final _auth = FirebaseAuthServices(), _random = Random();
  final List<_SwimmingFishState> _swimmingFishes = [];
  List<FishItem> _ownedFishItems = [];
  bool _isLoading = true;
  late AnimationController _swimController;

  @override
  void initState() {
    super.initState();
    _swimController =
        AnimationController(vsync: this, duration: const Duration(seconds: 120))
          ..repeat();
    _loadOwnedFishes();
  }

  @override
  void dispose() {
    _swimController.dispose();
    super.dispose();
  }

  Future<void> _loadOwnedFishes() async {
    final user = _auth.currentUser;
    if (user != null) {
      final ownedNames = await _auth.getOwnedFishes(user.uid);
      final items = FishItem.defaultMarketCatalog
          .where((item) => ownedNames.contains(item.name))
          .toList();
      if (mounted) {
        setState(() {
          _ownedFishItems = items;
          _isLoading = false;
          _swimmingFishes.clear();
          for (var item in items) {
            _swimmingFishes.add(_SwimmingFishState(
                fish: item,
                startX: _random.nextDouble(),
                startY: 0.15 + _random.nextDouble() * 0.55,
                speedX: 2.0 + _random.nextDouble() * 3.0,
                facingRight: _random.nextBool(),
                scale: 0.8 + _random.nextDouble() * 0.4));
          }
        });
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showFishDetails(FishItem fish) => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: FishTheme.oceanCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(fish.imageAsset,
                height: 100, width: 100, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Text(fish.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(fish.description,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: FishTheme.textSubtle, fontSize: 13))
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close 💙',
                    style: TextStyle(color: FishTheme.cyanAccent)))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: AppBottomNavBar.aboutFab(context),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
        body: AquariumBackground(
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 70,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                            color: FishTheme.oceanCard.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: FishTheme.cyanAccent
                                    .withValues(alpha: 0.3))),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                const Text('🐠', style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('My Fish Tank',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      Text(
                                          '${_ownedFishItems.length} / ${FishItem.defaultMarketCatalog.length} Fishes Unlocked',
                                          style: const TextStyle(
                                              color: FishTheme.cyanGlow,
                                              fontSize: 12))
                                    ])
                              ]),
                              IconButton(
                                  icon: const Icon(Icons.refresh_rounded,
                                      color: FishTheme.cyanAccent, size: 20),
                                  onPressed: _loadOwnedFishes)
                            ]),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF041926).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.6),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app_rounded,
                                color: Colors.amber, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Click on the fishes to know more about this fish!',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 170.0, bottom: 20),
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: FishTheme.cyanAccent))
                        : _ownedFishItems.isEmpty
                            ? _emptyState()
                            : AnimatedBuilder(
                                animation: _swimController,
                                builder: (context, _) => LayoutBuilder(
                                    builder: (context, c) => Stack(
                                            children: _swimmingFishes.map((s) {
                                          double totalDist = s.startX +
                                              (s.facingRight ? 1 : -1) *
                                                  s.speedX *
                                                  _swimController.value;
                                          double cycle = totalDist % 2.0;
                                          if (cycle < 0) cycle += 2.0;

                                          double x;
                                          bool isFacingRight;
                                          if (cycle <= 1.0) {
                                            x = cycle;
                                            isFacingRight = s.facingRight;
                                          } else {
                                            x = 2.0 - cycle;
                                            isFacingRight = !s.facingRight;
                                          }

                                          double y = s.startY +
                                              sin(_swimController.value *
                                                          2 *
                                                          pi +
                                                      s.startX * 10) *
                                                  0.05;
                                          return Positioned(
                                              left: x * (c.maxWidth - 70),
                                              top: y * (c.maxHeight - 70),
                                              child: GestureDetector(
                                                  onTap: () =>
                                                      _showFishDetails(s.fish),
                                                  child: Transform.scale(
                                                      scale: s.scale,
                                                      child: Transform.flip(
                                                          flipX: !isFacingRight,
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                        color: FishTheme.cyanAccent.withValues(
                                                                            alpha: 0.2),
                                                                        blurRadius:
                                                                            10,
                                                                        spreadRadius:
                                                                            2)
                                                                  ]),
                                                              child: Image.asset(
                                                                  s.fish
                                                                      .imageAsset,
                                                                  height: 65,
                                                                  width: 65,
                                                                  fit: BoxFit
                                                                      .contain))))));
                                        }).toList()))),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _emptyState() => Center(
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: FishTheme.oceanCard.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: FishTheme.cyanAccent.withValues(alpha: 0.3))),
          child: const Column(mainAxisSize: MainAxisSize.min, children: [
            Text('🌊 🐠 🌊', style: TextStyle(fontSize: 44)),
            SizedBox(height: 12),
            Text('Your Fish Tank is empty!',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            SizedBox(height: 8),
            Text(
                'Buy cute fishes in the Marketplace tab using coins earned from playing games!',
                textAlign: TextAlign.center,
                style: TextStyle(color: FishTheme.textSubtle, fontSize: 13))
          ])));
}

class _SwimmingFishState {
  final FishItem fish;
  final double startX, startY, speedX, scale;
  final bool facingRight;
  _SwimmingFishState(
      {required this.fish,
      required this.startX,
      required this.startY,
      required this.speedX,
      required this.facingRight,
      required this.scale});
}
