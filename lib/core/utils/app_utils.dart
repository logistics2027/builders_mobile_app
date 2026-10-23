
import 'package:avg_mart/main.dart';
import 'package:flutter/material.dart';

void showToast(String message) {
  final overlayState = navigatorKey.currentState?.overlay;
  if (overlayState == null) return;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayContext) => Positioned(
      bottom: MediaQuery.of(overlayContext).padding.bottom + 80,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      ),
    ),
  );

  overlayState.insert(entry);

  Future.delayed(const Duration(seconds: 2), () {
    entry.remove();
  });
}
