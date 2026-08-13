import 'package:flutter/material.dart';
import '../../models/fish_model.dart';
import '../../services/firebaseauth_service.dart';
import '../../theme/fish_theme.dart';
import '../../widgets/navigation.dart';
import '../../widgets/aquarium_background.dart';
import '../../widgets/coins_display.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final _auth = FirebaseAuthServices();
  int _userCoins = 0;
  List<String> _ownedFishes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final coins = await _auth.getUserCoins(user.uid),
          owned = await _auth.getOwnedFishes(user.uid);
      if (mounted) {
        setState(() {
          _userCoins = coins;
          _ownedFishes = owned;
          _isLoading = false;
        });
      }
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBuyFish(FishItem fish) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (_ownedFishes.contains(fish.name)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('You already own ${fish.name}! 🐟'),
          backgroundColor: Colors.amber.shade800));
      return;
    }
    if (_userCoins < fish.price) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Insufficient coins! Need ${fish.price} coins. 🪙'),
          backgroundColor: FishTheme.coralPink));
      return;
    }
    if (await _auth.buyFish(
        uid: user.uid, fishName: fish.name, price: fish.price)) {
      await _loadUserData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('🎉 Congratulations! You unlocked ${fish.name}!'),
            backgroundColor: FishTheme.cyanGlow));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: AppBottomNavBar.aboutFab(context),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
        body: AquariumBackground(
          centerWidget:
              CoinsDisplay(availableCoins: _userCoins, showTotal: false),
          child: SafeArea(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: FishTheme.cyanAccent))
                : Column(
                    children: [
                      const SizedBox(height: 80),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 8.0),
                          child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF042033).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: FishTheme.cyanAccent
                                          .withValues(alpha: 0.3))),
                              child: const Row(children: [
                                Icon(Icons.storefront_rounded,
                                    color: Colors.amber, size: 24),
                                SizedBox(width: 10),
                                Expanded(
                                    child: Text(
                                        'Temasek Fish Market: Buy & collect native species to grow your net worth!',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5)))
                              ]))),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 8.0),
                          itemCount: FishItem.defaultMarketCatalog.length,
                          itemBuilder: (context, i) {
                            final fish = FishItem.defaultMarketCatalog[i],
                                isOwned = _ownedFishes.contains(fish.name);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14.0),
                              padding: const EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                  color: isOwned
                                      ? const Color(0xFF073047).withValues(alpha: 0.9)
                                      : FishTheme.oceanCard.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: isOwned
                                          ? FishTheme.cyanAccent
                                          : FishTheme.cyanAccent
                                              .withValues(alpha: 0.3),
                                      width: isOwned ? 1.8 : 1.2),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4))
                                  ]),
                              child: Row(
                                children: [
                                  Container(
                                      width: 70,
                                      height: 70,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF041926),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: FishTheme.cyanAccent
                                                  .withValues(alpha: 0.3))),
                                      child: Image.asset(fish.imageAsset,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) =>
                                              const Center(
                                                  child: Text('🐠',
                                                      style: TextStyle(
                                                          fontSize: 32))))),
                                  const SizedBox(width: 14),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(fish.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text(fish.description,
                                            style: const TextStyle(
                                                color: FishTheme.textSubtle,
                                                fontSize: 11),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 8),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('🪙 ${fish.price} Coins',
                                                  style: const TextStyle(
                                                      color: Colors.amber,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13)),
                                              ElevatedButton(
                                                  onPressed: isOwned
                                                      ? null
                                                      : () =>
                                                          _handleBuyFish(fish),
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor: isOwned
                                                          ? Colors.grey.shade800
                                                          : FishTheme
                                                              .cyanAccent,
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 14,
                                                          vertical: 6),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  12))),
                                                  child: Text(
                                                      isOwned
                                                          ? 'OWNED ✔'
                                                          : 'BUY FISH 🛒',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11,
                                                          color: isOwned
                                                              ? Colors.white54
                                                              : FishTheme.primaryDark)))
                                            ])
                                      ])),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      );
}
