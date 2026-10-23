import 'package:avg_mart/theme/app_color.dart';
import 'package:avg_mart/widgets/avg_mart_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _openLink(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Could not open $url')));
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AvgMartAppBar(title: 'About'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionLabel('ABOUT'),
          const SizedBox(height: 8),
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'AVG Mart is your one-stop online shopping destination. '
                'From daily essentials to the latest trends, we bring a '
                'wide range of quality products to your doorstep with a '
                'fast, secure, and hassle-free shopping experience.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.6,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          _sectionLabel('WHY SHOP WITH US'),
          const SizedBox(height: 8),
          _buildCard(
            child: Column(
              children: const [
                _ListItem('Wide range of products across categories'),
                _ListItem('Fast and reliable doorstep delivery'),
                _ListItem('Secure payments with multiple options'),
                _ListItem('Easy returns and refunds'),
                _ListItem('Exclusive deals and offers'),
                _ListItem('Dedicated customer support', isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionLabel("WHAT'S NEW"),
          const SizedBox(height: 8),
          _buildCard(
            child: Column(
              children: const [
                _ListItem('Faster checkout experience'),
                _ListItem('New payment options added'),
                _ListItem('Improved order tracking', isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionLabel('COMPANY'),
          const SizedBox(height: 8),
          _buildCard(
            child: Column(
              children: const [
                _ListItem(
                  'AVG Mart is owned and operated by Agila Vetri Prime Tech.',
                ),
                _ListItem('Serving customers since 2026', isLast: true),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionLabel('CONTACT US'),
          const SizedBox(height: 8),
          _buildCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.email_outlined,
                  title: 'support@avgmart.com',
                  tappable: true,
                  onTap: () => _openLink(context, 'mailto:support@avgmart.com'),
                ),
                const _InfoRow(
                  icon: Icons.call_outlined,
                  title: '+91 9187112123',
                  tappable: false,
                ),
                _InfoRow(
                  icon: Icons.language_outlined,
                  title: 'www.avgmart.com',
                  tappable: true,
                  onTap: () => _openLink(context, 'https://www.avgmart.com'),
                ),
                const _InfoRow(
                  icon: Icons.location_on_outlined,
                  title: 'Bengaluru, India',
                  tappable: false,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Center(
            child: Text(
              '© 2026 Agila Vetri Prime Tech. All rights reserved.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Shared building blocks
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

Widget _buildCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    child: child,
  );
}

// Plain check-mark row for the informational lists.
class _ListItem extends StatelessWidget {
  final String text;
  final bool isLast;
  const _ListItem(this.text, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF1F3F5)),
      ],
    );
  }
}

// Contact row: leading icon chip, title, chevron only when tappable.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool tappable;
  final bool isLast;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.tappable,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF001B44),
              ),
            ),
          ),
          if (tappable)
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.grey.shade400,
            ),
        ],
      ),
    );

    return Column(
      children: [
        tappable
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: row,
              )
            : row,
        if (!isLast) const Divider(height: 1, color: Color(0xFFF1F3F5)),
      ],
    );
  }
}
