// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:geolocator/geolocator.dart';
// import '../service/location_service.dart';
// import '../state/app_state.dart';
// import '../theme/app_theme.dart';
// import '../screens/search_results_screen.dart';
// import '../screens/address_screen.dart';
// import '../bloc/product/product_cubit.dart';
// import '../bloc/cart/cart_cubit.dart';
// import '../bloc/profile/profile_cubit.dart';

// class AvgHeader extends StatefulWidget implements PreferredSizeWidget {
//   final bool showBackButton;

//   /// When true (default), the search box is NOT editable — tapping it
//   /// navigates to [SearchResultsScreen]. Use this everywhere except the
//   /// search screen itself (Home, category pages, etc).
//   ///
//   /// When false, the search box is a live, editable TextField wired up via
//   /// [searchController] / [onSearchChanged] / [onSearchSubmitted]. Only
//   /// [SearchResultsScreen] should pass false — it owns the query state.
//   final bool isReadOnly;

//   /// Only used when [isReadOnly] is false. Required in that case so the
//   /// header can render/edit the caller's own query text.
//   final TextEditingController? searchController;
//   final ValueChanged<String>? onSearchChanged;
//   final ValueChanged<String>? onSearchSubmitted;
//   final VoidCallback? onBackPressed;

//   const AvgHeader({
//     super.key,
//     this.showBackButton = false,
//     this.isReadOnly = true,
//     this.searchController,
//     this.onSearchChanged,
//     this.onSearchSubmitted,
//     this.onBackPressed,
//   }) : assert(
//          isReadOnly || searchController != null,
//          'searchController is required when isReadOnly is false',
//        );

//   @override
//   State<AvgHeader> createState() => _AvgHeaderState();

//   @override
//   Size get preferredSize => const Size.fromHeight(112.0);
// }

// class _AvgHeaderState extends State<AvgHeader> with WidgetsBindingObserver {
//   LocationResult? _location = LocationService.currentCachedLocation;
//   bool _fetchingLiveLocation = false;
//   bool _locationOff = false;
//   static bool _enablePromptShownThisSession = false;

//   StreamSubscription<ServiceStatus>? _serviceStatusSub;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);

//     // If memory cache is empty, load from disk immediately
//     if (_location == null) {
//       LocationService.loadFromStorage().then((cached) {
//         if (mounted && cached != null && _location == null) {
//           setState(() {
//             _location = cached;
//           });
//         }
//       });
//     }

//     // Listen for device location toggle
//     _serviceStatusSub = LocationService.serviceStatusStream.listen((status) {
//       if (status == ServiceStatus.enabled) {
//         _refreshLocation(force: true);
//       } else if (mounted) {
//         setState(() {
//           _locationOff = true;
//         });
//       }
//     });

//     // Background fetch/verification
//     _refreshLocation(promptIfUnavailable: false);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _refreshLocation(force: false);
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _serviceStatusSub?.cancel();
//     super.dispose();
//   }

//   Future<void> _refreshLocation({
//     bool force = false,
//     bool promptIfUnavailable = false,
//   }) async {
//     if (_fetchingLiveLocation) return;

//     // Only show spinner if we have NO address at all to display yet
//     if (_location == null && mounted) {
//       setState(() => _fetchingLiveLocation = true);
//     }

//     try {
//       final result = await LocationService.fetchCurrentLocation(force: force);
//       if (!mounted) return;
//       setState(() {
//         _location = result;
//         _locationOff = false;
//         _fetchingLiveLocation = false;
//       });
//     } on LocationException catch (e) {
//       if (!mounted) return;
//       final unavailable =
//           e.failure == LocationFailure.serviceDisabled ||
//           e.failure == LocationFailure.permissionDenied ||
//           e.failure == LocationFailure.permissionDeniedForever;

//       setState(() {
//         _locationOff = unavailable;
//         _fetchingLiveLocation = false;
//       });

//       if (unavailable &&
//           promptIfUnavailable &&
//           !_enablePromptShownThisSession) {
//         _enablePromptShownThisSession = true;
//         _showEnableLocationDialog(e.failure);
//       }
//     } catch (_) {
//       if (mounted) setState(() => _fetchingLiveLocation = false);
//     }
//   }

//   Future<void> _showEnableLocationDialog(LocationFailure failure) async {
//     if (!mounted) return;

//     final bool needsAppSettings =
//         failure == LocationFailure.permissionDeniedForever;
//     final bool needsServiceSwitch = failure == LocationFailure.serviceDisabled;

