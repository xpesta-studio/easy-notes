import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'database/hive_service.dart';
import 'services/note_service.dart';
import 'services/theme_service.dart';
import 'services/billing_service.dart';
import 'services/premium_service.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize offline Hive local database
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize Google Play Billing and Premium services
  final billingService = BillingService();
  final premiumService = PremiumService(
    hiveService: hiveService,
    billingService: billingService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => NoteService(hiveService: hiveService)),
        ChangeNotifierProvider.value(value: billingService),
        ChangeNotifierProvider.value(value: premiumService),
      ],
      child: const EasyNotesApp(),
    ),
  );
}

class EasyNotesApp extends StatelessWidget {
  const EasyNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Easy Notes',
          debugShowCheckedModeBanner: false,
          themeMode: themeService.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}