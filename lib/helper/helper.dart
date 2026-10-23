/// Converts a raw string like "men's footwear" to "Men's Footwear"


import 'package:avg_mart/models/product_response.dart';

/// Parses a price string safely, defaulting to 0.0 on null/invalid input.
double parsePrice(String? value) {
  if (value == null) return 0.0;
  return double.tryParse(value) ?? 0.0;
}

/// The price to actually show for a product: offer price when present and
/// valid, otherwise the original price.
double displayPrice(ProductResponse product) {
  final offer = parsePrice(product.offerPrice);
  return offer > 0 ? offer : parsePrice(product.originalPrice);
}

/// Whole-number discount percentage, or 0 when there's nothing to show
/// (missing prices, or offer >= original).
int discountPercentage(ProductResponse product) {
  final original = parsePrice(product.originalPrice);
  final offer = parsePrice(product.offerPrice);
  if (original <= 0 || offer <= 0 || offer >= original) return 0;
  return (((original - offer) / original) * 100).round();
}

/// First image URL for a product, or null when it has none.
String? firstProductImage(ProductResponse product) {
  return (product.images != null && product.images!.isNotEmpty) ? product.images!.first : null;
}
String toTitleCase(String? text) {
  if (text == null || text.trim().isEmpty) return '';
  return text
      .trim()
      .split(RegExp(r'\s+'))
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}
