// import 'dart:async';
// import 'package:dio/dio.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:avg_mart/service/storege_service.dart';

// enum LocationFailure {
//   serviceDisabled,
//   permissionDenied,
//   permissionDeniedForever,
//   unknown,
// }

// class LocationException implements Exception {
//   final LocationFailure failure;
//   final String message;

//   const LocationException(this.failure, this.message);

//   @override
//   String toString() => message;
// }

// class LocationResult {
//   final double latitude;
//   final double longitude;
//   final String subLocality;
//   final String street;
//   final String city;
//   final String state;
//   final String district;
//   final String postalCode;
//   final String country;

//   const LocationResult({
//     required this.latitude,
//     required this.longitude,
//     required this.street,
//     required this.city,
//     required this.state,
//     required this.district,
//     required this.postalCode,
//     required this.country,
//     this.subLocality = '',
//   });

//   /// Short, accurate label for the header (e.g. "Koramangala, Bengaluru 560034").
//   String get label {
//     final sub = subLocality.trim();
//     final c = city.trim();
//     final d = district.trim();
//     final s = street.trim();
//     final pin = postalCode.trim();

//     final parts = <String>[];
//     if (sub.isNotEmpty) {
//       parts.add(sub);
//     } else if (s.isNotEmpty) {
//       parts.add(s);
//     }

//     if (c.isNotEmpty && !parts.contains(c)) {
//       parts.add(c);
//     } else if (parts.isEmpty && d.isNotEmpty) {
//       parts.add(d);
//     }

//     final area = parts.isNotEmpty ? parts.join(', ') : '';
//     final pincodeStr = pin.isNotEmpty ? ' $pin' : '';

//     if (area.isNotEmpty) {
//       return '$area$pincodeStr'.trim();
//     }
//     if (c.isNotEmpty) {
//       return '$c$pincodeStr'.trim();
//     }
//     return 'Current Location';
//   }

//   Map<String, dynamic> toJson() => {
//     'latitude': latitude,
//     'longitude': longitude,
//     'subLocality': subLocality,
//     'street': street,
//     'city': city,
//     'state': state,
//     'district': district,
//     'postalCode': postalCode,
//     'country': country,
//   };

//   factory LocationResult.fromJson(Map<String, dynamic> json) => LocationResult(
//     latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
//     longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
//     subLocality: (json['subLocality'] ?? '') as String,
//     street: (json['street'] ?? '') as String,
//     city: (json['city'] ?? '') as String,
//     state: (json['state'] ?? '') as String,
//     district: (json['district'] ?? '') as String,
//     postalCode: (json['postalCode'] ?? '') as String,
//     country: (json['country'] ?? '') as String,
//   );
// }

// class LocationService {
//   static const String _cacheKey = 'cached_user_location_v2';
//   static final StorageService _storage = StorageService();
//   static final Dio _dio = Dio(
//     BaseOptions(
//       connectTimeout: const Duration(seconds: 6),
//       receiveTimeout: const Duration(seconds: 6),
//       headers: {
//         'User-Agent': 'AVGMart-App/1.2 (Android; Mobile; support@avgmart.com)',
//         'Accept': 'application/json',
//       },
//     ),
//   );

//   // In-memory cache for instant zero-latency UI rendering
//   static LocationResult? _cachedLocation;
//   static bool _hasLoadedFromDisk = false;
//   static Future<LocationResult>? _inFlightFetch;
//   static DateTime? _lastFetchTime;

//   static LocationResult? get currentCachedLocation => _cachedLocation;

//   /// Loads cached location from persistent storage if not already loaded into memory.
//   static Future<LocationResult?> loadFromStorage() async {
//     if (_cachedLocation != null) return _cachedLocation;
//     if (_hasLoadedFromDisk) return null;

//     try {
//       _hasLoadedFromDisk = true;
//       final data = await _storage.getResponse(_cacheKey);
//       if (data != null) {
//         _cachedLocation = LocationResult.fromJson(data);
//         return _cachedLocation;
//       }
//     } catch (_) {
//       // Storage read error ignored
//     }
//     return null;
//   }

