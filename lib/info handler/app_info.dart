import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user_fyp/info%20handler/directions.dart';

import '../assistants/geofire_assistant.dart';
import '../models/active_nearby_available_drivers.dart';

class AppInfo extends ChangeNotifier
{
  Directions? userPickUpLocation, userDropOffLocation;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};


  void updatePickUpLocationAddress(Directions userPickUpAddress)
  {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress)
  {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  void resetValues() {
    userPickUpLocation = null;
    userDropOffLocation = null;
    notifyListeners();
  }

  displayActiveDriversOnUsersMap(List<ActiveNearbyAvailableDrivers> drivers) {
    markersSet.clear();
    circlesSet.clear();

    Set<Marker> driversMarkerSet = Set<Marker>();

    if (drivers.isNotEmpty) {
      for (var element in drivers) {
        LatLng eachDriverActivePosition =
            LatLng(element.locationLatitude!, element.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId("driver${element.driverId!}"),
          position: eachDriverActivePosition,
          // icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }
    } else {
      for (ActiveNearbyAvailableDrivers eachDriver
          in GeoFireAssistant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition =
            LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId("driver" + eachDriver.driverId!),
          position: eachDriverActivePosition,
          // icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }
    }

    markersSet = driversMarkerSet;

    notifyListeners();
  }

}