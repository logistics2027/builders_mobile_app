import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable brand header widget featuring the official AVG logo,
/// title, and optional subtitle used across all authentication screens.
class AuthBrandHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double logoSize;
  final bool showBrandName;

  const AuthBrandHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.logoSize = 72,
    this.showBrandName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo container with subtle shadow and border
          Container(
            width: logoSize,
            height: logoSize,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(logoSize * 0.28),
              border: Border.all(
                color: AppTheme.divider,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Image.asset(
              'assets/AVG.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.shopping_bag_rounded,
                  color: AppTheme.primary,
                  size: 36,
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          if (showBrandName) ...[
            const Text(
              'AVG MART',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
                letterSpacing: 1.8,
              ),
            ),
            const SizedBox(height: 6),
          ],

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),

          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
