import 'package:avg_mart/widgets/avg_mart_app_bar.dart';
import 'package:flutter/material.dart';

class ReturnPolicyScreen extends StatelessWidget {
  const ReturnPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AvgMartAppBar(title: 'Return & Refund Policy'),
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
              title: '1. Return Window',
              body:
                  'Items can be requested for return or replacement within 7 days '
                  'of delivery if they arrive damaged, defective, or incorrect.',
            ),
            const _PolicySection(
              title: '2. Eligibility Criteria',
              body:
                  'To be eligible for a return, the product must be unused, in its '
                  'original condition, with tags intact and original packaging included.',
            ),
            const _PolicySection(
              title: '3. Non-Returnable Items',
              body:
                  'Certain items such as personal care, perishable goods, and '
                  'hygiene-sensitive products cannot be returned once delivered unless defective.',
            ),
            const _PolicySection(
              title: '4. Refund Process',
              body:
                  'Once the returned item is inspected and approved at our facility, '
                  'the refund is initiated to your original payment method within 5-7 business days.',
            ),
            const _PolicySection(
              title: '5. How to Initiate a Return',
              body:
                  'To request a return, go to your Orders section or email us at '
                  'support@avgmart.com with your order details and photos of the item.',
            ),
            const _PolicySection(
              title: '6. Customer Support',
              body:
                  'For any questions regarding returns and refunds, please reach out '
                  'to our support team at support@avgmart.com.',
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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