//     final goToSettings = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Turn on location'),
//         content: Text(
//           needsServiceSwitch
//               ? 'Please enable device location to view exact delivery speeds and local AVG Mart deals near you.'
//               : needsAppSettings
//               ? 'Location permission is denied. Enable it in App Settings for precise delivery tracking.'
//               : 'Allow location access to show instant delivery availability near you.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text('Not now'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(ctx, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.primary,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Turn on'),
//           ),
//         ],
//       ),
//     );

//     if (goToSettings != true) return;

//     if (needsServiceSwitch) {
//       await LocationService.openLocationSettings();
//     } else if (needsAppSettings) {
//       await LocationService.openAppSettings();
//     } else {
//       await _refreshLocation(force: true);
//     }
//   }

//   void _openAddressScreen() {
//     ProfileCubit? profileCubit;
//     try {
//       profileCubit = BlocProvider.of<ProfileCubit>(context);
//     } catch (_) {
//       profileCubit = null;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (routeContext) => profileCubit != null
//             ? BlocProvider.value(
//                 value: profileCubit,
//                 child: const AddressScreen(),
//               )
//             : BlocProvider(
//                 create: (_) => ProfileCubit()..fetchProfile(),
//                 child: const AddressScreen(),
//               ),
//       ),
//     );
//   }

//   void _navigateToSearch() {
//     ProfileCubit? profileCubit;
//     try {
//       profileCubit = BlocProvider.of<ProfileCubit>(context);
//     } catch (_) {
//       profileCubit = null;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (routeContext) => MultiBlocProvider(
//           providers: [
//             BlocProvider.value(value: BlocProvider.of<ProductCubit>(context)),
//             BlocProvider.value(value: BlocProvider.of<CartCubit>(context)),
//             if (profileCubit != null)
//               BlocProvider.value(value: profileCubit)
//             else
//               BlocProvider(create: (_) => ProfileCubit()..fetchProfile()),
//           ],
//           child: const SearchResultsScreen(searchQuery: ''),
//         ),
//       ),
//     );
//   }

//   void _handleBack() {
//     if (widget.onBackPressed != null) {
//       widget.onBackPressed!();
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appState = AppStateProvider.of(context);
//     final selectedAddress = appState.selectedAddress;
//     final double topPadding = MediaQuery.of(context).padding.top;

//     return Container(
//       padding: EdgeInsets.only(top: topPadding),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: AppTheme.headerGradient,
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // --- Brand Logo + Location capsule row ---
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
//             child: SizedBox(
//               height: 38,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // AVG Mart Brand Emblem
//                   Container(
//                     width: 32,
//                     height: 32,
//                     margin: const EdgeInsets.only(right: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(9),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withValues(alpha: 0.12),
//                           blurRadius: 6,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     padding: const EdgeInsets.all(4),
//                     child: Image.asset(
//                       'assets/AVG.png',
//                       fit: BoxFit.contain,
//                       errorBuilder: (context, error, stackTrace) {
//                         return const Icon(
//                           Icons.shopping_bag_rounded,
//                           color: AppTheme.primary,
//                           size: 18,
//                         );
//                       },
//                     ),
//                   ),

//                   // Location Bar Chip
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: _openAddressScreen,
//                       behavior: HitTestBehavior.opaque,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withValues(alpha: 0.12),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: Colors.white.withValues(alpha: 0.22),
//                             width: 0.8,
//                           ),
//                         ),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: _buildLocationIcon(selectedAddress),
//                             ),
//                             const SizedBox(width: 6),
//                             Expanded(child: _buildAddressLabel(selectedAddress)),
//                             const SizedBox(width: 6),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withValues(alpha: 0.20),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     'Change',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 10.5,
//                                       fontWeight: FontWeight.w700,
//                                       letterSpacing: 0.2,
//                                     ),
//                                   ),
//                                   SizedBox(width: 2),
//                                   Icon(
//                                     Icons.chevron_right_rounded,
//                                     color: Colors.white,
//                                     size: 13,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // --- Search Bar Row ---
//           Padding(
//             padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
//             child: Row(
//               children: [
//                 if (widget.showBackButton) ...[
//                   GestureDetector(
//                     onTap: _handleBack,
//                     child: Container(
//                       width: 42,
//                       height: 42,
//                       margin: const EdgeInsets.only(right: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.16),
//                         borderRadius: BorderRadius.circular(13),
//                         border: Border.all(
//                           color: Colors.white.withValues(alpha: 0.2),
//                           width: 0.8,
//                         ),
//                       ),
//                       child: const Icon(
//                         Icons.arrow_back_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//                 ],
//                 Expanded(child: _buildSearchBox(context)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLocationIcon(dynamic selectedAddress) {
//     final bool showSpinner =
//         _fetchingLiveLocation && selectedAddress == null && _location == null;

