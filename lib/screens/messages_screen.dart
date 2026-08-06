import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_tokens.dart';

/// Placeholder for Messages tab (reference: bottom-nav Messages)
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Messages',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTokens.ink,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppTokens.muted),
            const SizedBox(height: 16),
            Text(
              'Messages coming soon',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: AppTokens.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
