import 'package:ecommerence_project/screens/onboarding/splash_screen.dart';
import 'package:ecommerence_project/providers/shop_provider.dart';
import 'package:ecommerence_project/providers/theme_provider.dart';
import 'package:ecommerence_project/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.instance.initialize();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFFFAF9F7),
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;
    return MaterialApp(
      title: 'Fashion Dome',
      debugShowCheckedModeBanner: false,
      theme: _appTheme(Brightness.light),
      darkTheme: _appTheme(Brightness.dark),
      themeMode: themeMode,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: theme.scaffoldBackgroundColor,
            systemNavigationBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
          ),
          child: child!,
        );
      },
      home: const Splashscreen(),
    );
  }
}

ThemeData _appTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final ink = isDark ? const Color(0xFFF5F1EB) : const Color(0xFF1C1C1C);
  final canvas = isDark ? const Color(0xFF10100F) : const Color(0xFFFAF9F7);
  final surface = isDark ? const Color(0xFF1B1A18) : Colors.white;
  final muted = isDark ? const Color(0xFFAAA39B) : const Color(0xFF6E6A66);
  final line = isDark ? const Color(0xFF37332F) : const Color(0xFFE7E2DC);
  final accent = isDark ? const Color(0xFFD1AE86) : const Color(0xFF9A7651);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: ink,
    brightness: brightness,
    primary: ink,
    onPrimary: isDark ? const Color(0xFF1C1C1C) : Colors.white,
    surface: surface,
    onSurface: ink,
    secondary: accent,
    onSecondary: isDark ? const Color(0xFF1C1C1C) : Colors.white,
    outline: line,
  );
  final textTheme =
      (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
            fontFamily: 'GeneralSans',
            bodyColor: ink,
            displayColor: ink,
          );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'GeneralSans',
    scaffoldBackgroundColor: canvas,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'GeneralSans',
        color: ink,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: muted),
      labelStyle: TextStyle(color: muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ink, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ink,
        foregroundColor: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: ink),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: line),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: ink,
      unselectedItemColor: muted,
      selectedLabelStyle: const TextStyle(
        fontFamily: 'GeneralSans',
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontFamily: 'GeneralSans'),
    ),
    dividerTheme: DividerThemeData(color: line, space: 1),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      contentTextStyle: TextStyle(
        fontFamily: 'GeneralSans',
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
