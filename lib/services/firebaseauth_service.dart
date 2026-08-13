import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirebaseAuthServices {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signIn(
      {required String email, required String password}) async {
    try {
      return (await _auth.signInWithEmailAndPassword(
              email: email.trim(), password: password))
          .user;
    } on FirebaseAuthException catch (e) {
      _toast(_err(e.code, e.message));
    } catch (_) {
      _toast('An unexpected error occurred.');
    }
    return null;
  }

  Future<User?> signUp(
      {required String email,
      required String password,
      String? username}) async {
    try {
      final uCred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      if (uCred.user != null) {
        final name = username?.trim();
        if (name != null && name.isNotEmpty) {
          await uCred.user!.updateDisplayName(name);
        }
        await saveUserProfileToFirestore(
            uid: uCred.user!.uid,
            email: email.trim(),
            displayName: name,
            initialCoins: 50);
      }
      return uCred.user;
    } on FirebaseAuthException catch (e) {
      _toast(_err(e.code, e.message));
    } catch (_) {
      _toast('An unexpected error occurred.');
    }
    return null;
  }

  Future<bool> updateUserProfile(
      {String? displayName,
      String? email,
      String? password,
      File? imageFile}) async {
    final user = currentUser;
    if (user == null) {
      _toast('No authenticated user found.');
      return false;
    }
    try {
      String? photoBase64;
      if (imageFile != null) {
        photoBase64 = base64Encode(await imageFile.readAsBytes());
      }
      if (displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
      }
      if (email != null &&
          email.trim().isNotEmpty &&
          email.trim() != user.email) {
        await user.verifyBeforeUpdateEmail(email.trim());
      }
      if (password != null && password.isNotEmpty) {
        await user.updatePassword(password);
      }

      await saveUserProfileToFirestore(
        uid: user.uid,
        email: email?.trim() ?? user.email ?? '',
        displayName: displayName?.trim() ?? user.displayName ?? '',
        photoBase64: photoBase64,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _toast(_err(e.code, e.message));
    } catch (e) {
      _toast('Failed to update profile: $e');
    }
    return false;
  }

  Future<void> saveUserProfileToFirestore(
      {required String uid,
      required String email,
      String? displayName,
      String? photoBase64,
      int? initialCoins}) async {
    try {
      final data = <String, dynamic>{
        'uid': uid,
        'email': email,
        'updatedAt': FieldValue.serverTimestamp()
      };
      if (displayName != null && displayName.isNotEmpty) {
        data['displayName'] = displayName;
      }
      if (photoBase64 != null && photoBase64.isNotEmpty) {
        data['photoBase64'] = photoBase64;
      }

      final doc = await _firestore.collection('users').doc(uid).get();
      int coins = initialCoins ?? 50;
      List<String> owned = [];

      if (doc.exists && doc.data() != null) {
        final d = doc.data()!;
        if (d['coins'] != null) coins = (d['coins'] as num).toInt();
        if (d['ownedFishes'] != null) {
          owned = List<String>.from(d['ownedFishes']);
        }
      } else {
        data['coins'] = coins;
      }
      data['totalCoins'] =
          calculateTotalCoins(availableCoins: coins, ownedFishes: owned);
      await _firestore
          .collection('users')
          .doc(uid)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save error: $e');
    }
  }

  Future<int> getUserCoins(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data()?['coins'] != null) {
        return (doc.data()!['coins'] as num).toInt();
      }
    } catch (_) {}
    return 50;
  }

  Future<bool> deductCoins(String uid, int amount) async {
    try {
      final current = await getUserCoins(uid);
      if (current < amount) {
        _toast('Insufficient coins! Need $amount coins.');
        return false;
      }
      final owned = await getOwnedFishes(uid);
      final newCoins = current - amount;
      await _firestore.collection('users').doc(uid).set({
        'coins': newCoins,
        'totalCoins':
            calculateTotalCoins(availableCoins: newCoins, ownedFishes: owned)
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      _toast('Failed to deduct coins.');
      return false;
    }
  }

  Future<void> addCoins(String uid, int amount) async {
    try {
      final current = await getUserCoins(uid);
      final owned = await getOwnedFishes(uid);
      final newCoins = current + amount;
      await _firestore.collection('users').doc(uid).set({
        'coins': newCoins,
        'totalCoins':
            calculateTotalCoins(availableCoins: newCoins, ownedFishes: owned)
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error adding coins: $e');
    }
  }

  Future<int> getUserExp(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data()?['exp'] != null) {
        return (doc.data()!['exp'] as num).toInt();
      }
    } catch (_) {}
    return 0;
  }

  Future<void> addExp(String uid, int amount) async {
    try {
      final currentExp = await getUserExp(uid);
      await _firestore.collection('users').doc(uid).set({
        'exp': currentExp + amount,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error adding exp: $e');
    }
  }

  static const fishPrices = {
    'Bubble Fish': 15,
    'Ocean Swimmer': 20,
    'Puffer Pal': 25,
    'Baby Shark': 30,
    'Cute Octopus': 35,
    'Mini Squid': 40,
    'Little Crab': 45,
    'Jelly Friend': 50,
    'Starry Guppy': 60,
    'Golden Angelfish': 70,
    'Neon Tetra': 80,
    'Rainbow Crown Fish': 100,
  };

  int calculateBoughtFishCoins(List<String> owned) =>
      owned.fold(0, (acc, f) => acc + (fishPrices[f] ?? 0));
  int calculateTotalCoins(
          {required int availableCoins, required List<String> ownedFishes}) =>
      calculateBoughtFishCoins(ownedFishes) + availableCoins;

  Future<int> getTotalUserCoins(String uid) async => calculateTotalCoins(
      availableCoins: await getUserCoins(uid),
      ownedFishes: await getOwnedFishes(uid));

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllUsers() =>
      _firestore.collection('users').snapshots();

  Future<List<String>> getOwnedFishes(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data()?['ownedFishes'] != null) {
        return List<String>.from(doc.data()!['ownedFishes']);
      }
    } catch (_) {}
    return [];
  }

  Future<bool> buyFish(
      {required String uid,
      required String fishName,
      required int price}) async {
    try {
      final current = await getUserCoins(uid);
      if (current < price) {
        _toast('Insufficient coins! Need $price coins.');
        return false;
      }
      final owned = await getOwnedFishes(uid);
      if (owned.contains(fishName)) {
        _toast('You already own $fishName!');
        return false;
      }
      final newCoins = current - price;
      owned.add(fishName);
      await _firestore.collection('users').doc(uid).set({
        'coins': newCoins,
        'ownedFishes': owned,
        'totalCoins':
            calculateTotalCoins(availableCoins: newCoins, ownedFishes: owned)
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      _toast('Error purchasing fish.');
      return false;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserFirestoreProfile(
      String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (_) {
      return null;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserProfile(
          String uid) =>
      _firestore.collection('users').doc(uid).snapshots();

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      _toast('Error signing out.');
    }
  }

  void _toast(String msg) => Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      fontSize: 14.0);

  static const _errorMap = {
    'user-not-found': 'No user account found with this email.',
    'wrong-password': 'Incorrect password. Please try again.',
    'invalid-credential': 'Invalid email or password.',
    'email-already-in-use':
        'An account already exists with this email address.',
    'invalid-email': 'Please enter a valid email address.',
    'weak-password': 'Password is too weak. Please use at least 6 characters.',
    'requires-recent-login':
        'Please log out and log back in to change your email or password.',
    'user-disabled': 'This account has been disabled.',
    'too-many-requests': 'Too many attempts. Please try again later.',
  };

  String _err(String code, String? def) =>
      _errorMap[code] ?? (def ?? 'Authentication error occurred.');
}
