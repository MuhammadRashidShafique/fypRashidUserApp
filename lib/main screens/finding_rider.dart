import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../assistants/assistant_methods.dart';
import '../global/global.dart';
import '../models/active_nearby_available_drivers.dart';
import '../widgets/progress_dialog.dart';
import 'ride_screen.dart';

class FindingRiderScreen extends StatefulWidget {
  const FindingRiderScreen({super.key});

  @override
  State<FindingRiderScreen> createState() => _FindingRiderScreenState();
}

class _FindingRiderScreenState extends State<FindingRiderScreen> {
  double bottomPaddingOfMap = 0;
  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(24.860966, 66.990501),
    zoom: 15.4746,
  );
  Position? userCurrentPosition;
  String userName = "your Name";
  String userEmail = "your Email";
  Set<Polyline> polyLineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoOrdinates(
            userCurrentPosition!, context);
    print("this is your address = " + humanReadableAddress);

    if (userModelCurrentInfo != null) {
      userName = userModelCurrentInfo!.name!;
      userEmail = userModelCurrentInfo!.email!;
    }

    setState(() {
      _initialPosition = cameraPosition;
    });
  }

  @override
  void initState() {
    locateUserPosition();
    checkRideAccepted();
    super.initState();
  }

  void checkRideAccepted() {
    dynamic ref = FirebaseDatabase.instance
        .ref()
        .child("requestRides")
        .child(currentFirebaseUser!.uid)
        .onValue;

    ref.listen((event) {
      if (event.snapshot.value["user_id"] == currentFirebaseUser!.uid) {
        String status = event.snapshot.value["status"].toString();
        if (status == "accepted") {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RideScreen()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<dynamic>(
              stream: FirebaseDatabase.instance
                  .ref()
                  .child("requestRides")
                  .child(currentFirebaseUser!.uid)
                  .onValue,
              builder: (context, snapshot) {
                return _initialPosition == null
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : GoogleMap(
                        padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        zoomGesturesEnabled: true,
                        zoomControlsEnabled: true,
                        initialCameraPosition: _initialPosition,
                        markers: Set.from(markersSet),
                        circles: circlesSet,
                        onMapCreated: (GoogleMapController controller) {
                          _controllerGoogleMap.complete(controller);
                          newGoogleMapController = controller;
                          // Future.delayed(const Duration(milliseconds: 200), () {
                          //   controller.animateCamera(CameraUpdate.newLatLngBounds(
                          //       MapUtils.boundsFromLatLngList(
                          //           markersSet.map((loc) => loc.position).toList()),
                          //       1));
                          // });
                          blackThemeGoogleMap();

                          setState(() {
                            bottomPaddingOfMap = 240;
                          });
                        },
                      );
              }),
          Align(
            alignment: Alignment.center,
            child: ProgressDialogue(
              message: "Finding Rider for you...",
            ),
          )
        ],
      ),
    );
  }

  blackThemeGoogleMap() {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }



}
