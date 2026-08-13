import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/firebaseauth_service.dart';
import '../../theme/fish_theme.dart';
import '../../widgets/aquarium_background.dart';
import '../../widgets/navigation.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _auth = FirebaseAuthServices();

  Widget _badge(int rank) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: FishTheme.cyanAccent.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: FishTheme.cyanAccent.withValues(alpha: 0.8), width: 1.2)),
      child: Text('Rank $rank',
          style: const TextStyle(
              color: FishTheme.cyanAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12)));

  @override
  Widget build(BuildContext context) {
    final currentUid = _auth.currentUser?.uid;
    return Scaffold(
      floatingActionButton: AppBottomNavBar.aboutFab(context),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: -1),
      body: AquariumBackground(
        isLeaderboardActive: true,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 80),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                        color: const Color(0xFF042033).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: FishTheme.cyanAccent.withValues(alpha: 0.35))),
                    child: const Column(children: [
                      Text('🏆 LEADERBOARD',
                          style: TextStyle(
                              color: FishTheme.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.2)),
                      SizedBox(height: 4),
                      Text('Top Explorers Ranked by EXP Points',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: FishTheme.textSubtle, fontSize: 12))
                    ])),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _auth.streamAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: FishTheme.cyanAccent));
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.redAccent)));
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                          child: Text('No explorers found in Temasek Reef yet!',
                              style: TextStyle(color: FishTheme.textSubtle)));
                    }

                    final users = docs
                        .map((d) => UserProfile.fromFirestore(
                            d, _auth.calculateBoughtFishCoins))
                        .toList()
                      ..sort((a, b) {
                        final expCmp = b.exp.compareTo(a.exp);
                        if (expCmp != 0) return expCmp;
                        return b.totalCoins.compareTo(a.totalCoins);
                      });

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final u = users[index], isMe = u.uid == currentUid;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          decoration: BoxDecoration(
                              gradient: isMe
                                  ? const LinearGradient(colors: [
                                      Color(0xFF0A3E54),
                                      Color(0xFF0F5A7A)
                                    ])
                                  : LinearGradient(colors: [
                                      FishTheme.oceanCard.withValues(alpha: 0.9),
                                      const Color(0xFF052436)
                                    ]),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isMe
                                      ? FishTheme.cyanAccent
                                      : FishTheme.cyanAccent.withValues(alpha: 0.2),
                                  width: isMe ? 1.8 : 1.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ]),
                          child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: _badge(index + 1),
                              title: Row(children: [
                                Expanded(
                                    child: Text(u.displayName,
                                        style: TextStyle(
                                            color: isMe
                                                ? FishTheme.cyanAccent
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                        overflow: TextOverflow.ellipsis)),
                                if (isMe)
                                  Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: FishTheme.cyanAccent
                                              .withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Text('YOU',
                                          style: TextStyle(
                                              color: FishTheme.cyanAccent,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)))
                              ]),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          color: FishTheme.cyanAccent, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${u.exp} EXP',
                                        style: const TextStyle(
                                          color: FishTheme.cyanAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${u.totalCoins} Coins',
                                    style: const TextStyle(
                                      color: FishTheme.textSubtle,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              )),
                        );
                      },
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
}
