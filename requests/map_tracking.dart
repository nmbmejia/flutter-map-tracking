import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/components/loading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tagcash/apps/buy_load/request_screen_new.dart';
import 'package:tagcash/apps/buy_load/app_globals.dart' as globals;
import 'package:geocoder/geocoder.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:dio/dio.dart';



class MapTrackingScreen extends StatefulWidget {
  MapTrackingScreen({Key key, this.title, @required this.request}) : super(key: key);
  final String title;
  final request;

  @override
  _MapTrackingState createState() => _MapTrackingState();


}


class _MapTrackingState extends State<MapTrackingScreen> {
  final String apiKey = "AIzaSyC-oNp08gOKUppWwwyB29yINn79cNGxdl0";
  bool isLoading = true;
  bool isStopped = false; //global


  bool findMyLocation = false;
  bool initialized = false;
  GoogleMapController mapController;
  Location _location = Location();

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize:20.0);

  double start_lat = globals.tracking_pickupLAT;
  double start_long = globals.tracking_pickupLONG;
  double end_lat = globals.tracking_dropoffLAT;
  double end_long = globals.tracking_dropoffLONG;
  LatLng _initialcameraposition = LatLng(0,0);

  double current_lat = 0.0;
  double current_long = 0.0;

  double remainingDistance = 0.0;
  String remainingDistanceTitle = "";

  String estimatedTime = "";

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  _initialize() {
    markers.clear();
    _initialcameraposition = LatLng(start_lat, start_long);

    //MARKERS
    Marker currentLocationMarker = Marker(
      markerId: MarkerId('0'),
      position: LatLng(
        0.0,
        0.0,
      ),
      infoWindow: InfoWindow(
        title: 'CURRENT LOCATION',
        snippet: "TEST1",
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    // Destination Location Marker
    Marker pickupMarker = Marker(
      markerId: MarkerId('1'),
      position: LatLng(
        start_lat,
        start_long,
      ),
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: "TEST2",
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    // Destination Location Marker
    Marker dropOffMarker = Marker(
      markerId: MarkerId('2'),
      position: LatLng(
        end_lat,
        end_long,
      ),
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: "TEST2",
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );

    setState(() {
      markers[MarkerId('0')] = currentLocationMarker;
      markers[MarkerId('1')] = pickupMarker;
      markers[MarkerId('2')] = dropOffMarker;
    });

    getCurrentLocation();

    initialized = true;
  }


  getCurrentLocation() {
    polylines.clear();
    polylineCoordinates.clear();

    this._getLocation().then((l) {
      current_lat = l.latitude;
      current_long = l.longitude;
      findMyLocation = true;

      Marker locationMarker = Marker(
        markerId: MarkerId('0'),
        position: LatLng(
          l.latitude,
          l.longitude,
        ),

        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      );

      setState(() {
        markers[MarkerId('0')] = locationMarker;
      });

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(l.latitude, l.longitude),zoom: 15),
        ),
      );

      getEstimateTime(l.latitude, l.longitude, start_lat, start_long);
      _createPolylines(l.latitude, l.longitude, start_lat, start_long);
    });
  }

  getEstimateTime(start_lat, start_long, dest_lat, dest_long) async {
    Dio dio = new Dio();
    Response response = await dio.get("https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins="+ start_lat.toString() + ","+ start_long.toString() +"&destinations="+ dest_lat.toString() +", "+ dest_long.toString() + "&key="+ apiKey +"");
    //response.data['rows']       [{elements: [{distance: {text: 0.2 mi, value: 312}, duration: {text: 1 min, value: 57}, status: OK}]}]
    print(response.data['rows'][0]['elements'][0]['duration']['text'].toString());
    setState(() {
      estimatedTime = response.data['rows'][0]['elements'][0]['duration']['text'].toString();
    });
    isLoading = false;


    //repeat
    Future.delayed(const Duration(milliseconds: 5000), () {
      getCurrentLocation();
    });


    //return response.data.rows;
  }


  //POLYLINES

  PolylinePoints polylinePoints;

  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  _createPolylines(start_lat, start_long, dest_lat, dest_long) async {
    remainingDistance = 0.0;
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

    //DISTANCE

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      remainingDistance += _coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }

    setState(() {
      remainingDistanceTitle = remainingDistance.toStringAsFixed(2);
    });
    //globals.totalDistance = _placeDistance;
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

  Future<LocationData> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await _location.getLocation();
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
    return currentLocation;
  }


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _showRequestDetailsDialog(request) async {
    print(request.toString());
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height:15.0),
                    Divider(height: 1, thickness: 1),
                    SizedBox(height:15.0),
                    Text("PICKUP FROM", style: TextStyle(color: Colors.orange),),
                    SizedBox(height:15.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("USERNAME", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),),
                        Text(request['pickup_username'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ],
                    ),
                    SizedBox(height:5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("ADDRESS", style: TextStyle(color: Colors.grey, fontSize: 14),),
                        Expanded(
                            child:
                            Text(request['pickup_address'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14),)
                        ),
                      ],
                    ),
                    SizedBox(height:5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("CONTACT", style: TextStyle(color: Colors.grey, fontSize: 14),),
                        Text(request['pickup_contact_number'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ],
                    ),

                    SizedBox(height:15.0),
                    Divider(height: 1, thickness: 1),
                    SizedBox(height:15.0),
                    Text("DELIVER TO", style: TextStyle(color: Colors.orange),),
                    SizedBox(height:15.0),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("USERNAME", style: TextStyle(color: Colors.grey, fontSize: 14),),
                        Text(request['delivery_username'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ],
                    ),
                    SizedBox(height:5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("ADDRESS", style: TextStyle(color: Colors.grey, fontSize: 14),),
                        Text(request['delivery_address'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ],
                    ),
                    SizedBox(height:5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("CONTACT", style: TextStyle(color: Colors.grey, fontSize: 14),),
                        Text(request['delivery_contact_number'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ],
                    ),

                    SizedBox(height:15.0),
                    Divider(height: 1, thickness: 1),
                    SizedBox(height:15.0),
                    Text("OTHERS", style: TextStyle(color: Colors.orange),),
                    SizedBox(height:15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("CATEGORY", style: TextStyle(color: Colors.grey, fontSize: 14),),
                        Text(request['category'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ],
                    ),
                    SizedBox(height:5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("NOTES", style: TextStyle(color: Colors.grey, fontSize: 14),),
                        Text(request['notes'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ],
                    ),
                    SizedBox(height:5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("AMOUNT", style: TextStyle(color: Colors.grey, fontSize: 14),),
                        Text(request['amount'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ],
                    ),
                    SizedBox(height:5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("REQUIRED ID", style: TextStyle(color: Colors.grey, fontSize: 14),),
                        Text((request['required_id_status'].toString() == "1") ? "YES" : "NO", style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ],
                    ),
                    SizedBox(height:15.0),
                    Divider(height: 1, thickness: 1),
                    SizedBox(height:15.0),
                    Text("TOTALS", style: TextStyle(color: Colors.orange),),
                    SizedBox(height:15.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("DISTANCE", style: TextStyle(color: Colors.grey, fontSize: 14),),
                        Text(request['distance'].toString() + "km", style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ],
                    ),
                    SizedBox(height:5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("PAYABLES", style: TextStyle(color: Colors.grey, fontSize: 14),),
                        Text(request['amount'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14),),
                      ],
                    ),
                    SizedBox(height:50.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(request['request_created'].toString() + " - ", style: TextStyle(color: Colors.grey, fontSize: 12),),
                        Text(request['time_diff']['days_ago'].toString() + "d " + request['time_diff']['hours_ago'].toString() + "h " + request['time_diff']['mins_ago'].toString() + "m ago", style: TextStyle(color: Colors.grey, fontSize: 12),),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (request['status_code'].toString() == "1") ?


                Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.green,
                  child: MaterialButton(
                    minWidth: MediaQuery
                        .of(context)
                        .size
                        .width *.2,
                    onPressed: (){
                      Navigator.of(context).pop();
                      //_confirmAcceptBooking(context, request['id']);
                    },
                    child: Text("Accept Booking",
                        textAlign: TextAlign.center,
                        style: style.copyWith(color: Colors.white70, fontSize: 17)),
                  ),
                )


                    : SizedBox(width:0),
                SizedBox(width: 15.0),
                //declineRequestButton,
              ],
            )
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    if(isStopped == false) isStopped = true;
    (!initialized) ? _initialize() : "";

    final callButton = Material(
        color: Colors.transparent,
        shape: CircleBorder(
            side: BorderSide(color: Colors.black38)
        ),
        child: IconButton(
          iconSize: 40,
          color: Colors.green,
          icon: Icon(Icons.call),
          onPressed: () {
            launch("tel:"+ widget.request['pickup_contact_number'].toString() +"");
          },
        )
    );

    final textButton = Material(
        color: Colors.transparent,
        shape: CircleBorder(
            side: BorderSide(color: Colors.black38)
        ),
        child: IconButton(
          iconSize: 40,
          color: Colors.blue,
          icon: Icon(Icons.sms),
          onPressed: () {
            launch("sms:"+ widget.request['pickup_contact_number'].toString() +"");
          },
        )
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.home),
          backgroundColor: Colors.white,
          title: Text("Track your delivery", style: TextStyle(color: Colors.black),),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              polylines: Set<Polyline>.of(polylines.values),
              initialCameraPosition: CameraPosition(target: _initialcameraposition,zoom: 13),
              markers: Set<Marker>.of(markers.values),
              //onCameraMove: _onCameraMove,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white30),
                  child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(estimatedTime, style: TextStyle(color: Colors.black54, fontSize: 35, fontWeight: FontWeight.bold),),
                          Text("You are " + remainingDistance.toStringAsFixed(1) + "km away from waypoint", style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.normal),),
                          SizedBox(height: 10,),
                          Text("Order ID" + widget.request['id'].toString() + " · Paid via Card", style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.normal),),
                          SizedBox(height: 10,),
                          GestureDetector(
                              child: Text("More Details", style: TextStyle(color: Colors.blue, fontSize: 12)),
                              onTap: () {
                                _showRequestDetailsDialog(widget.request);
                              }
                          ),
                          SizedBox(height: 20,),

                          Divider(color: Colors.grey, thickness: 1.0, height: 1.0),

                          SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Image.network("https://www.shareicon.net/data/512x512/2016/05/24/770137_man_512x512.png",scale: 7,),
                                  Text(widget.request['pickup_username'].toString(), style: TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.normal),),
                                  Image.network("https://www.pngkey.com/png/full/104-1046461_parent-directory-five-star-rating-blue.png", scale: 9),
                                ],
                              ),
                              Column(
                                children: [
                                  callButton,
                                  SizedBox(height:15),
                                  Text("Call", style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.normal),),
                                ],
                              ),
                              Column(
                                children: [
                                  textButton,
                                  SizedBox(height:15),
                                  Text("Text", style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.normal),),
                                ],
                              ),
                            ],
                          )
                        ],
                      )
                  ),
                ),
              ),
            ),
            isLoading ? Center(child: Loading()) : SizedBox(),
          ],
        ),
      ),
    );
  }
}