//     if (showSpinner) {
//       return const Padding(
//         padding: EdgeInsets.all(2.0),
//         child: CircularProgressIndicator(
//           strokeWidth: 2,
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//         ),
//       );
//     }

//     final bool isOff =
//         selectedAddress == null && _locationOff && _location == null;

//     return Icon(
//       isOff ? Icons.location_off_rounded : Icons.location_on_rounded,
//       color: isOff ? Colors.amberAccent : Colors.white,
//       size: 16,
//     );
//   }

//   Widget _buildAddressLabel(dynamic selectedAddress) {
//     String label;

//     if (selectedAddress != null) {
//       final name = selectedAddress.fullName ?? 'You';
//       final city = selectedAddress.city ?? '';
//       final pin = selectedAddress.pincode ?? '';
//       final loc = city.isNotEmpty ? '$city $pin'.trim() : pin;
//       label = 'Deliver to $name${loc.isNotEmpty ? ' · $loc' : ''}';
//     } else if (_location != null && _location!.label.isNotEmpty) {
//       label = 'Deliver to ${_location!.label}';
//     } else if (_fetchingLiveLocation) {
//       label = 'Locating your area...';
//     } else if (_locationOff) {
//       label = 'Tap to turn on location';
//     } else {
//       label = 'Select delivery location';
//     }

//     return Text(
//       label,
//       maxLines: 1,
//       overflow: TextOverflow.ellipsis,
//       style: const TextStyle(
//         fontSize: 11.8,
//         color: Colors.white,
//         fontWeight: FontWeight.w600,
//         letterSpacing: 0.1,
//       ),
//     );
//   }

//   Widget _buildSearchBox(BuildContext context) {
//     final box = Container(
//       height: 44.0,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(22.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.10),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const Padding(
//             padding: EdgeInsets.only(left: 14.0, right: 8.0),
//             child: Icon(
//               Icons.search_rounded,
//               color: AppTheme.primary,
//               size: 22,
//             ),
//           ),
//           Expanded(
//             child: widget.isReadOnly
//                 ? const Text(
//                     'Search products, brands & more on AVG Mart',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: AppTheme.textMuted,
//                       fontSize: 13.5,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   )
//                 : TextField(
//                     controller: widget.searchController,
//                     autofocus: false,
//                     onChanged: widget.onSearchChanged,
//                     onSubmitted: widget.onSearchSubmitted,
//                     style: const TextStyle(
//                       fontSize: 14.0,
//                       color: AppTheme.textPrimary,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     decoration: const InputDecoration(
//                       hintText: 'Search products, brands & more on AVG Mart',
//                       hintStyle: TextStyle(
//                         color: AppTheme.textMuted,
//                         fontSize: 13.5,
//                         fontWeight: FontWeight.w400,
//                       ),
//                       border: InputBorder.none,
//                       isDense: true,
//                       contentPadding: EdgeInsets.symmetric(vertical: 11.0),
//                     ),
//                   ),
//           ),
//           if (!widget.isReadOnly &&
//               widget.searchController != null &&
//               widget.searchController!.text.isNotEmpty)
//             IconButton(
//               icon: const Icon(
//                 Icons.close_rounded,
//                 color: Colors.black45,
//                 size: 20,
//               ),
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(minWidth: 36),
//               onPressed: () {
//                 widget.searchController!.clear();
//                 widget.onSearchChanged?.call('');
//               },
//             )
//           else
//             Container(
//               margin: const EdgeInsets.only(right: 8),
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: AppTheme.tint,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.mic_none_rounded,
//                 color: AppTheme.primary,
//                 size: 16,
//               ),
//             ),
//         ],
//       ),
//     );

//     if (!widget.isReadOnly) return box;

//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       onTap: _navigateToSearch,
//       child: AbsorbPointer(child: box),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../service/location_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../screens/search_results_screen.dart';
import '../screens/address_screen.dart';
import '../bloc/product/product_cubit.dart';
import '../bloc/cart/cart_cubit.dart';
import '../bloc/profile/profile_cubit.dart';

class AvgHeader extends StatefulWidget implements PreferredSizeWidget {
  final bool showBackButton;

  /// When true (default), the search box is NOT editable — tapping it
  /// navigates to [SearchResultsScreen]. Use this everywhere except the
  /// search screen itself (Home, category pages, etc).
  ///
  /// When false, the search box is a live, editable TextField wired up via
  /// [searchController] / [onSearchChanged] / [onSearchSubmitted]. Only
  /// [SearchResultsScreen] should pass false — it owns the query state.
  final bool isReadOnly;

