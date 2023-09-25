import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_fyp/info%20handler/directions.dart';

import '../BBC LONDON/MapUtlis.dart';
import '../assistants/assistant_methods.dart';
import '../assistants/geofire_assistant.dart';
import '../global/global.dart';
import '../info handler/app_info.dart';
import '../models/active_nearby_available_drivers.dart';
import '../widgets/progress_dialog.dart';
import 'feedback_screen.dart';
import 'schedule_screen.dart';

class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;
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
  Map data = {};
  List<LatLng> pLineCoOrdinatesList = [];

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

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

  void checkRideAccepted() {
    dynamic ref = FirebaseDatabase.instance
        .ref()
        .child("requestRides")
        .child(currentFirebaseUser!.uid)
        .onValue;

    ref.listen((event) {
      if (event.snapshot.value["user_id"] == currentFirebaseUser!.uid) {
        String status = event.snapshot.value["status"].toString();
        if (status == "completed") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const FeedBackScreen()));
        } else if (status == "arrived") {
          drawPolyLineFromOriginToDestination(event.snapshot.value);
        }
      }
    });
  }

  @override
  void initState() {
    locateUserPosition();
    checkRideAccepted();
    super.initState();
  }

  void callNumber(String phoneNumber) async {
    String number = phoneNumber; //set the number here
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    final userLocationInfo = Provider.of<AppInfo>(context);
    return Scaffold(
      body: _initialPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder<dynamic>(
              stream: FirebaseDatabase.instance
                  .ref()
                  .child("requestRides")
                  .child(currentFirebaseUser!.uid)
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                data = snapshot.data.snapshot.value;

                return Stack(children: [
                  GoogleMap(
                    padding: EdgeInsets.only(bottom: bottomPaddingOfMap),

                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    initialCameraPosition: _initialPosition,
                    polylines: polyLineSet,
                    // markers: markers,
                    markers: Set.from(markersSet),
                    circles: circlesSet,
                    onMapCreated: (GoogleMapController controller) async {
                      _controllerGoogleMap.complete(controller);
                      newGoogleMapController = controller;
                      await drawPolyLineFromOriginToDestination(
                          snapshot.data.snapshot.value);
                      Future.delayed(const Duration(milliseconds: 200), () {
                        controller.animateCamera(CameraUpdate.newLatLngBounds(
                            MapUtils.boundsFromLatLngList(
                                markersSet.map((loc) => loc.position).toList()),
                            1));
                      });
                      blackThemeGoogleMap();

                      setState(() {
                        bottomPaddingOfMap = 240;
                      });
                      },
                  ),

                  //custom hamburger button for drawer
                  Positioned(
                    top: 30,
                    left: 14,
                    child: GestureDetector(
                      onTap: () {
                        if (openNavigationDrawer) {
                          sKey.currentState!.openDrawer();
                        } else {
                          //restart-refresh-minimize app progmatically
                          // SystemNavigator.pop();
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(
                          openNavigationDrawer ? Icons.menu : Icons.close,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),

                  //ui for searching location
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedSize(
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 120),
                        child: Container(
                          height: searchLocationContainerHeight,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 18),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),

                                //from
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Driver Name: ${data["driver_name"]}",
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                        Text(
                                          "Driver Phone: ${data["driver_phone"]}",
                                          style: const TextStyle(
                                              color: Colors.grey, fontSize: 14),
                                        ),
                                        Row(
                                          children: const [
                                            Text(
                                              "Reviews:",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                              size: 15,
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                              size: 15,
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                              size: 15,
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                              size: 15,
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: Colors.yellow,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    data["status"] == "accepted"
                                        ? const SizedBox.shrink()
                                        : const Spacer(),
                                    data["status"] == "accepted"
                                        ? const SizedBox.shrink()
                                        : GestureDetector(
                                            onTap: () {
                                              callNumber(data["driver_phone"]);
                                            },
                                            child: const Icon(Icons.call,
                                                color: Colors.green)),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
                                Container(
                                  height: 100,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[700],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: data["status"] == "accepted"
                                      ? const Center(
                                          child: Text(
                                            "Your Rider is on the way",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            const SizedBox(height: 15.0),
                                            Row(
                                              children: [
                                                const SizedBox(width: 10.0),
                                                const Icon(
                                                  Icons.location_on,
                                                  color: Colors.green,
                                                ),
                                                const SizedBox(width: 10.0),
                                                Expanded(
                                                  child: Text(
                                                    "from: ${data["pickupLocation"]}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5.0),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 40),
                                              child: Divider(
                                                color: Colors.white,
                                                height: 1,
                                              ),
                                            ),
                                            const SizedBox(height: 15.0),
                                            Row(
                                              children: [
                                                const SizedBox(width: 10.0),
                                                const Icon(
                                                  Icons.location_on,
                                                  color: Colors.green,
                                                ),
                                                const SizedBox(width: 10.0),
                                                Expanded(
                                                  child: Text(
                                                    "To: ${data["dropOffLocation"]}",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5.0),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 40),
                                              child: Divider(
                                                color: Colors.white,
                                                height: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                ]);
              }),
    );
  }

  Future<void> drawPolyLineFromOriginToDestination(Map data) async {
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition;
    if (data["status"] == "accepted") {
      destinationPosition = Directions(
          locationName: data["Driver Location"],
          locationLatitude: data["driver_lat"],
          locationLongitude: data["driver_lng"]);
    } else {
      destinationPosition =
          Provider.of<AppInfo>(context, listen: false).userDropOffLocation;
    }

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    List<ActiveNearbyAvailableDrivers> drivers = [];

    drivers.add(ActiveNearbyAvailableDrivers(
        driverId: "",
        locationLatitude: destinationLatLng.latitude,
        locationLongitude: destinationLatLng.longitude,
      ),);
    drivers.add(ActiveNearbyAvailableDrivers(
        driverId: "",
        locationLatitude: originLatLng.latitude,
        locationLongitude: originLatLng.longitude,
      ),);

    displayActiveDriversOnUsersMap(drivers);

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    pLineCoOrdinatesList.clear();

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoOrdinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.purpleAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    // setState(() {

    // });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
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

    setState(() {});
    // });
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
