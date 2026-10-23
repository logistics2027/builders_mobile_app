import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
class HomeNetworkImage extends StatelessWidget {
  const HomeNetworkImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final int? targetW = width.isFinite ? (width * dpr).round() : null;
    final int? targetH = height.isFinite ? (height * dpr).round() : null;

    Widget image;
    if (url == null || url!.isEmpty) {
      image = _placeholder();
    } else {
      image = CachedNetworkImage(
        imageUrl: url!,
        width: width.isFinite ? width : null,
        height: height.isFinite ? height : null,
        fit: fit,
        memCacheWidth: (targetW != null && targetW > 0) ? targetW : null,
        memCacheHeight: (targetH != null && targetH > 0) ? targetH : null,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => Container(
          width: width.isFinite ? width : null,
          height: height.isFinite ? height : null,
          color: Colors.grey.shade100,
        ),
        errorWidget: (context, url, error) => _placeholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _placeholder() {
    return Container(
      width: width.isFinite ? width : null,
      height: height.isFinite ? height : null,
      color: Colors.grey.shade100,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}