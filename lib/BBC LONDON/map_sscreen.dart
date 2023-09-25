import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:flutter_uber_youtube/map_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user_fyp/BBC%20LONDON/MapUtlis.dart';

class MapScreen extends StatefulWidget {
  // final DetailsResult? startPosition;
  // final DetailsResult? endPosition;

  MapScreen({
    Key? key,

    // this.startPosition, this.endPosition
  }) : super(key: key);
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Set<Marker> markers = Set(); //markers for google map
  var mymarkers = [];
  late CameraPosition _initialPosition;
  static Position? position;
 
  LatLng loc1 = LatLng(27.6602292, 85.308027);
  LatLng loc2 = LatLng( 24.968399, 67.276137);

  addMarkers() async {
    mymarkers.add({
      "id": "loc1",
      "marker": Marker(
          markerId: MarkerId(loc1.toString()),
          position: loc1,
          icon: BitmapDescriptor.defaultMarker)
    });
  }
  // LatLng showLocation = LatLon()

  final Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _myCurrentLocationCameraPosition =
      CameraPosition(target: LatLng(position!.altitude, position!.longitude));
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initialPosition = CameraPosition(
      target: loc1,
      // LatLng(widget.startPosition!.geometry!.location!.lat!,
      //     widget.startPosition!.geometry!.location!.lng!),
      zoom: 14.4746,
    );
  }

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.black,
        points: polylineCoordinates,
        width: 5);
    polylines[id] = polyline;
    setState(() {});
  }

  // _getPolyline() async {
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       'AIzaSyDBorxMHcrLrPMvgzTDgEgLz9HA5UDuNY8',
  //       PointLatLng(widget.startPosition!.geometry!.location!.lat!,
  //           widget.startPosition!.geometry!.location!.lng!),
  //       PointLatLng(widget.endPosition!.geometry!.location!.lat!,
  //           widget.endPosition!.geometry!.location!.lng!),
  //       travelMode: TravelMode.driving);

  //   if (result.points.isNotEmpty) {
  //     result.points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //   }
  //   _addPolyLine();
  // }

  final ref = FirebaseDatabase.instance.ref('drivers');

  @override
  Widget build(BuildContext context) {
    Set<Marker> _markers = {
      Marker(markerId: const MarkerId('start'), position: loc1
          //  LatLng(widget.startPosition!.geometry!.location!.lat!,
          //     widget.startPosition!.geometry!.location!.lng!)

          ),
      Marker(markerId: const MarkerId('end'), position: loc2

          // LatLng(widget.endPosition!.geometry!.location!.lat!,
          //     widget.endPosition!.geometry!.location!.lng!)
          )
    };

    return Scaffold(
        body: Stack(children: [
      GoogleMap(
        polylines: Set<Polyline>.of(polylines.values),
        initialCameraPosition: _initialPosition,
        markers: Set.from(_markers),
        zoomGesturesEnabled: true,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        mapToolbarEnabled: true,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          Future.delayed(const Duration(milliseconds: 200), () {
            controller.animateCamera(CameraUpdate.newLatLngBounds(
                MapUtils.boundsFromLatLngList(
                    _markers.map((loc) => loc.position).toList()),
                1));
            // _getPolyline();
          });
        },
      ),
    ]));
  }
}