//   /// Saves location to memory and persistent storage.
//   static Future<void> saveCachedLocation(LocationResult result) async {
//     _cachedLocation = result;
//     try {
//       await _storage.saveResponse(_cacheKey, result.toJson());
//     } catch (_) {
//       // Storage write error ignored
//     }
//   }

//   /// Emits whenever the user toggles the device location switch.
//   static Stream<ServiceStatus> get serviceStatusStream =>
//       Geolocator.getServiceStatusStream();

//   static Future<bool> isLocationServiceEnabled() =>
//       Geolocator.isLocationServiceEnabled();

//   static Future<bool> openLocationSettings() =>
//       Geolocator.openLocationSettings();

//   static Future<bool> openAppSettings() => Geolocator.openAppSettings();

//   /// Fetches current location with single-flight de-duplication and multi-source geocoding.
//   static Future<LocationResult> fetchCurrentLocation({bool force = false}) {
//     // If not forced and recent result is available, return immediately
//     if (!force &&
//         _cachedLocation != null &&
//         _lastFetchTime != null &&
//         DateTime.now().difference(_lastFetchTime!).inMinutes < 5) {
//       return Future.value(_cachedLocation);
//     }

//     // De-duplicate concurrent calls
//     if (_inFlightFetch != null && !force) {
//       return _inFlightFetch!;
//     }

//     final future = _performFetch();
//     _inFlightFetch = future;
//     return future.whenComplete(() {
//       _inFlightFetch = null;
//     });
//   }

