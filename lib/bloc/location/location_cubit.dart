import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  Future<void> checkLocationStatus() async {
    emit(LocationChecking());
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationDisabled());
        return;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        emit(LocationEnabled());
      } else {
        emit(LocationDisabled());
      }
    } catch (_) {
      emit(LocationDisabled());
    }
  }

  Future<void> requestLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationDisabled());
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        emit(LocationEnabled());
      } else {
        emit(LocationDisabled());
      }
    } catch (_) {
      emit(LocationDisabled());
    }
  }
}
