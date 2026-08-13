import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebaseauth_service.dart';
import '../../theme/fish_theme.dart';
import '../../widgets/auth_layout.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>(),
      _username = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController(),
      _confirmPassword = TextEditingController(),
      _auth = FirebaseAuthServices();
  bool _isObscuredPass = true, _isObscuredConfirm = true, _isLoading = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    User? user = await _auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
        username: _username.text.trim());
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.bubble_chart_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    'Success! You joined the school of Temasek Fishes! 🐠',
                    style: TextStyle(fontWeight: FontWeight.bold)))
          ]),
          backgroundColor: const Color(0xFF00A896),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => AuthLayout(
        showBackButton: true,
        title: 'Create Account',
        subtitle: 'Join Temasek Fishes to start your fish adventure! 🌊',
        imageAsset: 'assets/image.png',
        badgeText: 'JOIN THE SCHOOL OF FISH',
        badgeIcon: Icons.waves_rounded,
        badgeColor: FishTheme.coralLight,
        bottomText: 'Already a swimmer? ',
        bottomLinkText: 'Splash back in 🐟',
        onBottomLinkTap: () => Navigator.pop(context),
        formChild: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                  controller: _username,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: FishTheme.inputDecoration(
                      labelText: 'Explorer Username',
                      hintText: 'Captain Nemo',
                      prefixIcon: Icons.person_outline_rounded),
                  validator: (v) => v == null || v.trim().length < 2
                      ? 'Username must be at least 2 characters'
                      : null),
              const SizedBox(height: 18),
              TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: FishTheme.inputDecoration(
                      labelText: 'Fish Explorer Email',
                      hintText: 'explorer@sea.com',
                      prefixIcon: Icons.water_drop_outlined),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter your email address'
                      : (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(v.trim())
                          ? 'Please enter a valid email address'
                          : null)),
              const SizedBox(height: 18),
              TextFormField(
                  controller: _password,
                  obscureText: _isObscuredPass,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: FishTheme.inputDecoration(
                      labelText: 'Secret Reef Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                          icon: Icon(
                              _isObscuredPass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: FishTheme.textLabel),
                          onPressed: () => setState(
                              () => _isObscuredPass = !_isObscuredPass))),
                  validator: (v) => v == null || v.length < 6
                      ? 'Password must be at least 6 characters long'
                      : null),
              const SizedBox(height: 18),
              TextFormField(
                  controller: _confirmPassword,
                  obscureText: _isObscuredConfirm,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: Colors.white),
                  onFieldSubmitted: (_) => _handleSignUp(),
                  decoration: FishTheme.inputDecoration(
                      labelText: 'Confirm Secret Password',
                      prefixIcon: Icons.lock_reset_rounded,
                      suffixIcon: IconButton(
                          icon: Icon(
                              _isObscuredConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: FishTheme.textLabel),
                          onPressed: () => setState(
                              () => _isObscuredConfirm = !_isObscuredConfirm))),
                  validator: (v) =>
                      v != _password.text ? 'Passwords do not match' : null),
              const SizedBox(height: 26),
              FishTheme.gradientButton(
                  text: 'START SWIMMING',
                  icon: Icons.pool_rounded,
                  colors: const [FishTheme.coralPink, FishTheme.coralLight],
                  onPressed: _handleSignUp,
                  isLoading: _isLoading),
            ],
          ),
        ),
      );
}
