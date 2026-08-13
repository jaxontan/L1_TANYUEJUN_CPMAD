import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/fish_model.dart';
import '../../models/game_card_model.dart';
import '../../services/firebaseauth_service.dart';
import '../../theme/fish_theme.dart';
import '../../widgets/navigation.dart';
import '../../widgets/aquarium_background.dart';

enum GameDifficulty { easy, medium, hard }

enum GameState { selectDifficulty, previewCards, playing, gameOver, victory }

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});
  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  final _auth = FirebaseAuthServices();

  static const int totalPairs = 8;

  int _getCoinReward(GameDifficulty d) =>
      d == GameDifficulty.easy ? 5 : (d == GameDifficulty.medium ? 10 : 15);

  int _getExpReward(GameDifficulty d) =>
      d == GameDifficulty.easy ? 5 : (d == GameDifficulty.medium ? 10 : 15);

  GameDifficulty _difficulty = GameDifficulty.easy;
  GameState _gameState = GameState.selectDifficulty;
  int _timeRemaining = 60, _previewCountdown = 5, _matchesFound = 0;
  Timer? _gameTimer, _previewTimer, _matchTimer;
  bool _isProcessing = false;
  List<FishCard> _cards = [];
  FishCard? _firstCard;

  @override
  void dispose() {
    _matchTimer?.cancel();
    _gameTimer?.cancel();
    _previewTimer?.cancel();
    super.dispose();
  }

  int _getTimer(GameDifficulty d) =>
      d == GameDifficulty.easy ? 60 : (d == GameDifficulty.medium ? 45 : 30);

  void _start(GameDifficulty d) {
    _difficulty = d;
    _timeRemaining = _getTimer(d);

    _matchTimer?.cancel();
    _gameTimer?.cancel();
    _previewTimer?.cancel();

    List<FishCard> cards = [];
    int id = 0;
    for (var item in FishItem.defaultMarketCatalog.take(totalPairs)) {
      cards.add(
        FishCard(
          id: id++,
          emoji: '🐠',
          name: item.name,
          imagePath: item.imageAsset,
          isFlipped: true,
        ),
      );
      cards.add(
        FishCard(
          id: id++,
          emoji: '🐠',
          name: item.name,
          imagePath: item.imageAsset,
          isFlipped: true,
        ),
      );
    }

    cards.shuffle();

    if (mounted) {
      setState(() {
        _cards = cards;
        _firstCard = null;
        _isProcessing = false;
        _matchesFound = 0;
        _previewCountdown = 5;
        _gameState = GameState.previewCards;
      });
    }

    _previewTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_previewCountdown > 1) {
        setState(() => _previewCountdown--);
      } else {
        _previewTimer?.cancel();

        setState(() {
          for (var c in _cards) {
            c.isFlipped = false;
          }
          _gameState = GameState.playing;
        });

        _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          if (_timeRemaining > 0) {
            setState(() => _timeRemaining--);
          } else {
            _gameTimer?.cancel();
            _handleTimeUp();
          }
        });
      }
    });
  }

  void _onCardTapped(FishCard card) {
    if (_gameState != GameState.playing ||
        card.isFlipped ||
        card.isMatched ||
        _isProcessing) {
      return;
    }

    if (_firstCard == null) {
      setState(() {
        card.isFlipped = true;
        _firstCard = card;
      });
    } else {
      final first = _firstCard!;
      if (first.id == card.id) return;

      setState(() {
        card.isFlipped = true;
        _isProcessing = true;
      });

      if (first.name == card.name) {
        setState(() {
          first.isMatched = card.isMatched = true;
          _matchesFound++;
          _firstCard = null;
          _isProcessing = false;
        });

        if (_matchesFound >= totalPairs) {
          _gameTimer?.cancel();
          _handleVictory();
        }
      } else {
        _matchTimer?.cancel();
        _matchTimer = Timer(const Duration(milliseconds: 700), () {
          if (mounted) {
            setState(() {
              first.isFlipped = card.isFlipped = false;
              _firstCard = null;
              _isProcessing = false;
            });
          }
        });
      }
    }
  }

  void _handleTimeUp() {
    setState(() => _gameState = GameState.gameOver);
    _dialog(
      title: '⏳ TIME UP!',
      titleColor: Colors.redAccent,
      subtitle: 'Keep Training Your Memory!',
      icon: '⏰',
      message:
          'You matched $_matchesFound / $totalPairs pairs before time ran out.',
    );
  }

  Future<void> _handleVictory() async {
    setState(() => _gameState = GameState.victory);

    final coinReward = _getCoinReward(_difficulty);
    final expReward = _getExpReward(_difficulty);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _auth.addCoins(user.uid, coinReward);
        await _auth.addExp(user.uid, expReward);
      } catch (_) {}
    }

    if (!mounted) return;
    _dialog(
      title: '🏆 VICTORY! 🏆',
      titleColor: Colors.amber,
      subtitle: 'Ocean Champion!',
      icon: '🎉',
      message:
          'You matched all 8 pairs on ${_difficulty.name.toUpperCase()} mode with $_timeRemaining seconds left!',
      extraWidget: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF041926),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 6),
            Text(
              '+$coinReward Coins',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.star_rounded, color: FishTheme.cyanAccent, size: 20),
            const SizedBox(width: 6),
            Text(
              '+$expReward EXP',
              style: const TextStyle(
                color: FishTheme.cyanAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _dialog({
    required String title,
    required Color titleColor,
    required String subtitle,
    required String icon,
    required String message,
    Widget? extraWidget,
  }) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: FishTheme.oceanCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: FishTheme.textSubtle, fontSize: 14),
          ),
          if (extraWidget != null) ...[const SizedBox(height: 14), extraWidget],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() => _gameState = GameState.selectDifficulty);
          },
          child: const Text(
            'Difficulty Menu ⚙️',
            style: TextStyle(color: FishTheme.cyanAccent),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: FishTheme.cyanAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
            _start(_difficulty);
          },
          child: const Text(
            'Play Again 🔄',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: AppBottomNavBar.aboutFab(context),
    bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    body: AquariumBackground(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),

            if (_gameState == GameState.selectDifficulty)
              Expanded(child: _difficultyMenu())
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: FishTheme.oceanCard.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: FishTheme.cyanAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            color: _timeRemaining <= 10
                                ? Colors.redAccent
                                : FishTheme.cyanAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Time: ${_timeRemaining}s',
                            style: TextStyle(
                              color: _timeRemaining <= 10
                                  ? Colors.redAccent
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Matched: $_matchesFound / $totalPairs',
                        style: const TextStyle(
                          color: FishTheme.cyanGlow,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _gameTimer?.cancel();
                          _previewTimer?.cancel();
                          setState(
                            () => _gameState = GameState.selectDifficulty,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF041926),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: FishTheme.cyanAccent.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Menu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_gameState == GameState.previewCards)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    left: 16.0,
                    right: 16.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.remove_red_eye_outlined,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Memorize the cards! Flipping in $_previewCountdown...',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 6),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    itemCount: _cards.length,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                    itemBuilder: (context, i) => _CardItem(
                      key: ValueKey(_cards[i].id),
                      card: _cards[i],
                      onTap: () => _onCardTapped(_cards[i]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _difficultyMenu() => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: FishTheme.oceanCard.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: FishTheme.cyanAccent.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🧠 MEMORY MATCH 🧠',
              style: TextStyle(
                color: FishTheme.cyanGlow,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select difficulty to start:',
              style: TextStyle(color: FishTheme.textSubtle, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _diffBtn(
              'EASY',
              '60 Seconds',
              5,
              5,
              Colors.greenAccent,
              GameDifficulty.easy,
            ),
            const SizedBox(height: 14),
            _diffBtn(
              'MEDIUM',
              '45 Seconds',
              10,
              10,
              Colors.orangeAccent,
              GameDifficulty.medium,
            ),
            const SizedBox(height: 14),
            _diffBtn(
              'HARD',
              '30 Seconds',
              15,
              15,
              Colors.redAccent,
              GameDifficulty.hard,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _diffBtn(
    String title,
    String time,
    int coins,
    int exp,
    Color color,
    GameDifficulty d,
  ) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF041926),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: color, width: 2),
            ),
          ),
          onPressed: () => _start(d),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on_rounded,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+$coins Coins',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.star_rounded,
                        color: FishTheme.cyanAccent,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+$exp EXP',
                        style: const TextStyle(
                          color: FishTheme.cyanAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _CardItem extends StatelessWidget {
  final FishCard card;
  final VoidCallback onTap;
  const _CardItem({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final showFront = card.isFlipped || card.isMatched;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Container(
          key: ValueKey<bool>(showFront),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: showFront
                ? const Color(0xFF042033)
                : const Color(0xFF0C4D6E),
            border: Border.all(
              color: card.isMatched
                  ? const Color(0xFF00F5D4)
                  : const Color(0xFF00B4D8).withValues(alpha: 0.6),
              width: card.isMatched ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: card.isMatched
                    ? const Color(0xFF00F5D4).withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: card.isMatched ? 8 : 4,
              ),
            ],
          ),
          child: Center(
            child: showFront
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (card.imagePath != null)
                        Image.asset(
                          card.imagePath!,
                          height: 38,
                          width: 38,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Text(
                            card.emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        )
                      else
                        Text(card.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          card.name,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Icon(
                    Icons.help_outline_rounded,
                    color: Color(0xFF00F5D4),
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
