import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebaseauth_service.dart';
import '../../theme/fish_theme.dart';
import '../../widgets/auth_layout.dart';
import '../Games/memory_game_screen.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(),
      _email = TextEditingController(),
      _password = TextEditingController(),
      _auth = FirebaseAuthServices();
  bool _isObscured = true, _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    User? user =
        await _auth.signIn(email: _email.text.trim(), password: _password.text);
    
    if (user == null && _email.text.trim().toLowerCase() == 'demo@sea.com') {
      user = await _auth.signUp(
          email: 'demo@sea.com',
          password: _password.text,
          username: 'Demo Explorer');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.set_meal_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    'Splash! Welcome back, ${user.email ?? "Fish Explorer"} 🐟',
                    style: const TextStyle(fontWeight: FontWeight.bold)))
          ]),
          backgroundColor: const Color(0xFF00A896),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MemoryGameScreen()));
    }
  }

  void _fillDemoAccount() {
    _email.text = 'demo@sea.com';
    _password.text = '123456';
    _handleLogin();
  }

  @override
  Widget build(BuildContext context) => AuthLayout(
        title: 'Temasek Fishes',
        subtitle: 'Dive into your aquatic fish kingdom! 🌊',
        imageAsset: 'assets/image.png',
        badgeText: 'AQUARIUM ADVENTURE GAME',
        badgeIcon: Icons.sports_esports_rounded,
        badgeColor: FishTheme.cyanGlow,
        bottomText: 'New fish in the tank? ',
        bottomLinkText: 'Join the School 🐠',
        onBottomLinkTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SignUpScreen())),
        formChild: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      ? 'Please enter your fish explorer email'
                      : (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(v.trim())
                          ? 'Please enter a valid email address'
                          : null)),
              const SizedBox(height: 18),
              TextFormField(
                  controller: _password,
                  obscureText: _isObscured,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: Colors.white),
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: FishTheme.inputDecoration(
                      labelText: 'Secret Reef Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                          icon: Icon(
                              _isObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: FishTheme.textLabel),
                          onPressed: () =>
                              setState(() => _isObscured = !_isObscured))),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter your password'
                      : null),
              const SizedBox(height: 26),
              FishTheme.gradientButton(
                  text: 'DIVE IN',
                  icon: Icons.phishing_rounded,
                  onPressed: _handleLogin,
                  isLoading: _isLoading),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _fillDemoAccount,
                icon: const Icon(Icons.flash_on_rounded,
                    color: Colors.amber, size: 18),
                label: const Text(
                  'Quick Demo Login (demo@sea.com)',
                  style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.amber, width: 1.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      );
}
