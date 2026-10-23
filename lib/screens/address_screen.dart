import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/profile/profile_cubit.dart';
import '../bloc/profile/profile_state.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../models/address.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  // Same radii as the cart and checkout screens.
  static const double _rCard = 14;
  static const double _rControl = 10;

  bool _isAddingAddress = false;
  bool _isLocating = false;

  // When non-null, the form is in "edit" mode for this address
  // instead of "add new address" mode.
  ShippingAddress? _editingAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BlocProvider.of<ProfileCubit>(context).fetchProfile();
      }
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _aptController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  bool _setAsDefault = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _aptController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isLocating = true;
    });

    try {
      // 1. Make sure location services are actually on.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError(
          'Location services are disabled. Please enable GPS and try again.',
        );
        return;
      }

      // 2. Check/request permission.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError(
          'Location permission is permanently denied. Please enable it from app settings.',
        );
        return;
      }

      // 3. Get the current GPS position.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // 4. Reverse-geocode the coordinates into a human-readable address.
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        _showError('Could not resolve an address for your current location.');
        return;
      }

      final place = placemarks.first;

      if (!mounted) return;

      setState(() {
        final street = [
          place.subThoroughfare,
          place.thoroughfare,
        ].where((s) => s != null && s.isNotEmpty).join(' ');
        _streetController.text = street.isNotEmpty
            ? street
            : (place.street ?? '');
        _aptController.text = place.subLocality ?? '';
        _cityController.text =
            place.locality ?? place.subAdministrativeArea ?? '';
        _stateController.text = place.administrativeArea ?? '';
        _zipController.text = place.postalCode ?? '';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location details filled in.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showError('Failed to fetch location: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _isLocating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.error,
      ),
    );
  }

  // Pre-fill the form with an existing address and switch into edit mode.
  void _startEdit(ShippingAddress address) {
    setState(() {
      _editingAddress = address;
      _nameController.text = address.fullName;
      _phoneController.text = address.phoneNumber;
      _streetController.text = address.streetName;
      _aptController.text = address.landmark;
      _cityController.text = address.city;
      _stateController.text = address.state;
      _zipController.text = address.pincode;
      _setAsDefault = false;
      _isAddingAddress = true;
    });
  }

  void _resetForm() {
    _nameController.clear();
    _phoneController.clear();
    _streetController.clear();
    _aptController.clear();
    _cityController.clear();
    _stateController.clear();
    _zipController.clear();
    _setAsDefault = false;
    _editingAddress = null;
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final wasEditing = _editingAddress != null;
      final cubit = BlocProvider.of<ProfileCubit>(context);

      final success = wasEditing
          ? await cubit.editAddress(
              id: _editingAddress!.id ?? '',
              tag: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              streetName: _streetController.text.trim(),
              landmark: _aptController.text.trim(),
              city: _cityController.text.trim(),
              state: _stateController.text.trim(),
              district: _cityController.text.trim(), // fallback
              pincode: _zipController.text.trim(),
            )
          : await cubit.addAddress(
              tag: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              streetName: _streetController.text.trim(),
              landmark: _aptController.text.trim(),
              city: _cityController.text.trim(),
              state: _stateController.text.trim(),
              district: _cityController.text.trim(), // fallback
              pincode: _zipController.text.trim(),
            );

      if (success && mounted) {
        setState(() {
          _isAddingAddress = false;
          _resetForm();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasEditing
                  ? 'Address updated successfully.'
                  : 'Address saved successfully.',
            ),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasEditing
                  ? 'Failed to update address. Please try again.'
                  : 'Failed to save address. Please try again.',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Shared styling helpers
  // ---------------------------------------------------------------------------
  BoxDecoration _cardDecoration({
    Color? border,
    double borderWidth = 1,
    Color? color,
  }) => BoxDecoration(
    color: color ?? AppTheme.surface,
    borderRadius: BorderRadius.circular(_rCard),
    border: Border.all(color: border ?? AppTheme.divider, width: borderWidth),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    ),
  );

  Widget _bottomBar({required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: AppTheme.divider)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(top: false, child: child),
    );
  }

  ButtonStyle get _primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_rControl),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        return Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppTheme.headerGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            elevation: 0,
            title: Text(
              _isAddingAddress
                  ? (_editingAddress != null
                        ? 'Edit Address'
                        : 'Add New Address')
                  : 'Select Shipping Location',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (_isAddingAddress) {
                  setState(() {
                    _isAddingAddress = false;
                    _editingAddress = null;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          backgroundColor: AppTheme.background,
          body: _isAddingAddress
              ? _buildAddAddressForm(appState)
              : _buildAddressListView(appState, profileState),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // LIST VIEW
  // ---------------------------------------------------------------------------
  Widget _buildAddressListView(AppState appState, ProfileState profileState) {
    if (profileState is ProfileLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileState is ProfileError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 28,
                  color: AppTheme.error,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load addresses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                profileState.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () =>
                      BlocProvider.of<ProfileCubit>(context).fetchProfile(),
                  style: _primaryButtonStyle,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Try again',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<ShippingAddress> addresses = profileState is ProfileLoaded
        ? profileState.addresses
        : [];

    // Keep AppState's selection state in sync with whatever ProfileCubit
    // just loaded, so appState.selectedAddress never points at a stale/
    // removed address from a previous session.
    if (profileState is ProfileLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        appState.setAddresses(
          addresses,
          primaryAddress: profileState.primaryAddress,
        );
      });
    }

    return Column(
      children: [
        Expanded(
          child: addresses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppTheme.tint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            size: 34,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'No addresses saved',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Add a delivery address to speed up checkout.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppTheme.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    final isSelected =
                        appState.selectedAddress?.id == address.id;
                    final isDefault =
                        (profileState is ProfileLoaded &&
                            profileState.primaryAddress?.id == address.id) ||
                        index == 0;
                    return _buildAddressCard(
                      address,
                      isSelected,
                      isDefault,
                      appState,
                    );
                  },
                ),
        ),
        _bottomBar(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _resetForm(); // start clean, not mid-edit
                  _isAddingAddress = true;
                });
              },
              style: _primaryButtonStyle,
              child: const Text(
                'Add new address',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(
    ShippingAddress address,
    bool isSelected,
    bool isDefault,
    AppState appState,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(_rCard),
      onTap: () => appState.selectAddress(address),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
        decoration: _cardDecoration(
          border: isSelected ? AppTheme.primary : AppTheme.divider,
          borderWidth: isSelected ? 1.5 : 1,
          color: isSelected ? AppTheme.tint : AppTheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: isSelected ? AppTheme.primary : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.fullName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.formattedAddress,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Phone: ${address.phoneNumber}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 32),
                _linkButton(
                  'Edit',
                  Icons.edit_outlined,
                  AppTheme.linkBlue,
                  () => _startEdit(address),
                ),
                // NOTE: "Set as default" removed - ProfileCubit/API has no
                // backing for it yet. primaryAddress is currently just
                // addresses.first, not a real persisted flag.
                _linkButton(
                  'Remove',
                  Icons.delete_outline_rounded,
                  AppTheme.error,
                  () => BlocProvider.of<ProfileCubit>(
                    context,
                  ).removeAddress(address.id ?? ''),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ADD / EDIT FORM
  // ---------------------------------------------------------------------------
  Widget _buildAddAddressForm(AppState appState) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: _fetchLocation,
                          icon: const Icon(
                            Icons.my_location,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                          label: const Text(
                            'Use current location',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.tint,
                            side: BorderSide(
                              color: AppTheme.primary.withOpacity(0.25),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(_rControl),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      _sectionTitle('Contact'),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
                        decoration: _cardDecoration(),
                        child: Column(
                          children: [
                            _buildTextField('Full name', _nameController),
                            _buildTextField(
                              'Phone number',
                              _phoneController,
                              isPhone: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _sectionTitle('Address'),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
                        decoration: _cardDecoration(),
                        child: Column(
                          children: [
                            _buildTextField(
                              'Street address',
                              _streetController,
                            ),
                            _buildTextField(
                              'Apartment, suite, unit (optional)',
                              _aptController,
                              required: false,
                            ),
                            _buildTextField('City', _cityController),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'State',
                                    _stateController,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    'ZIP code',
                                    _zipController,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Material(
                        color: Colors.transparent,
                        child: CheckboxListTile(
                          title: const Text(
                            'Make this my default address',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          value: _setAsDefault,
                          activeColor: AppTheme.primary,
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          onChanged: (val) {
                            setState(() {
                              _setAsDefault = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            _bottomBar(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: _primaryButtonStyle,
                  child: Text(
                    _editingAddress != null ? 'Update address' : 'Save address',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_isLocating)
          Container(
            color: Colors.black.withOpacity(0.35),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(_rCard),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Detecting your location',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'This may take a few seconds',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPhone = false,
    bool required = true,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(_rControl),
      borderSide: BorderSide(color: c, width: w),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
            textCapitalization: isPhone
                ? TextCapitalization.none
                : TextCapitalization.words,
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 13,
              ),
              filled: true,
              fillColor: AppTheme.background,
              enabledBorder: border(AppTheme.divider),
              border: border(AppTheme.divider),
              focusedBorder: border(AppTheme.primary, 1.5),
              errorBorder: border(AppTheme.error),
              focusedErrorBorder: border(AppTheme.error, 1.5),
            ),
            validator: required
                ? (val) {
                    if (val == null || val.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
