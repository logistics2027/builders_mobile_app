import 'package:avg_mart/widgets/avg_mart_app_bar.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AvgMartAppBar(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: January 2026',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),

            const _PolicySection(
              title: '1. Information We Collect',
              body:
                  'We collect information you provide directly to us, such as '
                  'your name, email address, phone number, delivery address, '
                  'and payment details when you create an account or place an '
                  'order on AVG Mart. We also automatically collect certain '
                  'information about your device and how you use our app.',
            ),
            const _PolicySection(
              title: '2. How We Use Your Information',
              body:
                  'We use the information we collect to process your orders, '
                  'communicate with you about your purchases, personalize your '
                  'shopping experience, improve our services, and send you '
                  'promotional offers if you have opted in.',
            ),
            const _PolicySection(
              title: '3. Sharing of Information',
              body:
                  'We do not sell your personal information. We may share your '
                  'information with delivery partners, payment processors, and '
                  'service providers who help us operate the app, only to the '
                  'extent necessary to provide our services.',
            ),
            const _PolicySection(
              title: '4. Data Security',
              body:
                  'We implement reasonable technical and organizational measures '
                  'to protect your personal information from unauthorized access, '
                  'loss, or misuse. However, no method of transmission over the '
                  'internet is completely secure.',
            ),
            const _PolicySection(
              title: '5. Your Choices',
              body:
                  'You can update your account information, opt out of '
                  'promotional communications, or request deletion of your '
                  'account at any time from the app settings or by contacting '
                  'our support team.',
            ),
            const _PolicySection(
              title: '6. Children\'s Privacy',
              body:
                  'AVG Mart is not intended for use by children under the age '
                  'of 13. We do not knowingly collect personal information from '
                  'children.',
            ),
            const _PolicySection(
              title: '7. Changes to This Policy',
              body:
                  'We may update this Privacy Policy from time to time. We will '
                  'notify you of any material changes by posting the new policy '
                  'in the app.',
            ),
            const _PolicySection(
              title: '8. Contact Us',
              body:
                  'If you have any questions about this Privacy Policy, please '
                  'contact us at support@avgmart.com.',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}