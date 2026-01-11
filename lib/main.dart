import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sahaay/theme/app_theme.dart';
import 'package:sahaay/screens/splash_screen.dart';
import 'package:sahaay/providers/chat_provider.dart';
import 'package:sahaay/providers/stress_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for a clean look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const SahaayApp());
}

class SahaayApp extends StatelessWidget {
  const SahaayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StressProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'SAHAAY',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
