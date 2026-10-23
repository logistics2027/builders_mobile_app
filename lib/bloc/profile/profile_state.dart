import 'package:avg_mart/models/address.dart';
import 'package:equatable/equatable.dart';


abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> user;
  final List<ShippingAddress> addresses;
  final ShippingAddress? primaryAddress;
  final ShippingAddress? selectedAddress;
  final bool isLoggedIn;

  const ProfileLoaded({
    required this.user,
    required this.addresses,
    this.primaryAddress,
    this.selectedAddress,
    this.isLoggedIn = true,
  });

  @override
  List<Object?> get props => [user, addresses, primaryAddress, selectedAddress, isLoggedIn];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
