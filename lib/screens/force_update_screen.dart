import 'package:avg_mart/theme/app_color.dart';
import 'package:flutter/material.dart';

class ForceUpdateScreen extends StatelessWidget {
  final VoidCallback onUpdateNow;

  const ForceUpdateScreen({super.key, required this.onUpdateNow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false, // block back button — update is mandatory
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
          ),
          child: Stack(
            children: [
              // Decorative background circles
              Positioned(
                top: -60,
                right: -40,
                child: _decorCircle(160, AppColors.secondary.withOpacity(0.25)),
              ),
              Positioned(
                bottom: -80,
                left: -60,
                child: _decorCircle(220, Colors.white.withOpacity(0.08)),
              ),
              Positioned(
                top: size.height * 0.25,
                left: -30,
                child: _decorCircle(90, Colors.white.withOpacity(0.06)),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon badge
                          Container(
                            padding: const EdgeInsets.all(26),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 1.5,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.system_update_rounded,
                                size: 44,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Title
                          Text(
                            "Update Required",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Subtitle
                          Text(
                            "A new version of AVG MART is available.\n"
                            "Please update to continue using the app.",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Card with feature highlights
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                            child: Column(
                              children: const [
                                _FeatureRow(
                                  icon: Icons.bolt_rounded,
                                  text: "Faster performance & bug fixes",
                                ),
                                SizedBox(height: 12),
                                _FeatureRow(
                                  icon: Icons.shield_rounded,
                                  text: "Improved security & stability",
                                ),
                                SizedBox(height: 12),
                                _FeatureRow(
                                  icon: Icons.auto_awesome_rounded,
                                  text: "New features & experience",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Update button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: onUpdateNow,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                elevation: 6,
                                shadowColor: Colors.black.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.download_rounded, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Update Now",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          Text(
                            "This update is mandatory to continue",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _decorCircle(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
