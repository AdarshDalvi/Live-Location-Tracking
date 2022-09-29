import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_location_tracking/constants.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: LiveLocation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LiveLocation extends StatefulWidget {
  @override
  State<LiveLocation> createState() => LiveLocationState();
}

class LiveLocationState extends State<LiveLocation> {
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation= LatLng(19.0816525, 72.8365468);
  static const LatLng destination= LatLng(19.1247, 72.8374);

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  List<LatLng> polylineCoordinates =[];
  LocationData? currentLocation;


  @override
  void initState(){
    getPolyPoints();
    getCurrentLocation();
    super.initState();
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key, // Your Google Map Key
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude),
      );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
          (location) {
            currentLocation = location;
          },
        );
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen(
          (newLoc) {
            currentLocation = newLoc;
            googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          zoom: 18.5,
                          target: LatLng(
                            newLoc.latitude!,
                            newLoc.longitude!,
                          ),
                        ),
                      ),
                    );
            setState(() {});
    },
    );
  }

  

  @override
  Widget build(BuildContext context) {
    return currentLocation == null? Center(
      child: CircularProgressIndicator(color: Colors.red),
    ): Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: sourceLocation,
          zoom: 18
        ),
        mapType: MapType.normal,
        markers: {
          Marker(
            markerId: MarkerId("Poddar InterNational School"),
            icon: sourceIcon,
            position: sourceLocation
          ),
          Marker(
            markerId: MarkerId("Juhu Garden"),
            icon: destinationIcon,
            position: destination
          ),
          Marker(
            markerId: MarkerId("Live Marker"),
            icon: currentLocationIcon,
            position: LatLng(
              currentLocation!.latitude!,currentLocation!.longitude!
            )
          ),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId("Rasta"),
            points: polylineCoordinates,
            color: Colors.amber,
            width: 6
          ),
        },
        onMapCreated: (mapController) {
          _controller.complete(mapController);
        }
      )
      
    );
  }


}


