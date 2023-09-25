import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as loc;
import 'package:user_fyp/models/BookingModel.dart';
import '../../assistants/assistant_methods.dart';
import '../../global/global.dart';

import 'dart:math' show cos, sqrt, asin;

import 'feedback_screen.dart';

class RideStartCarpool extends StatefulWidget {
  final BookingModel data;
  const RideStartCarpool({super.key, required this.data});

  @override
  State<RideStartCarpool> createState() => _RideStartCarpoolState();
}

class _RideStartCarpoolState extends State<RideStartCarpool> {
  GoogleMapController? newGoogleMapController;
  double searchLocationContainerHeight = 260;
  double bottomPaddingOfMap = 0;

  CameraPosition _initialPosition = CameraPosition(
    target: LatLng(24.860966, 66.990501),
    zoom: 15.4746,
  );

  loc.Location location = loc.Location();
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  bool isLoading = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  var originLatLong;
  var destLatLong;

  Set<Marker> _markers = {};
  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markersSet = {};
  Position? driverCurrentPosition;

  var driverObject;
  bool reachedPickupVar = false;

  @override
  void initState() {
    locateMyPosition();
    _loadMarkersFromDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : driverObject == null
                ? const Center(
                    child: Text(
                      'The Ride has not yet been started.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        flex: 6,
                        child: GoogleMap(
                          mapType: MapType.satellite,
                          myLocationEnabled: true,
                          zoomGesturesEnabled: true,
                          zoomControlsEnabled: true,
                          initialCameraPosition: _initialPosition,
                          polylines: polyLineSet,
                          markers: _markers,
                          onMapCreated: (GoogleMapController controller) async {
                            _controllerGoogleMap.complete(controller);
                            newGoogleMapController = controller;

                          },
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        driverObject["driver_name"],
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                      Text(
                                        driverObject["driver_phone"],
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                      Text(
                                        "Rs." +
                                            driverObject["farePrice"]
                                                .toString(),
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                      Text(
                                        "Seats Booked: " +
                                            driverObject["seatsBooked"]
                                                .toString(),
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                      Text(
                                        "Booking ID: " +
                                            driverObject["bookingID"]
                                                .toString(),
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      ),
                                      Text(
                                        "Ride Status: " +
                                            driverObject["status"]
                                                .toUpperCase(),
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 12),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            callNumber(
                                                driverObject["driver_phone"]);
                                          },
                                          icon: const Icon(Icons.call,
                                              color: Colors.blue),
                                          iconSize: 30),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 0,
                              ),
                              reachedPickupVar == false
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            reachedPickup(
                                                driverObject["bookingID"]);
                                          },
                                          child: Text("Reached Pickup - " +
                                              driverObject["selectedStop"],
                                            style: TextStyle(fontSize: 11), // Adjust the font size
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.teal,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text("ETA : Calculating..."),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ));
  }

  // 1
  Future<void> _loadMarkersFromDB() async {
    final DatabaseReference dataRef = FirebaseDatabase.instance
        .ref()
        .child('schedule')
        .child(widget.data.scheduleID)
        .child("route");
    final markersSet = Set<Marker>();
    dataRef.onValue.listen((event) async {
      DataSnapshot snapshot = event.snapshot;
      List<dynamic> dataList = snapshot.value as List<dynamic>;
      for (int index = 0; index < dataList.length; index++) {
        Map<dynamic, dynamic> dataMap =
            dataList[index] as Map<dynamic, dynamic>;

        double latitude = dataMap["latitude"];
        double longitude = dataMap["longitude"];
        String title = dataMap["title"].toString();

        Position cPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (index == 0) {
          originLatLong = LatLng(latitude, longitude);
        } else if (index == 1) {
          destLatLong = LatLng(latitude, longitude);
        }
        var item = Marker(
          markerId: MarkerId(title),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: title,
          ),
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            getMyPolyline(
              LatLng(cPosition.latitude, cPosition.longitude),
              LatLng(latitude, longitude),
            );
          },
        );
        markersSet.add(item);
      }

      setState(() {
        _markers = markersSet;
      });
      drawPolylineMarkers();
      fetchDriverDetails();
    });
  }

  void locateMyPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;
    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 16);
    newGoogleMapController
        ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void callNumber(String phoneNumber) async {
    String number = phoneNumber; //set the number here
    await FlutterPhoneDirectCaller.callNumber(number);
  }

  // 2
  void fetchDriverDetails() async {
    DatabaseEvent event = await FirebaseDatabase.instance
        .ref()
        .child("booking")
        .orderByChild("scheduleID")
        .equalTo(widget.data.scheduleID)
        .once();
    if (event.snapshot.value != null) {
      Map<Object?, Object?> reviews =
          event.snapshot.value as Map<Object?, Object?>;
      reviews.forEach((key, value) async {
        if (value != null) {
          Map<dynamic, dynamic> item = value as Map<dynamic, dynamic>;
          if (item["scheduleID"] == widget.data.scheduleID) {
            if (item["passenger_id"] == currentFirebaseUser?.uid.toString()) {
              if (item["status"] == "approved" ||
                  item["status"] == "Ride Started") {
                driverObject = item;
                if (item["passenger_status"] == "Reached Pickup" ||
                    item["passenger_status"] == "Picked Up") {
                  reachedPickupVar = true;
                } else {
                  reachedPickupVar = false;
                }
                EndRideOnDestination();
              }
            }
          }
        }
      });
    }
    setState(() {
      isLoading = false;
    });

    locateDriverLivePosition();
  }

  void locateDriverLivePosition() {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('activeRides')
        .child(driverObject["driver_id"]);

    // Listen to the database changes
    ref.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        // Clear the existing locations before updating
        Map<dynamic, dynamic> ridesData =
            dataSnapshot.value as Map<dynamic, dynamic>;
        Map<dynamic, dynamic> location =
            ridesData["location"] as Map<dynamic, dynamic>;

        double latitude = double.parse(location["latitude"].toString());
        double longitude = double.parse(location["longitude"].toString());
        LatLng driverLocation = LatLng(latitude, longitude);
        Marker driverMarker = Marker(
          markerId: const MarkerId("vehicleMarker"),
          infoWindow: InfoWindow(
              title: driverObject['driver_name'], snippet: "Vehicle"),
          position: driverLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
        setState(() {
          _markers.add(driverMarker);
        });
      }
    });
  }

  // 4
  Future<void> drawPolylineMarkers() async {
    polyLineSet.clear();
    pLineCoOrdinatesList.clear();

    var prevLatLng = originLatLong;
    var originLatLng = originLatLong;
    var destinationLatLng = destLatLong;

    for (int i = 2; i < _markers.length; i++) {
      Marker marker = _markers.elementAt(i);
      if (marker.markerId.value == "vehicleMarker") {
        continue;
      } else {
        var oPos = prevLatLng;
        var dPos = marker.position;

        var directionDetailsInfo =
            await AssistantMethods.obtainOriginToDestinationDirectionDetails(
                oPos, dPos);

        PolylinePoints pPoints = PolylinePoints();
        List<PointLatLng> decodedPolyLinePointsResultList =
            pPoints.decodePolyline(directionDetailsInfo!.e_points!);

        if (decodedPolyLinePointsResultList.isNotEmpty) {
          decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
            pLineCoOrdinatesList
                .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
          });
        }

        prevLatLng = dPos;
      }
    }

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            prevLatLng, destinationLatLng);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoOrdinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    setState(() {
      Polyline polyline = Polyline(
          color: Colors.green,
          polylineId: const PolylineId("RouteLine"),
          jointType: JointType.round,
          points: pLineCoOrdinatesList,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          width: 5);
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

    newGoogleMapController
        ?.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 90));
  }

  Future<void> getMyPolyline(originLatLng, destinationLatLng) async {
    polyLineSet.clear();
    pLineCoOrdinatesList.clear();

    if (reachedPickupVar == true) return;

    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    if (decodedPolyLinePointsResultList.isNotEmpty) {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoOrdinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    setState(() {
      Polyline polyline = Polyline(
          color: Colors.purpleAccent,
          polylineId: const PolylineId("RouteToPoint"),
          jointType: JointType.bevel,
          points: pLineCoOrdinatesList,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          width: 3);
      polyLineSet.add(polyline);
    });
  }

  void reachedPickup(bookingID) {
    polyLineSet.clear();
    pLineCoOrdinatesList.clear();
    drawPolylineMarkers();

    FirebaseDatabase.instance
        .ref()
        .child("booking")
        .child(bookingID)
        .update({"passenger_status": "Reached Pickup"});
    setState(() {
      reachedPickupVar = true;
    });
  }

  void EndRideOnDestination() {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('booking')
        .child(driverObject["bookingID"]);

    // Listen to the database changes
    ref.onValue.listen((event) {
      DataSnapshot dataSnapshot = event.snapshot;

      if (dataSnapshot.value != null) {
        // Clear the existing locations before updating
        Map<dynamic, dynamic> bookingData =
            dataSnapshot.value as Map<dynamic, dynamic>;

        var status = bookingData["status"].toString();
        if (status == "Completed" || status == "approved") {
          Fluttertoast.showToast(msg: "Ride Completed");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const FeedBackScreen()));
        }
      }
    });
  }
}
