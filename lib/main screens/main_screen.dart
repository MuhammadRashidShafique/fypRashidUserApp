import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:user_fyp/main%20screens/finding_rider.dart';
import 'package:user_fyp/main%20screens/search_places_screen.dart';
import 'package:user_fyp/main%20screens/select_nearest_active_driver_screen.dart';
import 'package:user_fyp/widgets/progress_dialog.dart';

import '../BBC LONDON/MapUtlis.dart';
import '../BBC LONDON/tracking button.dart';
import '../assistants/assistant_methods.dart';
import '../assistants/geofire_assistant.dart';
import '../global/global.dart';
import '../info handler/app_info.dart';
import '../main.dart';
import '../models/active_nearby_available_drivers.dart';
import '../widgets/my_drawer.dart';

class MainScreen extends StatefulWidget {


  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController passengerController = TextEditingController();
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(24.860966, 66.990501),
    zoom: 15.4746,
  );

  final ref = FirebaseDatabase.instance.ref('drivers');

  List<String> carTypeList = ["CAR AC", "Car Non-AC", "Bike"];
  String? selectedCarType;

  final user = FirebaseAuth.instance.currentUser;

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 280;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "your Name";
  String userEmail = "your Email";

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];

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

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
    LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
    CameraPosition(target: latLngPosition, zoom: 14);

    // newGoogleMapController!
    //     .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

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
    // initializeGeoFireListener();
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
    locateUserPosition();

    //saveRideRequestInformation();
    //createActiveNearByDriverIconMarker();
  }

  saveRideRequestInformation() {
    onlineNearByAvailableDriversList =
        GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }

  searchNearestOnlineDrivers() async {
    //no active driver available
    if (onlineNearByAvailableDriversList.length == 0) {
      //cancel/delete the RideRequest Information

      setState(() {
        polyLineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoOrdinatesList.clear();
      });

      Fluttertoast.showToast(
          msg:
          "No Online Nearest Driver Available. Search Again after some time, Restarting App Now.");

      Future.delayed(const Duration(milliseconds: 4000), () {
        MyApp.restartApp(context);
      });

      return;
    }

    //active driver available
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);

    Navigator.push(context,
        MaterialPageRoute(builder: (c) => SelectNearestActiveDriversScreen()));
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    for (int i = 0; i < onlineNearestDriversList.length; i++) {
      await ref
          .child(onlineNearestDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;
        dList.add(driverKeyInfo);
      });
    }
  }

  Map data = {};

  @override
  Widget build(BuildContext context) {
    final userLocationInfo = Provider.of<AppInfo>(context);

    return Scaffold(
      key: sKey,
      drawer: SizedBox(
        width: 265,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black,
          ),
          child: MyDrawer(
            name: userName,
            email: userEmail,
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<dynamic>(
              stream: FirebaseDatabase.instance
                  .ref()
                  .child('activeDrivers')
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Parse the updated marker data from the snapshot

                Map data = snapshot.data!.snapshot.value;

                List<ActiveNearbyAvailableDrivers> drivers = [];

                data.forEach((key, value) {
                  drivers.add(
                    ActiveNearbyAvailableDrivers(
                      driverId: key.toString(),
                      locationLatitude: value['latitude'],
                      locationLongitude: value['longitude'],
                    ),
                  );
                });

                userLocationInfo.displayActiveDriversOnUsersMap(drivers);

                // WidgetsBinding.instance.addPostFrameCallback((_) {
                //   displayActiveDriversOnUsersMap(drivers);

                // });

                // Rest of the code...

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
                  initialCameraPosition: _initialPosition!,
                  polylines: polyLineSet,
                  markers: Set.from(userLocationInfo.markersSet),
                  circles: circlesSet,
                  onMapCreated: (GoogleMapController controller) {
                    _controllerGoogleMap.complete(controller);
                    newGoogleMapController = controller;
                    Future.delayed(const Duration(milliseconds: 200), () {
                      controller.animateCamera(
                          CameraUpdate.newLatLngBounds(
                              MapUtils.boundsFromLatLngList(markersSet
                                  .map((loc) => loc.position)
                                  .toList()),
                              1));
                    });
                    blackThemeGoogleMap();

                    setState(() {
                      bottomPaddingOfMap = 240;
                    });

                    // Update the markers on the map after the map is created
                    // displayActiveDriversOnUsersMap(drivers);
                  },
                );
              }),

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
                  SystemNavigator.pop();
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
            bottom: -30,
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      //from
                      Row(
                        children: [
                          const Icon(
                            Icons.add_location_alt_outlined,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "From",
                                style:
                                TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Text(
                                "your current location",
                                // Provider.of<AppInfo>(context).userPickUpLocation != null
                                //     ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,24) + "..."
                                //     : "not getting address",
                                style:
                                TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10.0),

                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16.0),

                      //to
                      GestureDetector(
                        onTap: () async {
                          //go to search places screen
                          var responseFromSearchScreen = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => SearchPlacesScreen()));

                          if (responseFromSearchScreen == "obtainedDropoff") {
                            setState(() {
                              openNavigationDrawer = false;
                            });

                            //draw routes - draw polyline
                            await drawPolyLineFromOriginToDestination();
                          }
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_location_alt_outlined,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 12.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "To",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Text(
                                  // "where to go",
                                  userLocationInfo.userDropOffLocation != null
                                      ? userLocationInfo
                                      .userDropOffLocation!.locationName!
                                      : "Where to go?",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors
                                        .grey, // Set the color of the border
                                    width: 1.0, // Set the width of the border
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                child: TextFormField(
                                  controller: passengerController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Passengers',
                                    labelStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder
                                        .none, // Hide the default input border
                                    contentPadding: EdgeInsets.all(
                                        12.0), // Add padding to the input content
                                  ),
                                ),
                              )),
                          SizedBox(
                            width: 50,
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.6,
                            child: DropdownButton(
                              iconSize: 26,
                              dropdownColor: Colors.black,
                              hint: const Text(
                                "Choose Car Type",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                              value: selectedCarType,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedCarType = newValue.toString();
                                });
                              },
                              items: carTypeList.map((car) {
                                return DropdownMenuItem(
                                  value: car,
                                  child: Text(
                                    car,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      ElevatedButton(
                        onPressed: () async {
                          if (userLocationInfo.userDropOffLocation != null) {
                            if (passengerController.text.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Please enter number of passengers");
                              return;
                            }
                            else if (selectedCarType == null) {
                              Fluttertoast.showToast(
                                  msg: "Please select a ride type");
                              return;
                            } else if (
                            selectedCarType == "Bike" &&
                                int.parse(passengerController.text) != 1
                            ) {
                              Fluttertoast.showToast(
                                  msg: "Bike can only carry one passenger");
                              return;
                            } else if (selectedCarType == "CAR AC"  &&
                                (int.parse(passengerController.text) > 4 ||
                                    int.parse(passengerController.text) < 1)) {
                              Fluttertoast.showToast(
                                  msg: "Car AC can only carry 1-4 passengers");
                              return;
                            } else if (selectedCarType == "Car Non-AC" &&
                                (int.parse(passengerController.text) > 4 ||
                                    int.parse(passengerController.text) < 1)) {
                              Fluttertoast.showToast(
                                  msg:
                                  "Car non AC can only carry 1-4 passengers");
                              return;
                            }

                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  ProgressDialogue(
                                    message: "Please wait...",
                                  ),
                            );
                            DatabaseReference ref = FirebaseDatabase.instance
                                .ref("requestRides")
                                .child(currentFirebaseUser!.uid);

                            await ref.set({
                              "toLatitude": userLocationInfo
                                  .userDropOffLocation!.locationLatitude,
                              "toLongitute": userLocationInfo
                                  .userDropOffLocation!.locationLongitude,
                              "fromLatitude": userCurrentPosition!.latitude,
                              "fromLongitute": userCurrentPosition!.longitude,
                              "dropOffLocation": userLocationInfo
                                  .userDropOffLocation!.locationName,
                              "pickupLocation": userLocationInfo
                                  .userPickUpLocation!.locationName,
                              "status": "pending",
                              "user_id": currentFirebaseUser!.uid,
                              "passenger_name": userModelCurrentInfo!.name,
                              "passenger_phone":
                              userModelCurrentInfo!.phone.toString(),
                              "passenger_email": userModelCurrentInfo!.email,
                              "passenger_count": passengerController.text,
                              "car_type": selectedCarType,
                            }).then((value) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const FindingRiderScreen()));
                            });
                          } else {
                            Fluttertoast.showToast(
                                msg: "Please select destination location");
                          }

                          // if()

                          // saveRideRequestInformation();
                          // Navigator.push(
                          //     context, //SelectNearestActiveDriversScreen
                          //     MaterialPageRoute(
                          //         builder: (c) => TrackingButton()));
                          // if(Provider.of<AppInfo>(context, listen: false).userDropOffLocation != null)
                          // {
                          //   saveRideRequestInformation();
                          // }
                          // else
                          // {
                          //   Fluttertoast.showToast(msg: "Please select destination location");
                          // }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        child: const Text(
                          "Request a Ride",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialogue(
        message: "Please wait...",
      ),
    );

    var directionDetailsInfo =
    await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        originLatLng, destinationLatLng);

    Navigator.pop(context);

    print("These are points = ");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
    pPoints.decodePolyline(directionDetailsInfo.e_points!);

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

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

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
  }

  createActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
      createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
          imageConfiguration, "assets/images/car.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }
}
