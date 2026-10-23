import 'dart:io' show Platform;
import 'package:avg_mart/core/constants/app_config.dart';
import 'package:avg_mart/screens/about_screen.dart';
import 'package:avg_mart/screens/privacy_policy_screen.dart';
import 'package:avg_mart/screens/return_policy_screen.dart';
import 'package:avg_mart/screens/shipping_policy_screen.dart';
import 'package:avg_mart/screens/terms_condition_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/profile/profile_cubit.dart';
import '../bloc/profile/profile_state.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/avg_header.dart';
import 'login_screen.dart';

// ---------------------------------------------------------------------
// Link / store / share helpers
// ---------------------------------------------------------------------

Future<void> _openLink(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not open $url')));
  }
}

Future<void> _rateApp(BuildContext context) async {
  if (!kIsWeb && Platform.isAndroid) {
    final marketUri = Uri.parse(
      'market://details?id=${AppConfig.androidPackageName}',
    );
    final canOpenStoreApp = await canLaunchUrl(marketUri);
    if (canOpenStoreApp) {
      await launchUrl(marketUri);
      return;
    }
    if (!context.mounted) return;
    await _openLink(
      context,
      'https://play.google.com/store/apps/details?id=${AppConfig.androidPackageName}',
    );
  } else if (!kIsWeb && Platform.isIOS) {
    if (AppConfig.iosAppId.isNotEmpty) {
      await _openLink(
        context,
        'https://apps.apple.com/app/id${AppConfig.iosAppId}?action=write-review',
      );
    } else {
      await _openLink(context, 'https://www.avgmart.com');
    }
  } else {
    await _openLink(
      context,
      'https://play.google.com/store/apps/details?id=${AppConfig.androidPackageName}',
    );
  }
}

// Uses SharePlus.instance.share() and always passes a non-zero
// sharePositionOrigin (required on iOS/iPadOS or the sheet may not appear).
Future<void> _shareApp(BuildContext context) async {
  final box = context.findRenderObject() as RenderBox?;
  final origin = (box != null)
      ? box.localToGlobal(Offset.zero) & box.size
      : const Rect.fromLTWH(0, 0, 1, 1);

  final isIOS = !kIsWeb && Platform.isIOS;
  final shareUrl = isIOS
      ? (AppConfig.iosAppId.isNotEmpty
            ? 'https://apps.apple.com/app/id${AppConfig.iosAppId}'
            : 'https://www.avgmart.com')
      : 'https://play.google.com/store/apps/details?id=${AppConfig.androidPackageName}&pcampaignid=web_share';

  await SharePlus.instance.share(
    ShareParams(
      text: 'Shop on Avg Mart: $shareUrl',
      sharePositionOrigin: origin,
    ),
  );
}

