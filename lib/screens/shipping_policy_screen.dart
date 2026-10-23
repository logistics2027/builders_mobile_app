import 'package:avg_mart/widgets/avg_mart_app_bar.dart';
import 'package:flutter/material.dart';

class ShippingPolicyScreen extends StatelessWidget {
  const ShippingPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AvgMartAppBar(title: 'Shipping Policy'),
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
              title: '1. Delivery Areas',
              body:
                  'AVG Mart currently delivers to select pin codes across '
                  'India. You can check delivery availability for your '
                  'location by entering your address or pin code at checkout.',
            ),
            const _PolicySection(
              title: '2. Delivery Timelines',
              body:
                  'Standard orders are typically delivered within 2-7 business '
                  'days, depending on your location and product availability. '
                  'Express delivery options may be available for select items '
                  'and locations.',
            ),
            const _PolicySection(
              title: '3. Shipping Charges',
              body:
                  'Shipping charges, if applicable, are calculated at checkout '
                  'based on order value, weight, and delivery location. Orders '
                  'above a certain value may qualify for free shipping.',
            ),
            const _PolicySection(
              title: '4. Order Tracking',
              body:
                  'Once your order is shipped, you will receive a tracking '
                  'link via the app and email/SMS so you can monitor its '
                  'progress in real time.',
            ),
            const _PolicySection(
              title: '5. Delivery Attempts',
              body:
                  'Our delivery partners will attempt delivery to the address '
                  'provided. If delivery is unsuccessful after multiple '
                  'attempts, the order may be returned to the seller.',
            ),
            const _PolicySection(
              title: '6. Delays',
              body:
                  'While we strive to meet estimated delivery timelines, '
                  'delays may occur due to weather, logistics disruptions, or '
                  'other circumstances beyond our control. We appreciate your '
                  'patience in such cases.',
            ),
            const _PolicySection(
              title: '7. Damaged or Missing Items',
              body:
                  'If your order arrives damaged or with missing items, please '
                  'report it through the app within 48 hours of delivery so we '
                  'can assist you promptly.',
            ),
            const _PolicySection(
              title: '8. Contact Us',
              body:
                  'For any shipping-related questions, please contact us at '
                  'support@avgmart.com.',
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