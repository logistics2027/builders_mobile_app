import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../service/location_service.dart';
import '../theme/app_theme.dart';

enum _GateStatus { checking, granted, serviceOff, denied, deniedForever }

/// Shows a non-dismissible bottom sheet asking the user to enable location.
/// The sheet closes automatically once location is on and permitted.
class LocationGate extends StatefulWidget {
  final Widget child;
  final VoidCallback? onGranted;

  const LocationGate({super.key, required this.child, this.onGranted});

  @override
  State<LocationGate> createState() => _LocationGateState();
}

class _LocationGateState extends State<LocationGate>
    with WidgetsBindingObserver {
  final ValueNotifier<_GateStatus> _status = ValueNotifier<_GateStatus>(
    _GateStatus.checking,
  );
  final ValueNotifier<bool> _busy = ValueNotifier<bool>(false);

  bool _sheetOpen = false;
  bool _autoRequested = false;
  BuildContext? _sheetContext;
  StreamSubscription<ServiceStatus>? _serviceSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _serviceSub = LocationService.serviceStatusStream.listen((_) {
      _evaluate();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluate(requestIfDenied: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _serviceSub?.cancel();
    _status.dispose();
    _busy.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // User may be coming back from the settings screen.
    if (state == AppLifecycleState.resumed) _evaluate();
  }

  Future<void> _evaluate({bool requestIfDenied = false}) async {
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      LocationPermission perm = await Geolocator.checkPermission();

      // Ask for permission right away on first launch, once.
      if (serviceOn &&
          perm == LocationPermission.denied &&
          requestIfDenied &&
          !_autoRequested) {
        _autoRequested = true;
        perm = await Geolocator.requestPermission();
      }

      final _GateStatus next;
      if (perm == LocationPermission.deniedForever) {
        next = _GateStatus.deniedForever;
      } else if (!serviceOn) {
        next = _GateStatus.serviceOff;
      } else if (perm == LocationPermission.denied ||
          perm == LocationPermission.unableToDetermine) {
        next = _GateStatus.denied;
      } else {
        next = _GateStatus.granted;
      }

      _applyStatus(next);
    } catch (_) {
      _applyStatus(_GateStatus.denied);
    }
  }

  void _applyStatus(_GateStatus next) {
    if (!mounted) return;
    final becameGranted =
        next == _GateStatus.granted && _status.value != _GateStatus.granted;

    _status.value = next;

    if (next == _GateStatus.granted) {
      _closeSheet();
      if (becameGranted) {
        LocationService.startTracking();
        LocationService.fetchCurrentLocation(force: true).catchError((_) {
          return LocationService.currentCachedLocation!;
        });
        widget.onGranted?.call();
      }
    } else if (next != _GateStatus.checking) {
      _openSheet();
    }
  }

  void _closeSheet() {
    final ctx = _sheetContext;
    if (_sheetOpen && ctx != null && ctx.mounted) {
      Navigator.of(ctx).pop();
    }
    _sheetOpen = false;
    _sheetContext = null;
  }

  Future<void> _openSheet() async {
    if (_sheetOpen || !mounted) return;
    _sheetOpen = true;

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        _sheetContext = sheetCtx;
        return PopScope(
          canPop: false, // blocks the back button too
          child: ValueListenableBuilder<_GateStatus>(
            valueListenable: _status,
            builder: (_, status, __) => ValueListenableBuilder<bool>(
              valueListenable: _busy,
              builder: (_, busy, __) => _LocationSheetContent(
                status: status,
                busy: busy,
                onPressed: _onButtonPressed,
              ),
            ),
          ),
        );
      },
    );

    // Sheet is gone; if location is still not granted, show it again.
    _sheetOpen = false;
    _sheetContext = null;
    if (mounted &&
        _status.value != _GateStatus.granted &&
        _status.value != _GateStatus.checking) {
      _openSheet();
    }
  }

  Future<void> _onButtonPressed() async {
    if (_busy.value) return;
    _busy.value = true;
    try {
      switch (_status.value) {
        case _GateStatus.serviceOff:
          await LocationService.openLocationSettings();
          break;
        case _GateStatus.deniedForever:
          await LocationService.openAppSettings();
          break;
        case _GateStatus.denied:
        case _GateStatus.checking:
        case _GateStatus.granted:
          await Geolocator.requestPermission();
          await _evaluate();
          break;
      }
    } finally {
      _busy.value = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _LocationSheetContent extends StatelessWidget {
  final _GateStatus status;
  final bool busy;
  final VoidCallback onPressed;

  const _LocationSheetContent({
    required this.status,
    required this.busy,
    required this.onPressed,
  });

  String get _title {
    switch (status) {
      case _GateStatus.serviceOff:
        return 'Turn on your location';
      case _GateStatus.deniedForever:
        return 'Allow location access';
      default:
        return 'Enable location';
    }
  }

  String get _message {
    switch (status) {
      case _GateStatus.serviceOff:
        return 'Location is switched off on your device. Turn it on to see '
            'what AVG Mart can deliver to you.';
      case _GateStatus.deniedForever:
        return 'Location permission is blocked. Open App Settings and allow '
            'location to continue.';
      default:
        return 'We need your location to show products and delivery '
            'availability in your area.';
    }
  }

  String get _buttonLabel {
    switch (status) {
      case _GateStatus.serviceOff:
        return 'Turn on location';
      case _GateStatus.deniedForever:
        return 'Open app settings';
      default:
        return 'Allow location access';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.tint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 38,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: busy ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _buttonLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
