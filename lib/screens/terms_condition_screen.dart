import 'package:avg_mart/widgets/avg_mart_app_bar.dart';
import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AvgMartAppBar(title: 'Terms & Conditions'),
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

            const _TermsSection(
              title: '1. Acceptance of Terms',
              body:
                  'By accessing or using the AVG Mart app, you agree to be '
                  'bound by these Terms & Conditions. If you do not agree, '
                  'please do not use the app.',
            ),
            const _TermsSection(
              title: '2. Account Registration',
              body:
                  'You must provide accurate and complete information when '
                  'creating an account. You are responsible for maintaining the '
                  'confidentiality of your login credentials and for all '
                  'activities under your account.',
            ),
            const _TermsSection(
              title: '3. Orders and Payments',
              body:
                  'All orders placed through AVG Mart are subject to '
                  'availability and confirmation. Prices are listed in the '
                  'applicable currency and may change without prior notice. '
                  'Payment must be completed through one of our supported '
                  'payment methods.',
            ),
            const _TermsSection(
              title: '4. Shipping and Delivery',
              body:
                  'Delivery timelines are estimates and may vary based on '
                  'location and product availability. AVG Mart is not liable '
                  'for delays caused by factors outside our reasonable control.',
            ),
            const _TermsSection(
              title: '5. Returns and Refunds',
              body:
                  'Returns and refunds are governed by our Return & Refund '
                  'Policy. Certain items may not be eligible for return due to '
                  'hygiene or other restrictions.',
            ),
            const _TermsSection(
              title: '6. Prohibited Use',
              body:
                  'You agree not to misuse the app, including attempting '
                  'unauthorized access, submitting fraudulent orders, or using '
                  'the app for any unlawful purpose.',
            ),
            const _TermsSection(
              title: '7. Limitation of Liability',
              body:
                  'AVG Mart shall not be liable for any indirect, incidental, '
                  'or consequential damages arising from your use of the app, '
                  'to the extent permitted by applicable law.',
            ),
            const _TermsSection(
              title: '8. Changes to Terms',
              body:
                  'We may revise these Terms & Conditions from time to time. '
                  'Continued use of the app after changes constitutes '
                  'acceptance of the updated terms.',
            ),
            const _TermsSection(
              title: '9. Contact Us',
              body:
                  'For any questions regarding these Terms & Conditions, '
                  'please contact us at support@avgmart.com.',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  final String title;
  final String body;
  const _TermsSection({required this.title, required this.body});

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