  /// Only used when [isReadOnly] is false. Required in that case so the
  /// header can render/edit the caller's own query text.
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onBackPressed;

  const AvgHeader({
    super.key,
    this.showBackButton = false,
    this.isReadOnly = true,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onBackPressed,
  }) : assert(
         isReadOnly || searchController != null,
         'searchController is required when isReadOnly is false',
       );

  @override
  State<AvgHeader> createState() => _AvgHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(112.0);
}

class _AvgHeaderState extends State<AvgHeader> with WidgetsBindingObserver {
  LocationResult? _location = LocationService.currentCachedLocation;
  bool _fetchingLiveLocation = false;
  bool _locationOff = false;
  static bool _enablePromptShownThisSession = false;

  StreamSubscription<ServiceStatus>? _serviceStatusSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Any change to the stored location (fresh fetch, user moved, disk load)
    // updates this header automatically. The cached value is never cleared.
    LocationService.locationNotifier.addListener(_onLocationChanged);

    // If memory cache is empty, load from disk immediately
    if (_location == null) {
      LocationService.loadFromStorage().then((cached) {
        if (mounted && cached != null && _location == null) {
          setState(() => _location = cached);
        }
      });
    }

    // Listen for device location toggle
    _serviceStatusSub = LocationService.serviceStatusStream.listen((status) {
      if (status == ServiceStatus.enabled) {
        _refreshLocation(force: true);
        LocationService.startTracking();
      } else {
        // Location switched off: keep showing the cached address,
        // just flag it so the icon can reflect it.
        LocationService.stopTracking();
        if (mounted) setState(() => _locationOff = true);
      }
    });