//   static Future<LocationResult> _performFetch() async {
//     final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw const LocationException(
//         LocationFailure.serviceDisabled,
//         'Location services are disabled on your device.',
//       );
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw const LocationException(
//           LocationFailure.permissionDenied,
//           'Location permission was denied.',
//         );
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       throw const LocationException(
//         LocationFailure.permissionDeniedForever,
//         'Location permission is permanently denied in settings.',
//       );
//     }

//     // Try last known position first (instant)
//     Position? pos;
//     try {
//       pos = await Geolocator.getLastKnownPosition();
//     } catch (_) {}

//     // Fetch fresh position with high accuracy
//     try {
//       pos = await Geolocator.getCurrentPosition(
//         locationSettings: const LocationSettings(
//           accuracy: LocationAccuracy.high,
//           timeLimit: Duration(seconds: 9),
//         ),
//       );
//     } catch (_) {
//       // Ignored: fallback to last known or cache below
//     }

//     if (pos == null) {
//       if (_cachedLocation != null) return _cachedLocation!;
//       throw const LocationException(
//         LocationFailure.unknown,
//         'Location unavailable.',
//       );
//     }



//     final result = await _reverseGeocode(pos.latitude, pos.longitude);
//     _lastFetchTime = DateTime.now();
//     await saveCachedLocation(result);
//     return result;
//   }

//   /// Multi-source reverse geocoder (Platform Geocoder + OSM Nominatim + BigDataCloud).
//   /// The first provider with non-empty locality/city wins.
//   static Future<LocationResult> _reverseGeocode(double lat, double lon) async {
//     final futures = <Future<LocationResult?>>[
//       _platformGeocoder(lat, lon),
//       _nominatim(lat, lon),
//       _bigDataCloud(lat, lon),
//     ];

//     final result = await _firstValidAnswer(futures);
//     if (result != null) return result;

//     // If all failed, check previous cache coordinates
//     if (_cachedLocation != null) {
//       return LocationResult(
//         latitude: lat,
//         longitude: lon,
//         subLocality: _cachedLocation!.subLocality,
//         street: _cachedLocation!.street,
//         city: _cachedLocation!.city,
//         state: _cachedLocation!.state,
//         district: _cachedLocation!.district,
//         postalCode: _cachedLocation!.postalCode,
//         country: _cachedLocation!.country,
//       );
//     }

//     return LocationResult(
//       latitude: lat,
//       longitude: lon,
//       subLocality: '',
//       street: '',
//       city: '',
//       state: '',
//       district: '',
//       postalCode: '',
//       country: '',
//     );
//   }

//   static Future<LocationResult?> _firstValidAnswer(
//     List<Future<LocationResult?>> list,
//   ) {
//     final completer = Completer<LocationResult?>();
//     var pending = list.length;

//     for (final f in list) {
//       f
//           .then((res) {
//             if (res != null &&
//                 (res.city.isNotEmpty ||
//                     res.subLocality.isNotEmpty ||
//                     res.district.isNotEmpty) &&
//                 !completer.isCompleted) {
//               completer.complete(res);
//             }
//           })
//           .catchError((_) {})
//           .whenComplete(() {
//             pending--;
//             if (pending == 0 && !completer.isCompleted) {
//               completer.complete(null);
//             }
//           });
//     }

//     // Safety timeout after 7 seconds
//     Future.delayed(const Duration(seconds: 7), () {
//       if (!completer.isCompleted) {
//         completer.complete(null);
//       }
//     });

//     return completer.future;
//   }

//   static Future<LocationResult?> _platformGeocoder(double lat, double lon) async {
//     try {
//       final placemarks = await placemarkFromCoordinates(
//         lat,
//         lon,
//       ).timeout(const Duration(seconds: 5));
//       if (placemarks.isEmpty) return null;

//       final p = placemarks.first;
//       final sub = p.subLocality ?? '';
//       final street = p.street ?? p.name ?? '';
//       final city = p.locality ?? p.subAdministrativeArea ?? '';
//       final state = p.administrativeArea ?? '';
//       final district = p.subAdministrativeArea ?? '';
//       final postal = p.postalCode ?? '';
//       final country = p.country ?? '';

//       return LocationResult(
//         latitude: lat,
//         longitude: lon,
//         subLocality: sub,
//         street: street,
//         city: city,
//         state: state,
//         district: district,
//         postalCode: postal,
//         country: country,
//       );
//     } catch (_) {
//       return null;
//     }
//   }

//   static Future<LocationResult?> _nominatim(double lat, double lon) async {
//     try {
//       final response = await _dio.get(
//         'https://nominatim.openstreetmap.org/reverse',
//         queryParameters: {
//           'format': 'json',
//           'lat': lat,
//           'lon': lon,
//           'zoom': 18,
//           'addressdetails': 1,
//         },
//       );

//       if (response.statusCode == 200 && response.data is Map) {
//         final data = response.data as Map;
//         final address = (data['address'] as Map?) ?? {};

//         final road = (address['road'] ?? address['street'] ?? '').toString();
//         final house = (address['house_number'] ?? '').toString();
//         final street = house.isNotEmpty ? '$house $road' : road;

//         final subLocality = (address['suburb'] ??
//                 address['neighbourhood'] ??
//                 address['subdistrict'] ??
//                 '')
//             .toString();

//         final city = (address['city'] ??
//                 address['town'] ??
//                 address['village'] ??
//                 address['municipality'] ??
//                 '')
//             .toString();

//         final state = (address['state'] ?? '').toString();
//         final district = (address['county'] ??
//                 address['state_district'] ??
//                 address['city_district'] ??
//                 '')
//             .toString();
//         final postalCode = (address['postcode'] ?? '').toString();
//         final country = (address['country'] ?? '').toString();

//         return LocationResult(
//           latitude: lat,
//           longitude: lon,
//           subLocality: subLocality,
//           street: street,
//           city: city,
//           state: state,
//           district: district,
//           postalCode: postalCode,
//           country: country,
//         );
//       }
//     } catch (_) {
//       // Network or decode failure
//     }
//     return null;
//   }

//   static Future<LocationResult?> _bigDataCloud(double lat, double lon) async {
//     try {
//       final response = await _dio.get(
//         'https://api.bigdatacloud.net/data/reverse-geocode-client',
//         queryParameters: {
//           'latitude': lat,
//           'longitude': lon,
//           'localityLanguage': 'en',
//         },
//       );

//       if (response.statusCode == 200 && response.data is Map) {
//         final data = response.data as Map;

//         final locality = (data['locality'] ?? '').toString();
//         final city = (data['city'] ?? data['principalSubdivision'] ?? '')
//             .toString();
//         final state = (data['principalSubdivision'] ?? '').toString();
//         final postalCode = (data['postcode'] ?? '').toString();
//         final country = (data['countryName'] ?? '').toString();

//         return LocationResult(
//           latitude: lat,
//           longitude: lon,
//           subLocality: locality,
//           street: '',
//           city: city,
//           state: state,
//           district: '',
//           postalCode: postalCode,
//           country: country,
//         );
//       }
//     } catch (_) {}
//     return null;
//   }
// }


import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:avg_mart/service/storege_service.dart';

enum LocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown,
}

class LocationException implements Exception {
  final LocationFailure failure;
  final String message;

  const LocationException(this.failure, this.message);

  @override
  String toString() => message;
}

class LocationResult {
  final double latitude;
  final double longitude;
  final String subLocality;
  final String street;
  final String city;
  final String state;
  final String district;
  final String postalCode;
  final String country;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.street,
    required this.city,
    required this.state,
    required this.district,
    required this.postalCode,
    required this.country,
    this.subLocality = '',
  });

  /// True when at least one human-readable place field is present.
  bool get hasAddress =>
      city.trim().isNotEmpty ||
      subLocality.trim().isNotEmpty ||
      district.trim().isNotEmpty ||
      street.trim().isNotEmpty;

  /// Short, accurate label for the header (e.g. "Koramangala, Bengaluru 560034").
  String get label {
    final sub = subLocality.trim();
    final c = city.trim();
    final d = district.trim();
    final s = street.trim();
    final pin = postalCode.trim();

    final parts = <String>[];
    if (sub.isNotEmpty) {
      parts.add(sub);
    } else if (s.isNotEmpty) {
      parts.add(s);
    }

    if (c.isNotEmpty && !parts.contains(c)) {
      parts.add(c);
    } else if (parts.isEmpty && d.isNotEmpty) {
      parts.add(d);
    }

    final area = parts.isNotEmpty ? parts.join(', ') : '';
    final pincodeStr = pin.isNotEmpty ? ' $pin' : '';

    if (area.isNotEmpty) {
      return '$area$pincodeStr'.trim();
    }
    if (c.isNotEmpty) {
      return '$c$pincodeStr'.trim();
    }
    return 'Current Location';
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'subLocality': subLocality,
    'street': street,
    'city': city,
    'state': state,
    'district': district,
    'postalCode': postalCode,
    'country': country,
  };

  factory LocationResult.fromJson(Map<String, dynamic> json) => LocationResult(
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    subLocality: (json['subLocality'] ?? '') as String,
    street: (json['street'] ?? '') as String,
    city: (json['city'] ?? '') as String,
    state: (json['state'] ?? '') as String,
    district: (json['district'] ?? '') as String,
    postalCode: (json['postalCode'] ?? '') as String,
    country: (json['country'] ?? '') as String,
  );
}

