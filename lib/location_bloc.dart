import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationBloc extends Bloc<void, bool> {
  late StreamSubscription<Position> _positionSubscription;

  LocationBloc() : super(false) {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      _positionSubscription = Geolocator.getPositionStream().listen((position) {
        _checkInSpecificArea(position);
      });
    }
  }

  void _checkInSpecificArea(Position position) async {
    const specificAreaLatitude = 23.006216941644222;
    const specificAreaLongitude = 72.60118651047857;
    final distance = await Geolocator.distanceBetween(
      specificAreaLatitude,
      specificAreaLongitude,
      position.latitude,
      position.longitude,
    );
    if (distance <= 100) {
      emit(true);
    } else {
      emit(false);
    }
    print('Position is $position');
  }

  @override
  Future<void> close() {
    _positionSubscription.cancel();
    return super.close();
  }
}
