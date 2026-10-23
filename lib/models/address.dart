class UserAddress {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String street;
  final String apartment;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isDefault;

  const UserAddress({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    required this.apartment,
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'United States',
    this.isDefault = false,
  });

  UserAddress copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? street,
    String? apartment,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      apartment: apartment ?? this.apartment,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get formattedAddress {
    final aptStr = apartment.isNotEmpty ? ', $apartment' : '';
    return '$street$aptStr, $city, $state $zipCode, $country';
  }
}


class ShippingAddress {
  final String? id;
  final String tag;
  final String phone;
  final String streetName;
  final String landmark;
  final String city;
  final String state;
  final String district;
  final String pincode;
  final double? latitude;
  final double? longitude;

  const ShippingAddress({
    this.id,
    required this.tag,
    required this.phone,
    required this.streetName,
    required this.landmark,
    required this.city,
    required this.state,
    required this.district,
    required this.pincode,
    this.latitude,
    this.longitude,
  });

  String get fullName => tag;
  String get street => streetName;
  String get postalCode => pincode;
  String get phoneNumber => phone;

  String get formattedAddress {
    final landmarkStr = landmark.isNotEmpty ? ', $landmark' : '';
    return '$streetName$landmarkStr, $city, $state $pincode, $district';
  }

  bool get isValid =>
      tag.isNotEmpty &&
      phone.isNotEmpty &&
      streetName.isNotEmpty &&
      city.isNotEmpty &&
      pincode.isNotEmpty;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['_id'] ?? json['id']?.toString(),
      tag: json['tag'] ?? 'Home',
      phone: json['phone'] ?? '',
      streetName: json['street_name'] ?? json['streetName'] ?? '',
      landmark: json['landmark'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      pincode: json['pincode'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tag': tag,
      'phone': phone,
      'streetName': streetName,
      'landmark': landmark,
      'city': city,
      'state': state,
      'district': district,
      'pincode': pincode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }

  ShippingAddress copyWith({
    String? id,
    String? tag,
    String? phone,
    String? streetName,
    String? landmark,
    String? city,
    String? state,
    String? district,
    String? pincode,
    double? latitude,
    double? longitude,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      phone: phone ?? this.phone,
      streetName: streetName ?? this.streetName,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      district: district ?? this.district,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

