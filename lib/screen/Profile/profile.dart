import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/firebaseauth_service.dart';
import '../../theme/fish_theme.dart';
import '../../widgets/aquarium_background.dart';
import '../../widgets/navigation.dart';
import '../../widgets/coins_net_worth_card.dart';
import '../Auth/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>(),
      _auth = FirebaseAuthServices(),
      _picker = ImagePicker();
  late TextEditingController _nameController,
      _emailController,
      _passwordController;
  File? _selectedImageFile;
  String? _firestoreBase64Image;
  bool _isObscured = true, _isLoading = false, _isFetching = true;
  int _availableCoins = 0, _boughtFishCoins = 0, _totalCoins = 0, _userExp = 0;
  List<String> _ownedFishes = [];

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _passwordController = TextEditingController();
    _loadFirestoreData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadFirestoreData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final coins = await _auth.getUserCoins(user.uid),
          owned = await _auth.getOwnedFishes(user.uid),
          exp = await _auth.getUserExp(user.uid);
      final boughtCoins = _auth.calculateBoughtFishCoins(owned),
          total = _auth.calculateTotalCoins(
              availableCoins: coins, ownedFishes: owned);
      final doc = await _auth.getUserFirestoreProfile(user.uid);

      if (mounted) {
        setState(() {
          _availableCoins = coins;
          _ownedFishes = owned;
          _boughtFishCoins = boughtCoins;
          _totalCoins = total;
          _userExp = exp;
          if (doc != null && doc.exists && doc.data() != null) {
            final data = doc.data()!;
            if (data['displayName'] != null && _nameController.text.isEmpty) {
              _nameController.text = data['displayName'];
            }
            if (data['photoBase64'] != null) {
              _firestoreBase64Image = data['photoBase64'];
            }
          }
        });
      }
    }
    if (mounted) setState(() => _isFetching = false);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
          source: source, maxWidth: 800, maxHeight: 800, imageQuality: 85);
      if (pickedFile != null) {
        setState(() => _selectedImageFile = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
      }
    }
  }

  void _showImagePickerOptions() => showModalBottomSheet(
        context: context,
        backgroundColor: FishTheme.oceanCard,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (_) => SafeArea(
          child: Wrap(
            children: [
              const ListTile(
                  title: Text('Select Profile Picture',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18))),
              ListTile(
                  leading: const Icon(Icons.photo_library_rounded,
                      color: FishTheme.cyanAccent),
                  title: const Text('Choose from Gallery',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  }),
              ListTile(
                  leading: const Icon(Icons.camera_alt_rounded,
                      color: FishTheme.cyanAccent),
                  title: const Text('Take a Photo',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  }),
            ],
          ),
        ),
      );

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final success = await _auth.updateUserProfile(
        displayName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
        imageFile: _selectedImageFile);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
                child: Text(
                    'Profile & picture saved successfully to Firestore! 🐟',
                    style: TextStyle(fontWeight: FontWeight.bold)))
          ]),
          backgroundColor: const Color(0xFF00A896),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))));
      _loadFirestoreData();
    }
  }

  Future<void> _handleSignOut() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
  }

  Widget _buildAvatarImage() {
    if (_selectedImageFile != null) {
      return ClipOval(
          child: Image.file(_selectedImageFile!,
              width: 104, height: 104, fit: BoxFit.cover));
    }
    if (_firestoreBase64Image != null && _firestoreBase64Image!.isNotEmpty) {
      try {
        return ClipOval(
            child: Image.memory(base64Decode(_firestoreBase64Image!),
                width: 104, height: 104, fit: BoxFit.cover));
      } catch (_) {}
    }
    return const Center(child: Text('🐟', style: TextStyle(fontSize: 48)));
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      floatingActionButton: AppBottomNavBar.aboutFab(context),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: -1),
      body: AquariumBackground(
        isProfileActive: true,
        child: SafeArea(
          child: _isFetching
              ? const Center(
                  child: CircularProgressIndicator(color: FishTheme.cyanAccent))
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 110),
                        GestureDetector(
                          onTap: _showImagePickerOptions,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                  width: 116,
                                  height: 116,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(colors: [
                                        FishTheme.cyanAccent,
                                        FishTheme.oceanBlue,
                                        FishTheme.coralPink
                                      ]),
                                      boxShadow: [
                                        BoxShadow(
                                            color: FishTheme.cyanAccent
                                                .withValues(alpha: 0.4),
                                            blurRadius: 20,
                                            spreadRadius: 3)
                                      ])),
                              Container(
                                  width: 104,
                                  height: 104,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF042033)),
                                  child: _buildAvatarImage()),
                              Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: FishTheme.cyanAccent,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8)
                                          ]),
                                      child: const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 18,
                                          color: FishTheme.primaryDark))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(user?.email ?? 'Fish Explorer',
                            style: const TextStyle(
                                color: FishTheme.textSubtle, fontSize: 14)),
                        const SizedBox(height: 20),
                        CoinsNetWorthCard(
                            availableCoins: _availableCoins,
                            boughtFishCoins: _boughtFishCoins,
                            totalCoins: _totalCoins,
                            ownedFishCount: _ownedFishes.length,
                            userExp: _userExp),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                              color: FishTheme.oceanCard.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  color: FishTheme.cyanAccent.withValues(alpha: 0.3),
                                  width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 25,
                                    offset: const Offset(0, 12))
                              ]),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                    controller: _nameController,
                                    textInputAction: TextInputAction.next,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: FishTheme.inputDecoration(
                                        labelText: 'Explorer Name',
                                        hintText: 'Enter your name',
                                        prefixIcon:
                                            Icons.person_outline_rounded),
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Please enter your name'
                                            : null),
                                const SizedBox(height: 18),
                                TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: FishTheme.inputDecoration(
                                        labelText: 'Email Address',
                                        hintText: 'explorer@sea.com',
                                        prefixIcon: Icons.email_outlined),
                                    validator: (v) => v == null ||
                                            v.trim().isEmpty
                                        ? 'Please enter your email'
                                        : (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                .hasMatch(v.trim())
                                            ? 'Please enter a valid email address'
                                            : null)),
                                const SizedBox(height: 18),
                                TextFormField(
                                    controller: _passwordController,
                                    obscureText: _isObscured,
                                    textInputAction: TextInputAction.done,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: FishTheme.inputDecoration(
                                        labelText: 'New Password (Optional)',
                                        prefixIcon: Icons.lock_outline_rounded,
                                        suffixIcon: IconButton(
                                            icon: Icon(
                                                _isObscured
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
                                                color: FishTheme.textLabel),
                                            onPressed: () => setState(() =>
                                                _isObscured = !_isObscured))),
                                    validator: (v) => v != null &&
                                            v.isNotEmpty &&
                                            v.length < 6
                                        ? 'Password must be at least 6 characters'
                                        : null),
                                const SizedBox(height: 26),
                                FishTheme.gradientButton(
                                    text: 'SAVE PROFILE',
                                    icon: Icons.save_rounded,
                                    onPressed: _handleSaveProfile,
                                    isLoading: _isLoading),
                                const SizedBox(height: 14),
                                OutlinedButton.icon(
                                    onPressed: _handleSignOut,
                                    icon: const Icon(Icons.logout_rounded,
                                        color: FishTheme.coralPink, size: 18),
                                    label: const Text('SIGN OUT',
                                        style: TextStyle(
                                            color: FishTheme.coralPink,
                                            fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: FishTheme.coralPink,
                                            width: 1.2),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 24),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
