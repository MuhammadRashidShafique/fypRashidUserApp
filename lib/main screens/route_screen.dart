import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';

import '../assistants/assistant_methods.dart';

import 'dart:math' as math;

class ViewRouteScreen extends StatefulWidget {
  const ViewRouteScreen({Key? key, required this.scheduleID}) : super(key: key);

  final String scheduleID; // Declare the scheduleData property

  @override
  State<ViewRouteScreen> createState() => ViewRouteScreenState();
}

class ViewRouteScreenState extends State<ViewRouteScreen> {
  GoogleMapController? newGoogleMapController;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  Set<Marker> _markers = {};

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  int currentPoint = 1;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(24.860966, 66.990501),
    zoom: 15.4746,
  );

  Position? driverCurrentPosition;
  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  var originLatLong;
  var destLatLong;
  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Travel Route"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            polylines: polyLineSet,
            markers: _markers, // Add this line to pass the markers to the map
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              // Add your own map customizations
              locateDriverPosition();
              _loadMarkersFromDB();
            },
          ),

        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 26), // Provide some spacing between the buttons
              FloatingActionButton(
                onPressed:
                drawPolylineMarkers, // Call the function to clear markers and reset
                child: Icon(Icons.refresh),
                tooltip: 'Clear Route',
              ),
            ],
          ),
        ],
      ),
    );
  }

  _getDistance(latD, lngD, latO, lngO) async {
    // Haversine formula, which takes into account the Earth's curvature
    const R = 6371; // Radius of the earth in km
    var d = latD - latO;
    var lo = lngD - lngO;
    var dLat = _toRadians(d);
    var dLon = _toRadians(lo);
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latD)) *
            math.cos(_toRadians(latO)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var distance = R * c; // Distance in km
    return distance;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  Future<void> _loadMarkersFromDB() async {
    final DatabaseReference dataRef = FirebaseDatabase.instance
        .ref()
        .child('schedule')
        .child(widget.scheduleID)
        .child("route");
    final markersSet = Set<Marker>();
    dataRef.onValue.listen((event) async {
      DataSnapshot snapshot = event.snapshot;
      List<dynamic> dataList = snapshot.value as List<dynamic>;
      for (int index = 0; index < dataList.length; index++) {
        Map<dynamic, dynamic> dataMap = dataList[index] as Map<dynamic, dynamic>;

        double latitude = dataMap["latitude"];
        double longitude = dataMap["longitude"];
        String title = dataMap["title"].toString();

        Position cPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        var distanceFromMyPosition = await _getDistance(
          latitude,
          longitude,
          cPosition.latitude,
          cPosition.longitude,
        );
        var distanceTotal = distanceFromMyPosition != 0.0 ? distanceFromMyPosition : 0;

        if (index == 0) {
          originLatLong = LatLng(latitude, longitude);
        }
        else if (index == 1){
          destLatLong = LatLng(latitude, longitude);
        }
        var item = Marker(
          markerId: MarkerId(title),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: title,
            snippet: "Distance: ${distanceTotal.toStringAsFixed(2)} Km",
          ),
          anchor: const Offset(0.5, 0.5),
          onTap: () {
            Fluttertoast.showToast(msg: "Getting Directions.");
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
    });
  }

  Future<void> getMyPolyline(originLatLng,destinationLatLng) async {
    polyLineSet.clear();
    pLineCoOrdinatesList.clear();

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
        width: 3
      );
      polyLineSet.add(polyline);
    });
  }

  Future<void> drawPolylineMarkers() async {
    polyLineSet.clear();
    pLineCoOrdinatesList.clear();

    var prevLatLng = originLatLong;
    var originLatLng = originLatLong;
    var destinationLatLng = destLatLong;

    for (int i = 2; i < _markers.length; i++) {
      Marker marker = _markers.elementAt(i);
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

      prevLatLng = dPos; // Update the previous LatLng to the current marker's position
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
          color: Colors.red,
          polylineId: const PolylineId("RouteLine"),
          jointType: JointType.round,
          points: pLineCoOrdinatesList,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,
          width: 4);

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
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 90));
  }


  void locateDriverPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    driverCurrentPosition = cPosition;
    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 16);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
}
