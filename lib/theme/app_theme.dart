// import 'package:flutter/material.dart';

// class AppTheme {
//   // Brand colors
//   static const Color primary = Color(0xFF0284C7);       // Sky 600 - Clean, professional Light Blue
//   static const Color secondary = Color(0xFF0369A1);     // Sky 700 - Elegant corporate blue
//   static const Color accent = Color(0xFFF97316);        // Coral Orange - Action buttons
//   static const Color starGold = Color(0xFFF59E0B);      // Amber Gold (Ratings)
  
//   // Backgrounds and Tints
//   static const Color background = Color(0xFFF0F9FF);    // Sky 50 - Soft light blue background
//   static const Color tint = Color(0xFFE0F2FE);          // Sky 100 - Gentle light blue tint
//   static const Color linkBlue = Color(0xFF0284C7);      // Sky 600

//   // Custom Gradients
//   static const List<Color> headerGradient = [
//     Color(0xFF0284C7),
//     Color(0xFF0369A1),
//   ];

//   static const List<Color> locationGradient = [
//     Color(0xFFE0F2FE),
//     Color(0xFFE0F2FE),
//   ];

//   static const List<Color> greetingGradient = [
//     Color(0xFFE0F2FE),
//     Colors.white,
//   ];
// }


import 'package:flutter/material.dart';

class AppTheme {
  // ===== Brand Colors =====
  static const Color primary = Color(0xFF1E3A8A);       // Indigo 900 - Deep trustworthy navy
  static const Color primaryLight = Color(0xFF3B82F6);  // Blue 500 - Lighter brand accent
  static const Color secondary = Color.fromARGB(255, 130, 153, 231);     // Indigo 800 - Supporting blue

  // ===== Action / CTA Colors =====
  static const Color accent = Color(0xFFF97316);        // Orange 500 - Add to cart, buy now
  static const Color accentDark = Color(0xFFEA580C);     // Orange 600 - Pressed state

  // ===== Ratings & Highlights =====
  static const Color starGold = Color(0xFFFBBF24);       // Amber 400 - Star ratings
  static const Color badgeRed = Color(0xFFDC2626);       // Red 600 - Sale/discount badges

  // ===== Semantic Colors =====
  static const Color success = Color(0xFF16A34A);        // Green 600 - In stock, order confirmed
  static const Color warning = Color(0xFFF59E0B);        // Amber 500 - Low stock
  static const Color error = Color(0xFFDC2626);          // Red 600 - Out of stock, errors
  static const Color info = Color(0xFF0284C7);           // Sky 600 - Informational banners

  // ===== Backgrounds & Surfaces =====
  static const Color background = Color(0xFFF8FAFC);     // Slate 50 - App background
  static const Color surface = Color(0xFFFFFFFF);        // White - Cards, product tiles
  static const Color tint = Color(0xFFEFF6FF);           // Blue 50 - Subtle section tint
  static const Color divider = Color(0xFFE2E8F0);        // Slate 200 - Borders/dividers

  // ===== Text Colors =====
  static const Color textPrimary = Color(0xFF0F172A);    // Slate 900 - Headings, titles
  static const Color textSecondary = Color(0xFF64748B);  // Slate 500 - Descriptions
  static const Color textMuted = Color(0xFF94A3B8);      // Slate 400 - Placeholder, meta info
  static const Color linkBlue = Color(0xFF2563EB);       // Blue 600 - Links

  // ===== Price Colors =====
  static const Color priceOriginal = Color(0xFF94A3B8);  // Slate 400 - Strikethrough price
  static const Color priceDiscounted = Color(0xFF16A34A); // Green 600 - Discounted price

  // ===== Gradients =====
  static const List<Color> headerGradient = [
    Color(0xFF1E3A8A),
    Color(0xFF1E40AF),
  ];

  static const List<Color> ctaGradient = [
    Color(0xFFF97316),
    Color(0xFFEA580C),
  ];

  static const List<Color> locationGradient = [
    Color(0xFFEFF6FF),
    Color(0xFFEFF6FF),
  ];

  static const List<Color> greetingGradient = [
    Color(0xFFEFF6FF),
    Colors.white,
  ];
}