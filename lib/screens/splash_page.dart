// import 'package:avg_mart/core/constants/app_config.dart';
// import 'package:avg_mart/models/app_version_response.dart';
// import 'package:avg_mart/screens/login_screen.dart';
// import 'package:avg_mart/screens/main_navigation_screen.dart';
// import 'package:avg_mart/screens/force_update_screen.dart';
// import 'package:avg_mart/screens/soft_update_bottom_sheet.dart';
// import 'package:avg_mart/service/storege_service.dart';
// import 'package:avg_mart/service/api_service.dart';
// import 'package:avg_mart/service/version_check_service.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// class SplashPage extends StatefulWidget {
//   const SplashPage({super.key});

//   @override
//   State<SplashPage> createState() => _SplashPageState();
// }

// class _SplashPageState extends State<SplashPage>
//     with SingleTickerProviderStateMixin {
//   final StorageService _storageService = StorageService();

//   bool _splashTimerDone = false;
//   bool _versionCheckDone = false;
//   bool _shouldNavigate = true;

//   // Brand colors
//   static const Color primary = Color(0xFF1E3A8A); // Indigo 900
//   static const Color primaryLight = Color(0xFF3B82F6); // Blue 500
//   static const Color secondary = Color.fromARGB(255, 130, 153, 231);

//   late final AnimationController _fadeController;
//   late final Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeOut,
//     );
//     _fadeController.forward();

//     _startSplashTimer();
//     _versionCheck();
//   }

//   @override
//   void dispose() {
//     _fadeController.dispose();
//     super.dispose();
//   }

//   void _startSplashTimer() {
//     Future.delayed(const Duration(seconds: 2), () {
//       _splashTimerDone = true;
//       _tryProceed();
//     });
//   }

//   void _tryProceed() {
//     if (!_splashTimerDone) return;
//     if (!_versionCheckDone) return;
//     if (!_shouldNavigate) return;
//     if (!mounted) return;

//     _checkToken();
//   }

//   // ── Version check ──────────────────────────────────────────────
//   Future<void> _versionCheck() async {
//     try {
//       final AppVersionResponse response = await ApiService().getAppVersion();
//       final Data? data = response.data;

//       if (data != null) {
//         final bool forceUpdate = data.forceUpdate ?? false;
//         final current = await VersionCheckService.getCurrentAppVersion();

//         if (defaultTargetPlatform == TargetPlatform.android) {
//           final String latest = data.androidCurrent ?? '0.0.0';

//           if (VersionCheckService.isVersionLower(current, latest)) {
//             _shouldNavigate = false;

//             if (forceUpdate) {
//               _showForceUpdate(
//                 onUpdateNow: () => VersionCheckService.launchPlayStore(
//                   AppConfig.androidPackageName,
//                 ),
//               );
//             } else {
//               _showSoftUpdate(
//                 releaseNotes: data.releaseNotes,
//                 onUpdateNow: () => VersionCheckService.launchPlayStore(
//                   AppConfig.androidPackageName,
//                 ),
//               );
//             }
//             return;
//           }
//         }

//         if (defaultTargetPlatform == TargetPlatform.iOS) {
//           final String latest = data.iosCurrent ?? '0.0.0';

//           if (AppConfig.iosAppId.isNotEmpty &&
//               VersionCheckService.isVersionLower(current, latest)) {
//             _shouldNavigate = false;

//             if (forceUpdate) {
//               _showForceUpdate(
//                 onUpdateNow: () =>
//                     VersionCheckService.launchAppStore(AppConfig.iosAppId),
//               );
//             } else {
//               _showSoftUpdate(
//                 releaseNotes: data.releaseNotes,
//                 onUpdateNow: () =>
//                     VersionCheckService.launchAppStore(AppConfig.iosAppId),
//               );
//             }
//             return;
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint("Version check error: $e");
//     }

//     _versionCheckDone = true;
//     _tryProceed();
//   }

//   void _showSoftUpdate({
//     required VoidCallback onUpdateNow,
//     String? releaseNotes,
//   }) {
//     if (!mounted) return;