    // Background fetch/verification
    _refreshLocation(promptIfUnavailable: false);
    LocationService.startTracking();
  }

  void _onLocationChanged() {
    final updated = LocationService.locationNotifier.value;
    if (!mounted || updated == null) return;
    setState(() => _location = updated);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLocation(force: false);
      LocationService.startTracking();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LocationService.locationNotifier.removeListener(_onLocationChanged);
    _serviceStatusSub?.cancel();
    super.dispose();
  }

  Future<void> _refreshLocation({
    bool force = false,
    bool promptIfUnavailable = false,
  }) async {
    if (_fetchingLiveLocation) return;

    // Only show spinner if we have NO address at all to display yet
    if (_location == null && mounted) {
      setState(() => _fetchingLiveLocation = true);
    }

    try {
      final result = await LocationService.fetchCurrentLocation(force: force);
      if (!mounted) return;
      setState(() {
        _location = result;
        _locationOff = false;
        _fetchingLiveLocation = false;
      });
      // Permission may have just been granted — make sure tracking runs.
      LocationService.startTracking();
    } on LocationException catch (e) {
      if (!mounted) return;
      final unavailable =
          e.failure == LocationFailure.serviceDisabled ||
          e.failure == LocationFailure.permissionDenied ||
          e.failure == LocationFailure.permissionDeniedForever;

      // NOTE: _location is intentionally NOT touched here, so the cached
      // address keeps showing while location is off / denied.
      setState(() {
        _locationOff = unavailable;
        _fetchingLiveLocation = false;
      });

      if (unavailable &&
          promptIfUnavailable &&
          !_enablePromptShownThisSession) {
        _enablePromptShownThisSession = true;
        _showEnableLocationDialog(e.failure);
      }
    } catch (_) {
      if (mounted) setState(() => _fetchingLiveLocation = false);
    }
  }

  Future<void> _showEnableLocationDialog(LocationFailure failure) async {
    if (!mounted) return;

    final bool needsAppSettings =
        failure == LocationFailure.permissionDeniedForever;
    final bool needsServiceSwitch = failure == LocationFailure.serviceDisabled;

    final goToSettings = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Turn on location'),
        content: Text(
          needsServiceSwitch
              ? 'Please enable device location to view exact delivery speeds and local AVG Mart deals near you.'
              : needsAppSettings
              ? 'Location permission is denied. Enable it in App Settings for precise delivery tracking.'
              : 'Allow location access to show instant delivery availability near you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Turn on'),
          ),
        ],
      ),
    );

    if (goToSettings != true) return;

    if (needsServiceSwitch) {
      await LocationService.openLocationSettings();
    } else if (needsAppSettings) {
      await LocationService.openAppSettings();
    } else {
      await _refreshLocation(force: true);
    }
  }

  void _openAddressScreen() {
    ProfileCubit? profileCubit;
    try {
      profileCubit = BlocProvider.of<ProfileCubit>(context);
    } catch (_) {
      profileCubit = null;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) => profileCubit != null
            ? BlocProvider.value(
                value: profileCubit,
                child: const AddressScreen(),
              )
            : BlocProvider(
                create: (_) => ProfileCubit()..fetchProfile(),
                child: const AddressScreen(),
              ),
      ),
    );
  }

  void _navigateToSearch() {
    ProfileCubit? profileCubit;
    try {
      profileCubit = BlocProvider.of<ProfileCubit>(context);
    } catch (_) {
      profileCubit = null;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: BlocProvider.of<ProductCubit>(context)),
            BlocProvider.value(value: BlocProvider.of<CartCubit>(context)),
            if (profileCubit != null)
              BlocProvider.value(value: profileCubit)
            else
              BlocProvider(create: (_) => ProfileCubit()..fetchProfile()),
          ],
          child: const SearchResultsScreen(searchQuery: ''),
        ),
      ),
    );
  }

  void _handleBack() {
    if (widget.onBackPressed != null) {
      widget.onBackPressed!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final selectedAddress = appState.selectedAddress;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPadding),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Brand Logo + Location capsule row ---
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
            child: SizedBox(
              height: 38,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // AVG Mart Brand Emblem
                  Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/AVG.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.shopping_bag_rounded,
                          color: AppTheme.primary,
                          size: 18,
                        );
                      },
                    ),
                  ),

                  // Location Bar Chip
                  Expanded(
                    child: GestureDetector(
                      onTap: _openAddressScreen,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: _buildLocationIcon(selectedAddress),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildAddressLabel(selectedAddress),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Change',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Search Bar Row ---
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
            child: Row(
              children: [
                if (widget.showBackButton) ...[
                  GestureDetector(
                    onTap: _handleBack,
                    child: Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                Expanded(child: _buildSearchBox(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationIcon(dynamic selectedAddress) {
    final bool showSpinner =
        _fetchingLiveLocation && selectedAddress == null && _location == null;

    if (showSpinner) {
      return const Padding(
        padding: EdgeInsets.all(2.0),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    // Only show the "off" icon when there is no address to display at all.
    final bool isOff =
        selectedAddress == null && _locationOff && _location == null;

    return Icon(
      isOff ? Icons.location_off_rounded : Icons.location_on_rounded,
      color: isOff ? Colors.amberAccent : Colors.white,
      size: 16,
    );
  }

  Widget _buildAddressLabel(dynamic selectedAddress) {
    String label;

    if (selectedAddress != null) {
      final name = selectedAddress.fullName ?? 'You';
      final city = selectedAddress.city ?? '';
      final pin = selectedAddress.pincode ?? '';
      final loc = city.isNotEmpty ? '$city $pin'.trim() : pin;
      label = 'Deliver to $name${loc.isNotEmpty ? ' · $loc' : ''}';
    } else if (_location != null && _location!.hasAddress) {
      // Cached (or live) location is always preferred, even if the
      // device location switch is currently off.
      label = 'Deliver to ${_location!.label}';
    } else if (_fetchingLiveLocation) {
      label = 'Locating your area...';
    } else if (_locationOff) {
      label = 'Tap to turn on location';
    } else {
      label = 'Select delivery location';
    }

    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11.8,
        color: Colors.white,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    final box = Container(
      height: 44.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 14.0, right: 8.0),
            child: Icon(
              Icons.search_rounded,
              color: AppTheme.primary,
              size: 22,
            ),
          ),
          Expanded(
            child: widget.isReadOnly
                ? const Text(
                    'Search products, brands & more on AVG Mart',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : TextField(
                    controller: widget.searchController,
                    autofocus: false,
                    onChanged: widget.onSearchChanged,
                    onSubmitted: widget.onSearchSubmitted,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search products, brands & more on AVG Mart',
                      hintStyle: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 11.0),
                    ),
                  ),
          ),
          if (!widget.isReadOnly &&
              widget.searchController != null &&
              widget.searchController!.text.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.black45,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36),
              onPressed: () {
                widget.searchController!.clear();
                widget.onSearchChanged?.call('');
              },
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.tint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_none_rounded,
                color: AppTheme.primary,
                size: 16,
              ),
            ),
        ],
      ),
    );

    if (!widget.isReadOnly) return box;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _navigateToSearch,
      child: AbsorbPointer(child: box),
    );
  }
}
