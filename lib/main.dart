import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/splash_screen.dart';
import 'services/app_role_service.dart';
import 'theme/app_theme.dart';
import 'widgets/ui_kit.dart';

Future<void> main() async {
  await runZonedGuarded(_init, (error, stack) {
    // Silence google_fonts network errors — fonts fall back to bundled assets.
    if (error.toString().contains('fonts.gstatic.com') ||
        error.toString().contains('Failed to load font')) {
      return;
    }
    debugPrint('Uncaught error: $error\n$stack');
  });
}

Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
  final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

  if (url.isEmpty || anonKey.isEmpty) {
    throw StateError(
      'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env — copy .env.example to .env and fill values.',
    );
  }

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  await AppRoleService.load();

  runApp(const ClinicApp());
}

class ClinicApp extends StatelessWidget {
  const ClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prodontics',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // The gradient canvas is painted once, here, behind every route — screens
      // just leave their Scaffold transparent. Individual screens must not wrap
      // themselves in AppGradientBackground or the glow blob stacks twice.
      builder: (context, child) =>
          AppGradientBackground(child: child ?? const SizedBox.shrink()),
      home: const SplashScreen(),
    );
  }
}
