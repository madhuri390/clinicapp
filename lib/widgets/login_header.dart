import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Large bold heading with "smiles" highlighted by a hand-drawn style oval.
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  static const String _heading = 'Trusted hands for your timeless smiles.';
  static const String _highlightWord = 'smiles';

  @override
  Widget build(BuildContext context) {
    final span = _buildHighlightedHeading();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text.rich(
        span,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF37474F),
          height: 1.3,
        ),
      ),
    );
  }

  InlineSpan _buildHighlightedHeading() {
    final poppins = GoogleFonts.poppins(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF37474F),
    );
    final parts = _heading.split(_highlightWord);
    if (parts.length != 2) {
      return TextSpan(text: _heading, style: poppins);
    }
    return TextSpan(
      children: [
        TextSpan(text: parts[0], style: poppins),
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: _HighlightOval(
            child: Text(
              _highlightWord,
              style: poppins.copyWith(color: const Color(0xFF37474F)),
            ),
          ),
        ),
        TextSpan(text: parts[1], style: poppins),
      ],
    );
  }
}

class _HighlightOval extends StatelessWidget {
  const _HighlightOval({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: -4,
          right: -4,
          top: -2,
          bottom: -2,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.loginAccentLight,
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
