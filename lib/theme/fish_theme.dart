import 'package:flutter/material.dart';

class FishTheme {
  static const primaryDark = Color(0xFF031926),
      oceanCard = Color(0xFF072639),
      cyanAccent = Color(0xFF00F5D4),
      cyanGlow = Color(0xFF80EED3),
      oceanBlue = Color(0xFF00B4D8),
      coralPink = Color(0xFFFF70A6),
      coralLight = Color(0xFFFF9EBC),
      textSubtle = Color(0xFFB0D5E5),
      textLabel = Color(0xFF90C2D9);

  static InputDecoration inputDecoration(
          {required String labelText,
          required IconData prefixIcon,
          String? hintText,
          Widget? suffixIcon}) =>
      InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: textLabel),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIcon: Icon(prefixIcon, color: cyanAccent),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF041926).withValues(alpha: 0.9),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: cyanAccent.withValues(alpha: 0.2))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: cyanAccent, width: 1.8)),
        errorStyle: const TextStyle(color: coralPink),
      );

  static Widget gradientButton(
      {required String text,
      required VoidCallback? onPressed,
      required bool isLoading,
      IconData? icon,
      List<Color>? colors}) {
    final gColors = colors ?? const [cyanAccent, oceanBlue];
    return Container(
      height: 54,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: gColors),
          boxShadow: [
            BoxShadow(
                color: gColors.first.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ]),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18))),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    strokeWidth: 2.8, color: primaryDark))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(text,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: primaryDark,
                        letterSpacing: 1.1)),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: primaryDark, size: 22)
                ]
              ]),
      ),
    );
  }
}
