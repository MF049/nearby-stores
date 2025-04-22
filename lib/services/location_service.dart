import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  double calculateDistance(double startLatitude, double startLongitude, 
                         double endLatitude, double endLongitude) {
    // Using Haversine formula
    var earthRadius = 6371.0; // km
    
    var dLat = _toRadians(endLatitude - startLatitude);
    var dLon = _toRadians(endLongitude - startLongitude);
    
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
            math.cos(_toRadians(startLatitude)) * math.cos(_toRadians(endLatitude)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);
            
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var distance = earthRadius * c;
    
    return distance;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }
}