// ---------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appState = AppStateProvider.of(context);
      if (appState.isLoggedIn) {
        BlocProvider.of<ProfileCubit>(context).fetchProfile();
      }
    });
  }

  /// Pulls a display name out of the profile API's user map, trying the
  /// common key variants, and falls back to AppState's cached name.
  String _resolveDisplayName(Map<String, dynamic>? user, AppState appState) {
    if (user == null) return appState.userName;
    final name =
        user['name'] ??
        user['fullName'] ??
        user['username'] ??
        user['userName'];
    if (name is String && name.trim().isNotEmpty) {
      return name.trim();
    }
    return appState.userName;
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _confirmLogout(BuildContext context, AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Sign Out'),
          content: const Text(
            'Are you sure you want to sign out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      appState.logout();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully signed out.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Clear the nav stack so the user can't go back into authenticated screens.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    AppState appState,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to permanently delete your account?\n\n'
            'All your personal data, addresses, and order history will be removed. '
            'This action cannot be undone.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF4A5568),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            const Center(child: CircularProgressIndicator(color: Colors.red)),
      );

      try {
        await appState.deleteAccount();

        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your account and personal data have been permanently deleted.',
            ),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete account. Please try again or contact support at support@avgmart.com: $e',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    if (!appState.isLoggedIn) {
      return _buildLoggedOutView(context);
    }

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        final userMap = profileState is ProfileLoaded
            ? profileState.user
            : null;
        final displayName = _resolveDisplayName(userMap, appState);
        final isProfileLoading =
            profileState is ProfileLoading && userMap == null;

        return Scaffold(
          appBar: const AvgHeader(isReadOnly: true),
          backgroundColor: AppTheme.background,
          body: RefreshIndicator(
            onRefresh: () async {
              await BlocProvider.of<ProfileCubit>(context).fetchProfile();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUserGreetingBanner(displayName, isProfileLoading),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('GENERAL'),
                        const SizedBox(height: 8),
                        _buildCard(
                          children: [
                            _MenuRow(
                              icon: Icons.info_outline,
                              title: 'About Avg Mart',
                              onTap: (_) => _push(context, const AboutScreen()),
                            ),
                            _MenuRow(
                              icon: Icons.help_outline_rounded,
                              title: 'Help & Support',
                              isLast: true,
                              onTap: (ctx) =>
                                  _openLink(ctx, 'https://www.avgmart.com'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _sectionLabel('LEGAL'),
                        const SizedBox(height: 8),
                        _buildCard(
                          children: [
                            _MenuRow(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              onTap: (_) =>
                                  _push(context, const PrivacyPolicyScreen()),
                            ),
                            _MenuRow(
                              icon: Icons.description_outlined,
                              title: 'Terms & Conditions',
                              onTap: (_) =>
                                  _push(context, const TermsConditionsScreen()),
                            ),
                            _MenuRow(
                              icon: Icons.local_shipping_outlined,
                              title: 'Shipping Policy',
                              onTap: (_) =>
                                  _push(context, const ShippingPolicyScreen()),
                            ),
                            _MenuRow(
                              icon: Icons.assignment_return_outlined,
                              title: 'Return & Refund Policy',
                              isLast: true,
                              onTap: (_) =>
                                  _push(context, const ReturnPolicyScreen()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _sectionLabel('SPREAD THE WORD'),
                        const SizedBox(height: 8),
                        _buildCard(
                          children: [
                            _MenuRow(
                              icon: Icons.star_border_rounded,
                              title: 'Rate this App',
                              onTap: (ctx) => _rateApp(ctx),
                            ),
                            _MenuRow(
                              icon: Icons.share_outlined,
                              title: 'Share this App',
                              isLast: true,
                              onTap: (ctx) => _shareApp(ctx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _sectionLabel('ACCOUNT'),
                        const SizedBox(height: 8),
                        _buildCard(
                          children: [
                            _MenuRow(
                              icon: Icons.exit_to_app,
                              title: 'Sign Out',
                              onTap: (_) => _confirmLogout(context, appState),
                            ),
                            _MenuRow(
                              icon: Icons.delete_forever_outlined,
                              title: 'Delete Account',
                              iconColor: Colors.red,
                              titleColor: Colors.red,
                              isLast: true,
                              onTap: (_) =>
                                  _confirmDeleteAccount(context, appState),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: Text(
                            '© 2026 Agila Vetri Prime Tech. All rights reserved.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppTheme.headerGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            color: Colors.white,
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sign in to your account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Sign in to view your profile, manage your orders and addresses, and shop faster.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _push(context, const LoginScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign In Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserGreetingBanner(String displayName, bool isLoading) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.greetingGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Text(
            'Hello, ',
            style: TextStyle(fontSize: 20, color: Colors.black87),
          ),
          Expanded(
            child: isLoading
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Shared building blocks (same style as About screen)
// ---------------------------------------------------------------------

Widget _sectionLabel(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: Color(0xFFA3ACB9),
    ),
  );
}

Widget _buildCard({required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFF1F3F5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLast;
  final Color? iconColor;
  final Color? titleColor;
  final ValueChanged<BuildContext> onTap;

  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLast = false,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.primary;

    // Builder gives onTap this row's own context (needed for the share
    // sheet's position origin on iOS/iPad).
    return Builder(
      builder: (rowContext) => Column(
        children: [
          InkWell(
            onTap: () => onTap(rowContext),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: titleColor ?? const Color(0xFF001B44),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
          if (!isLast) const Divider(height: 1, color: Color(0xFFF1F3F5)),
        ],
      ),
    );
  }
}
