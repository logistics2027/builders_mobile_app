import 'package:avg_mart/route_observe.dart';
import 'package:avg_mart/screens/splash_page.dart';
import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return AppStateProvider(
      notifier: appState,
      child: MaterialApp(
        title: 'AVG Mart',
        navigatorKey: navigatorKey,
        navigatorObservers: [routeObserver],

        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppTheme.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.primary,
            primary: AppTheme.primary,
            secondary: AppTheme.accent,
            surface: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black87),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: Colors.black87,
            showSelectedLabels: true,
            showUnselectedLabels: true,
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}