//     showModalBottomSheet(
//       context: context,
//       isDismissible: false,
//       enableDrag: false,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) => SoftUpdateBottomSheet(
//         releaseNotes: releaseNotes,
//         onUpdateNow: onUpdateNow,
//         onContinue: () {
//           Navigator.pop(context);
//           _versionCheckDone = true;
//           _shouldNavigate = true;
//           _tryProceed();
//         },
//       ),
//     );
//   }

//   void _showForceUpdate({required VoidCallback onUpdateNow}) {
//     if (!mounted) return;

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => ForceUpdateScreen(onUpdateNow: onUpdateNow),
//       ),
//     );
//   }

//   // ── Token / auto-login flow ─────────────────────────────────────
//   Future<void> _checkToken() async {
//     String? token;
//     try {
//       token = await _storageService.getToken('auth_token');
//     } catch (_) {
//       token = null;
//     }

//     if (!mounted) return;

//     if (token != null && token.isNotEmpty) {
//       _goToHome();
//     } else {
//       _goToLogin();
//     }
//   }

//   void _goToHome() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
//     );
//   }

//   void _goToLogin() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [primary, primaryLight],
//           ),
//         ),
//         child: SafeArea(
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: Column(
//               children: [
//                 Expanded(
//                   child: Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Logo badge
//                         Container(
//                           padding: const EdgeInsets.all(22),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.white.withOpacity(0.12),
//                             border: Border.all(
//                               color: Colors.white.withOpacity(0.25),
//                               width: 1.2,
//                             ),
//                           ),
//                           child: Container(
//                             padding: const EdgeInsets.all(18),
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.white,
//                             ),
//                             child: SizedBox(
//                               width: 56,
//                               height: 56,
//                               child: Image.asset(
//                                 "assets/AVG.png",
//                                 fit: BoxFit.contain,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 28),
//                         Text(
//                           "AVG MART",
//                           style: TextStyle(
//                             fontSize: 30,
//                             fontWeight: FontWeight.w900,
//                             letterSpacing: 3,
//                             color: Colors.white,
//                             shadows: [
//                               Shadow(
//                                 color: Colors.black.withOpacity(0.15),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           "Shop smart. Shop simple.",
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             letterSpacing: 0.5,
//                             color: Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Bottom loading section
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 48,
//                     vertical: 40,
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: LinearProgressIndicator(
//                           minHeight: 6,
//                           backgroundColor: Colors.white.withOpacity(0.2),
//                           valueColor: const AlwaysStoppedAnimation<Color>(
//                             secondary,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         "Loading your experience...",
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w400,
//                           letterSpacing: 0.3,
//                           color: Colors.white.withOpacity(0.75),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:math' as math;

import 'package:avg_mart/core/constants/app_config.dart';
import 'package:avg_mart/models/app_version_response.dart';
import 'package:avg_mart/screens/login_screen.dart';
import 'package:avg_mart/screens/main_navigation_screen.dart';
import 'package:avg_mart/screens/force_update_screen.dart';
import 'package:avg_mart/screens/soft_update_bottom_sheet.dart';
import 'package:avg_mart/service/storege_service.dart';
import 'package:avg_mart/service/api_service.dart';
import 'package:avg_mart/service/version_check_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  final StorageService _storageService = StorageService();

  bool _splashTimerDone = false;
  bool _versionCheckDone = false;
  bool _shouldNavigate = true;
  bool _proceeding = false;

  // Brand color for the loading dots
  static const Color primary = Color(0xFF1E3A8A);

  // Image sizing
  static const double _imageWidthFactor = 0.55; // 55% of screen width
  static const double _imageMaxWidth = 240;

  // Loader dots
  static const int _dotCount = 3;
  static const double _dotSize = 10;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final AnimationController _pulseController; // logo breathing
  late final Animation<double> _pulseAnimation;
  late final AnimationController _dotsController; // bouncing dots

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Logo gently scales up and down.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Dots loop forever until we navigate away.
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _startSplashTimer();
    _versionCheck();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  void _startSplashTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      _splashTimerDone = true;
      _tryProceed();
    });
  }

  void _tryProceed() {
    if (!_splashTimerDone) return;
    if (!_versionCheckDone) return;
    if (!_shouldNavigate) return;
    if (!mounted) return;
    if (_proceeding) return;
    _proceeding = true;

    _checkToken();
  }

  // ── Version check ──────────────────────────────────────────────
  Future<void> _versionCheck() async {
    try {
      final AppVersionResponse response = await ApiService().getAppVersion();
      final Data? data = response.data;

      if (data != null) {
        final bool forceUpdate = data.forceUpdate ?? false;
        final current = await VersionCheckService.getCurrentAppVersion();

        if (defaultTargetPlatform == TargetPlatform.android) {
          final String latest = data.androidCurrent ?? '0.0.0';

          if (VersionCheckService.isVersionLower(current, latest)) {
            _shouldNavigate = false;

            if (forceUpdate) {
              _showForceUpdate(
                onUpdateNow: () => VersionCheckService.launchPlayStore(
                  AppConfig.androidPackageName,
                ),
              );
            } else {
              _showSoftUpdate(
                releaseNotes: data.releaseNotes,
                onUpdateNow: () => VersionCheckService.launchPlayStore(
                  AppConfig.androidPackageName,
                ),
              );
            }
            return;
          }
        }

        if (defaultTargetPlatform == TargetPlatform.iOS) {
          final String latest = data.iosCurrent ?? '0.0.0';

          if (AppConfig.iosAppId.isNotEmpty &&
              VersionCheckService.isVersionLower(current, latest)) {
            _shouldNavigate = false;

            if (forceUpdate) {
              _showForceUpdate(
                onUpdateNow: () =>
                    VersionCheckService.launchAppStore(AppConfig.iosAppId),
              );
            } else {
              _showSoftUpdate(
                releaseNotes: data.releaseNotes,
                onUpdateNow: () =>
                    VersionCheckService.launchAppStore(AppConfig.iosAppId),
              );
            }
            return;
          }
        }
      }
    } catch (e) {
      debugPrint("Version check error: $e");
    }

    _versionCheckDone = true;
    _tryProceed();
  }

  void _showSoftUpdate({
    required VoidCallback onUpdateNow,
    String? releaseNotes,
  }) {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SoftUpdateBottomSheet(
        releaseNotes: releaseNotes,
        onUpdateNow: onUpdateNow,
        onContinue: () {
          Navigator.pop(context);
          _versionCheckDone = true;
          _shouldNavigate = true;
          _tryProceed();
        },
      ),
    );
  }

  void _showForceUpdate({required VoidCallback onUpdateNow}) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ForceUpdateScreen(onUpdateNow: onUpdateNow),
      ),
    );
  }

  // ── Token / auto-login flow ─────────────────────────────────────
  Future<void> _checkToken() async {
    String? token;
    try {
      token = await _storageService.getToken('auth_token');
    } catch (_) {
      token = null;
    }

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      _goToHome();
    } else {
      _goToLogin();
    }
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ── UI ──────────────────────────────────────────────────────────
  Widget _buildBouncingDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_dotCount, (i) {
            // Each dot is offset in time so they bounce as a wave.
            final t = (_dotsController.value - i * 0.15) % 1.0;
            final wave = math.sin(t * 2 * math.pi).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Transform.translate(
                offset: Offset(0, -12 * wave),
                child: Opacity(
                  opacity: 0.4 + 0.6 * wave,
                  child: Transform.scale(
                    scale: 0.85 + 0.35 * wave,
                    child: Container(
                      width: _dotSize,
                      height: _dotSize,
                      decoration: const BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = (screenWidth * _imageWidthFactor).clamp(
      0.0,
      _imageMaxWidth,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Pulsing logo
              Expanded(
                child: Center(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: SizedBox(
                      width: imageWidth,
                      child: Image.asset('assets/AVG.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),

              // Bouncing dots loader
              Padding(
                padding: const EdgeInsets.only(bottom: 56),
                child: SizedBox(
                  height: 32,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildBouncingDots(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
