import 'package:bloc/bloc.dart';
import 'package:avg_mart/models/address.dart';
import 'package:avg_mart/service/api_service.dart';
import 'package:avg_mart/service/storege_service.dart';
import 'profile_state.dart';


class ProfileCubit extends Cubit<ProfileState> {
  final ApiService _apiService;
  ShippingAddress? _selectedAddress;
  bool _isLoggedIn = true;

  ProfileCubit({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(ProfileInitial());

  bool get isLoggedIn {
    if (state is ProfileLoaded) {
      return (state as ProfileLoaded).isLoggedIn;
    }
    return _isLoggedIn;
  }

  ShippingAddress? get selectedAddress {
    if (state is ProfileLoaded) {
      return (state as ProfileLoaded).selectedAddress ?? _selectedAddress;
    }
    return _selectedAddress;
  }

  void selectAddress(ShippingAddress address) {
    _selectedAddress = address;
    if (state is ProfileLoaded) {
      final loaded = state as ProfileLoaded;
      emit(ProfileLoaded(
        user: loaded.user,
        addresses: loaded.addresses,
        primaryAddress: loaded.primaryAddress,
        selectedAddress: address,
        isLoggedIn: _isLoggedIn,
      ));
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _selectedAddress = null;
    await StorageService().clearAll();
    emit(ProfileInitial());
  }

  Future<void> fetchProfile() async {
    emit(ProfileLoading());
    try {
      await _apiService.addToken();
      final profile = await _apiService.getProfile();

      final user = profile['user'] as Map<String, dynamic>? ?? {};
      final addressesList = profile['addresses'] as List? ?? [];

      final addresses = addressesList
          .map((json) => ShippingAddress.fromJson(json as Map<String, dynamic>))
          .toList();

      ShippingAddress? primaryAddress;
      if (addresses.isNotEmpty) {
        primaryAddress = addresses.first;
      }

      if (_selectedAddress == null) {
        _selectedAddress = primaryAddress;
      } else {
        final idx = addresses.indexWhere((a) => a.id == _selectedAddress?.id);
        if (idx != -1) {
          _selectedAddress = addresses[idx];
        } else {
          _selectedAddress = primaryAddress;
        }
      }

      _isLoggedIn = true;

      emit(ProfileLoaded(
        user: user,
        addresses: addresses,
        primaryAddress: primaryAddress,
        selectedAddress: _selectedAddress,
        isLoggedIn: _isLoggedIn,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<bool> addAddress({
    required String tag,
    required String phone,
    required String streetName,
    required String landmark,
    required String city,
    required String state,
    required String district,
    required String pincode,
  }) async {
    try {
      await _apiService.addToken();
      await _apiService.addAddress(
        tag: tag,
        phone: phone,
        streetName: streetName,
        landmark: landmark,
        city: city,
        state: state,
        district: district,
        pincode: pincode,
      );
      await fetchProfile();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> editAddress({
    required String id,
    required String tag,
    required String phone,
    required String streetName,
    required String landmark,
    required String city,
    required String state,
    required String district,
    required String pincode,
  }) async {
    try {
      await _apiService.addToken();
      await _apiService.editAddress(
        id: id,
        data: {
          "tag": tag,
          "phone": phone,
          "streetName": streetName,
          "landmark": landmark,
          "city": city,
          "state": state,
          "district": district,
          "pincode": pincode,
        },
      );
      await fetchProfile();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeAddress(String id) async {
    try {
      await _apiService.addToken();
      await _apiService.removeAddress(id: id);
      await fetchProfile();
      return true;
    } catch (_) {
      return false;
    }
  }
}
