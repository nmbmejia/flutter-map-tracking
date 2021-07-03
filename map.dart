import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tagcash/apps/buy_load/request_screen_new.dart';
import 'package:tagcash/apps/buy_load/app_globals.dart' as globals;
import 'package:geocoder/geocoder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:math' show cos, sqrt, asin;


class MapScreen extends StatefulWidget {
  MapScreen({Key key, this.title, @optionalTypeArgs this.addressType}) : super(key: key);
  final String title;
  String addressType = "";

  @override
  _MapState createState() => _MapState();
}


class _MapState extends State<MapScreen> {
  bool findMyLocation = false;
  double centeredLat = 0.0;
  double centeredLong = 0.0;
  String centeredAddress = "";
  String _placeDistance = "";

  Location _location = Location();
  GoogleMapController mapController;
  final Set<Marker> _markers = {};
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize:20.0);
  LatLng _initialcameraposition = LatLng(20.5937, 78.9629);

  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};


  _createPolylines(start_lat, start_long, dest_lat, dest_long) async {
    polylinePoints = PolylinePoints();


    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyC-oNp08gOKUppWwwyB29yINn79cNGxdl0", // Google Maps API Key
      PointLatLng(start_lat, start_long),
      PointLatLng(dest_lat, dest_long),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    setState(() {
      polylines[id] = polyline;
    });

    //Distance calculation part
    double totalDistance = 0.0;

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += _coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }

    setState(() {
      _placeDistance = totalDistance.toStringAsFixed(2);
    });
    globals.totalDistance = totalDistance.toStringAsFixed(2);
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<List<Address>> _getAddress(double lat, double lang) async {
    final coordinates = new Coordinates(lat, lang);
    List<Address> add =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _location.onLocationChanged.listen((l) {
      if(!findMyLocation) {
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),
          ),
        );
        findMyLocation = true;
      }
    });
  }

  void _onCameraMove(CameraPosition position) {
    centeredLat = position.target.latitude;
    centeredLong = position.target.longitude;
  }

  void _onCameraIdle() {
    print("CENTERED LAT: " + centeredLat.toString());
    print("CENTERED LONG: " + centeredLong.toString());

    //Gets the actual address
    _getAddress(centeredLat, centeredLong)
        .then((value) {
          print ("CURRENT ADDRESS: " + "${value.first.addressLine}");
      setState(() {
        centeredAddress = "${value.first.addressLine}";
      });
    });

    //Create polyline for routing
    if(widget.addressType == "receiver" && globals.delivery_recipientAddress != "") {
      print("FIRST");

      polylines.clear();
      polylineCoordinates.clear();
      _placeDistance = "";
      _createPolylines(globals.delivery_recipientAddressLAT, globals.delivery_recipientAddressLONG, centeredLat, centeredLong);
    }
    else if(widget.addressType == "recipient" && globals.delivery_receiverAddress != "") {
      print("SECOND");
      polylines.clear();
      polylineCoordinates.clear();
      _placeDistance = "";
      _createPolylines(centeredLat, centeredLong, globals.delivery_receiverAddressLAT, globals.delivery_receiverAddressLONG);
    }


  }


  @override
  Widget build(BuildContext context) {

    final centerMarker = Align(
      alignment: Alignment.center,
      child: new Icon(Icons.person_pin_circle, size: 50.0, color: Colors.orange,),

    );

    final setLocationButton = Align(
      alignment: Alignment.bottomCenter,
      child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(30.0),
          color: Colors.white,
          child: MaterialButton(
            minWidth: MediaQuery
                .of(context)
                .size
                .width * .4,
            //onPressed: (){},
            child: Text("SET LOCATION",
                textAlign: TextAlign.center,
                style: style.copyWith(color: Colors.blueGrey)),
          ),
        ),
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Column(
            children: <Widget>[
              Text("Choose location", style: TextStyle(color: Colors.black),),
              Visibility(
                visible: _placeDistance == null ? false : true,
                child: Text('$_placeDistance km distance', style: TextStyle(color: Colors.black45, fontSize: 15.0),),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.done, color: Colors.black,),
              onPressed: () {
                if(widget.addressType == "receiver") {
                  globals.delivery_receiverAddress = centeredAddress;
                  globals.delivery_receiverAddressLAT = centeredLat;
                  globals.delivery_receiverAddressLONG = centeredLong;
                }
                if(widget.addressType == "recipient") {
                  globals.delivery_recipientAddress = centeredAddress;
                  globals.delivery_recipientAddressLAT = centeredLat;
                  globals.delivery_recipientAddressLONG = centeredLong;
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              onCameraIdle: _onCameraIdle,
              polylines: Set<Polyline>.of(polylines.values),
              initialCameraPosition: CameraPosition(target: _initialcameraposition),
              //markers: _markers,
              //onCameraMove: _onCameraMove,
            ),
            centerMarker,
          ],
        ),
      ),
    );
  }
}