class LocationService {
  static const String _cacheKey = 'cached_user_location_v2';

  /// Minimum movement (meters) before we re-geocode and update the header.
  static const double _moveThresholdMeters = 150;

  static final StorageService _storage = StorageService();
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 6),
      receiveTimeout: const Duration(seconds: 6),
      headers: {
        'User-Agent': 'AVGMart-App/1.2 (Android; Mobile; support@avgmart.com)',
        'Accept': 'application/json',
      },
    ),
  );

  // In-memory cache for instant zero-latency UI rendering
  static LocationResult? _cachedLocation;
  static bool _hasLoadedFromDisk = false;
  static Future<LocationResult>? _inFlightFetch;
  static DateTime? _lastFetchTime;

  /// Every header listens to this so all screens update together whenever
  /// the stored location changes (fresh fetch, user moved, loaded from disk).
  static final ValueNotifier<LocationResult?> locationNotifier =
      ValueNotifier<LocationResult?>(null);

  static StreamSubscription<Position>? _positionSub;
  static bool _processingMove = false;

  static LocationResult? get currentCachedLocation => _cachedLocation;

  /// Loads cached location from persistent storage if not already loaded into memory.
  static Future<LocationResult?> loadFromStorage() async {
    if (_cachedLocation != null) return _cachedLocation;
    if (_hasLoadedFromDisk) return null;

    try {
      _hasLoadedFromDisk = true;
      final data = await _storage.getResponse(_cacheKey);
      if (data != null) {
        final loaded = LocationResult.fromJson(data);
        // Don't overwrite a fresher in-memory value that arrived meanwhile.
        _cachedLocation ??= loaded;
        locationNotifier.value = _cachedLocation;
        return _cachedLocation;
      }
    } catch (_) {
      // Storage read error ignored
    }
    return null;
  }

  /// Saves location to memory and persistent storage, and notifies listeners.
  static Future<void> saveCachedLocation(LocationResult result) async {
    _cachedLocation = result;
    locationNotifier.value = result;
    try {
      await _storage.saveResponse(_cacheKey, result.toJson());
    } catch (_) {
      // Storage write error ignored
    }
  }

  /// Emits whenever the user toggles the device location switch.
  static Stream<ServiceStatus> get serviceStatusStream =>
      Geolocator.getServiceStatusStream();

  static Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();

  static Future<bool> openAppSettings() => Geolocator.openAppSettings();

  // ---------------------------------------------------------------------------
  // Live tracking: updates the cached address when the user actually moves.
  // ---------------------------------------------------------------------------

  /// Safe to call many times; only one stream is ever active.
  static Future<void> startTracking() async {
    if (_positionSub != null) return;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever ||
          perm == LocationPermission.unableToDetermine) {
        return;
      }

      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 150, // meters
        ),
      ).listen(_onPositionUpdate, onError: (_) {}, cancelOnError: false);
    } catch (_) {
      _positionSub = null;
    }
  }

  static Future<void> stopTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }

  static Future<void> _onPositionUpdate(Position pos) async {
    if (_processingMove) return;

    final cached = _cachedLocation;
    if (cached != null && cached.hasAddress) {
      final moved = Geolocator.distanceBetween(
        cached.latitude,
        cached.longitude,
        pos.latitude,
        pos.longitude,
      );
      if (moved < _moveThresholdMeters) return;
    }

    _processingMove = true;
    try {
      final result = await _reverseGeocode(pos.latitude, pos.longitude);
      if (result.hasAddress) {
        _lastFetchTime = DateTime.now();
        await saveCachedLocation(result);
      }
    } catch (_) {
      // Keep showing the previous cached location.
    } finally {
      _processingMove = false;
    }
  }

  // ---------------------------------------------------------------------------

  /// Fetches current location with single-flight de-duplication and multi-source geocoding.
  static Future<LocationResult> fetchCurrentLocation({bool force = false}) {
    // If not forced and recent result is available, return immediately
    if (!force &&
        _cachedLocation != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 5) {
      return Future.value(_cachedLocation);
    }

    // De-duplicate concurrent calls
    if (_inFlightFetch != null && !force) {
      return _inFlightFetch!;
    }

    final future = _performFetch();
    _inFlightFetch = future;
    return future.whenComplete(() {
      _inFlightFetch = null;
    });
  }

  static Future<LocationResult> _performFetch() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        LocationFailure.serviceDisabled,
        'Location services are disabled on your device.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
          LocationFailure.permissionDenied,
          'Location permission was denied.',
        );
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        LocationFailure.permissionDeniedForever,
        'Location permission is permanently denied in settings.',
      );
    }

    // Try last known position first (instant fallback)
    Position? pos;
    try {
      pos = await Geolocator.getLastKnownPosition();
    } catch (_) {}

    // Fetch fresh position with high accuracy
    try {
      pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 9),
        ),
      );
    } catch (_) {
      // Ignored: fallback to last known or cache below
    }

    if (pos == null) {
      if (_cachedLocation != null) return _cachedLocation!;
      throw const LocationException(
        LocationFailure.unknown,
        'Location unavailable.',
      );
    }

    final result = await _reverseGeocode(pos.latitude, pos.longitude);

    // Never replace a good cached address with an empty one.
    if (!result.hasAddress && _cachedLocation != null) {
      return _cachedLocation!;
    }

    _lastFetchTime = DateTime.now();
    await saveCachedLocation(result);
    return result;
  }

  /// Multi-source reverse geocoder (Platform Geocoder + OSM Nominatim + BigDataCloud).
  /// The first provider with non-empty locality/city wins.
  static Future<LocationResult> _reverseGeocode(double lat, double lon) async {
    final futures = <Future<LocationResult?>>[
      _platformGeocoder(lat, lon),
      _nominatim(lat, lon),
      _bigDataCloud(lat, lon),
    ];

    final result = await _firstValidAnswer(futures);
    if (result != null) return result;

    // If all failed, reuse previous address text with the new coordinates
    if (_cachedLocation != null) {
      return LocationResult(
        latitude: lat,
        longitude: lon,
        subLocality: _cachedLocation!.subLocality,
        street: _cachedLocation!.street,
        city: _cachedLocation!.city,
        state: _cachedLocation!.state,
        district: _cachedLocation!.district,
        postalCode: _cachedLocation!.postalCode,
        country: _cachedLocation!.country,
      );
    }

    return LocationResult(
      latitude: lat,
      longitude: lon,
      subLocality: '',
      street: '',
      city: '',
      state: '',
      district: '',
      postalCode: '',
      country: '',
    );
  }

  static Future<LocationResult?> _firstValidAnswer(
    List<Future<LocationResult?>> list,
  ) {
    final completer = Completer<LocationResult?>();
    var pending = list.length;

    for (final f in list) {
      f
          .then((res) {
            if (res != null &&
                (res.city.isNotEmpty ||
                    res.subLocality.isNotEmpty ||
                    res.district.isNotEmpty) &&
                !completer.isCompleted) {
              completer.complete(res);
            }
          })
          .catchError((_) {})
          .whenComplete(() {
            pending--;
            if (pending == 0 && !completer.isCompleted) {
              completer.complete(null);
            }
          });
    }

    // Safety timeout after 7 seconds
    Future.delayed(const Duration(seconds: 7), () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    return completer.future;
  }

  static Future<LocationResult?> _platformGeocoder(
    double lat,
    double lon,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        lat,
        lon,
      ).timeout(const Duration(seconds: 5));
      if (placemarks.isEmpty) return null;

      final p = placemarks.first;
      final sub = p.subLocality ?? '';
      final street = p.street ?? p.name ?? '';
      final city = p.locality ?? p.subAdministrativeArea ?? '';
      final state = p.administrativeArea ?? '';
      final district = p.subAdministrativeArea ?? '';
      final postal = p.postalCode ?? '';
      final country = p.country ?? '';

      return LocationResult(
        latitude: lat,
        longitude: lon,
        subLocality: sub,
        street: street,
        city: city,
        state: state,
        district: district,
        postalCode: postal,
        country: country,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<LocationResult?> _nominatim(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': lat,
          'lon': lon,
          'zoom': 18,
          'addressdetails': 1,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final address = (data['address'] as Map?) ?? {};

        final road = (address['road'] ?? address['street'] ?? '').toString();
        final house = (address['house_number'] ?? '').toString();
        final street = house.isNotEmpty ? '$house $road' : road;

        final subLocality = (address['suburb'] ??
                address['neighbourhood'] ??
                address['subdistrict'] ??
                '')
            .toString();

        final city = (address['city'] ??
                address['town'] ??
                address['village'] ??
                address['municipality'] ??
                '')
            .toString();

        final state = (address['state'] ?? '').toString();
        final district = (address['county'] ??
                address['state_district'] ??
                address['city_district'] ??
                '')
            .toString();
        final postalCode = (address['postcode'] ?? '').toString();
        final country = (address['country'] ?? '').toString();

        return LocationResult(
          latitude: lat,
          longitude: lon,
          subLocality: subLocality,
          street: street,
          city: city,
          state: state,
          district: district,
          postalCode: postalCode,
          country: country,
        );
      }
    } catch (_) {
      // Network or decode failure
    }
    return null;
  }

  static Future<LocationResult?> _bigDataCloud(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://api.bigdatacloud.net/data/reverse-geocode-client',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'localityLanguage': 'en',
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;

        final locality = (data['locality'] ?? '').toString();
        final city = (data['city'] ?? data['principalSubdivision'] ?? '')
            .toString();
        final state = (data['principalSubdivision'] ?? '').toString();
        final postalCode = (data['postcode'] ?? '').toString();
        final country = (data['countryName'] ?? '').toString();

        return LocationResult(
          latitude: lat,
          longitude: lon,
          subLocality: locality,
          street: '',
          city: city,
          state: state,
          district: '',
          postalCode: postalCode,
          country: country,
        );
      }
    } catch (_) {}
    return null;
  }
}