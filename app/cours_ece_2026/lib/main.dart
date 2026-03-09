import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Tes imports d'origine
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:formation_flutter/screens/homepage/homepage_screen.dart';
import 'package:formation_flutter/screens/product/product_page.dart';

// Tes nouveaux fichiers
import 'package:formation_flutter/services/auth_service.dart';
import 'package:formation_flutter/screens/login/login_page.dart';
import 'package:formation_flutter/screens/scanner/scanner_page.dart'; // Import du scanner

// 1. Initialisation globale
final pb = PocketBase('http://macbook-air-de-martin.local:8090');
final authService = AuthService(pb);

void main() {
  runApp(
    ChangeNotifierProvider.value(
      value: authService,
      child: const MyApp(),
    ),
  );
}

// 2. Configuration du Router
final GoRouter _router = GoRouter(
  initialLocation: '/',
  refreshListenable: authService, 
  
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      redirect: (context, state) {
        final bool loggedIn = authService.isAuthenticated;
        final bool loggingIn = state.matchedLocation == '/login';
        if (!loggedIn) return '/login';
        if (loggingIn) return '/';
        return null;
      },
    ),
    // NOUVELLE ROUTE : SCANNER
    GoRoute(
      path: '/scanner',
      builder: (context, state) => ScannerPage(),
      redirect: (context, state) {
        if (!authService.isAuthenticated) return '/login';
        return null;
      },
    ),
    GoRoute(
      path: '/product',
      builder: (context, state) => ProductPage(barcode: state.extra as String),
      redirect: (context, state) {
        if (!authService.isAuthenticated) return '/login';
        return null;
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Open Food Facts',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        extensions: [OffThemeExtension.defaultValues()],
        fontFamily: 'Avenir',
        dividerTheme: const DividerThemeData(color: AppColors.grey2, space: 1.0),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: AppColors.blue,
          unselectedItemColor: AppColors.grey2,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          indicatorColor: AppColors.blue,
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}