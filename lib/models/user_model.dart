import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid, displayName, email;
  final String? photoBase64;
  final int coins, boughtFishCoins, totalCoins, exp;
  final List<String> ownedFishes;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoBase64,
    required this.coins,
    required this.ownedFishes,
    required this.boughtFishCoins,
    required this.totalCoins,
    this.exp = 0,
  });

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    int Function(List<String>) calcBoughtCoins,
  ) {
    final data = doc.data() ?? {};
    final email = data['email'] ?? '';
    final owned = data['ownedFishes'] != null
        ? List<String>.from(data['ownedFishes'])
        : <String>[];
    final coins = (data['coins'] as num?)?.toInt() ?? 50;
    final exp = (data['exp'] as num?)?.toInt() ?? 0;
    final boughtCoins = calcBoughtCoins(owned);

    return UserProfile(
      uid: doc.id,
      displayName:
          data['displayName'] ??
          (email.isNotEmpty ? email.split('@')[0] : 'Explorer'),
      email: email,
      photoBase64: data['photoBase64'],
      coins: coins,
      ownedFishes: owned,
      boughtFishCoins: boughtCoins,
      totalCoins:
          (data['totalCoins'] as num?)?.toInt() ?? (boughtCoins + coins),
      exp: exp,
    );
  }

  Map<String, dynamic> toFirestoreMap() => {
    'uid': uid,
    'displayName': displayName,
    'email': email,
    if (photoBase64 != null) 'photoBase64': photoBase64,
    'coins': coins,
    'ownedFishes': ownedFishes,
    'totalCoins': totalCoins,
    'exp': exp,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
