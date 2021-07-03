import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tagcash/apps/buy_load/requests/map_tracking.dart';
import 'package:tagcash/apps/buy_load/rider/vehicle_list.dart';
import 'package:tagcash/apps/buy_load/rider/completed_deliveries.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/apps/buy_load/app_globals.dart' as globals;

class RidersScreen extends StatefulWidget {
  RidersScreen({Key key, this.title}) : super(key: key);
  final String title;


  @override
  _RidersState createState() => _RidersState();
}

class _RidersState extends State<RidersScreen> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize:20.0);
  var textValue = 'Active Status';
  List requestsList = new List();
  bool loaded = false;

  void _trackRider(request) {
    globals.clearTracking();
    globals.tracking_pickupLAT = request['from_lat'];
    globals.tracking_pickupLONG = request['from_lng'];
    globals.tracking_dropoffLAT = request['to_lat'];
    globals.tracking_dropoffLONG = request['to_lng'];

    print("HAHAHA");
    print(request['from_lat']);
    print(request['from_LNG']);
    Navigator.push(context, MaterialPageRoute(builder: (context) => MapTrackingScreen(request : request)));
  }

  void fetchRequests() async {
    /*setState(() {
      isLoading = true;
    });*/
    requestsList.clear();
    print('API Call: fetchRequests()');
    var apiBodyObj = {};
    apiBodyObj['access_token'] = AppConstants.accessToken;
    apiBodyObj['is_rider'] = 1;
    apiBodyObj['page_offset'] = 1;
    apiBodyObj['page_count'] = 100;
    await NetworkHelper.request("GoferBike/ListRequests", apiBodyObj).then((
        response) {
      List responseList = response['result'];
      setState(() {
        requestsList = responseList;
      });
    });
  }

  void fetchRiderOnOffStatus() async {
    /*setState(() {
      isLoading = true;
    });*/
    print('API Call: fetchRiderOnOffStatus()');
    var apiBodyObj = {};
    apiBodyObj['access_token'] = AppConstants.accessToken;
    await NetworkHelper.request("GoferBike/GetRiderOnOffStatus", apiBodyObj).then((
        response) {
      var status = response['rider_status'];
      setState(() {
        var a = (status == "offline") ? false : true;
        globals.active_status = a;
      });
    });
    loaded = true;
  }

  void switchRiderOnOffStatus(status) async {
    /*setState(() {
      isLoading = true;
    });*/
    print('API Call: switchRiderOnOffStatus()');
    var apiBodyObj = {};
    apiBodyObj['access_token'] = AppConstants.accessToken;
    apiBodyObj['status'] = status.toString();
    await NetworkHelper.request("GoferBike/SwitchRiderOnOffStatus", apiBodyObj).then((
        response) {
      var status = response['status'];
      if(status == "failed") {
        setState(() {
          globals.active_status = !globals.active_status;
        });
      }
      /*setState(() {
        var a = (status == "offline") ? false : true;
        globals.active_status = a;
      });*/
    });
    loaded = true;
  }

  void changeStatus(request_id, status) async {
    /*setState(() {
      isLoading = true;
    });*/
    print('API Call: changeStatus()');
    var apiBodyObj = {};
    apiBodyObj['access_token'] = AppConstants.accessToken;
    apiBodyObj['request_id'] = request_id;
    apiBodyObj['update_status_to'] = status;
    await NetworkHelper.request("GoferBike/ChangeStatus", apiBodyObj).then((
        response) {
      var status = response['status'];
      var error = response['error'];

      if(status.toString() == "success") {
        fetchRequests();
        showInSnackBar("Request accepted");
      }
      else if(status.toString() == "failed") {
        if(error == "rider_should_have_minimum_100_php_in_wallet") {
          showInSnackBar("Wallet balance is less than 100 pesos.");
        } else showInSnackBar("An error occured.");
      }
      /*setState(() {
        var a = (status == "offline") ? false : true;
        globals.active_status = a;
      });*/
    });
    loaded = true;
  }


  void toggleSwitch(bool value) {
    if(globals.active_status == false)
    {
      setState(() {
        globals.active_status = true;
        //textValue = 'Switch Button is ON';
      });
      switchRiderOnOffStatus("online");
      print('Switch Button is ON');
    }
    else
    {
      setState(() {
        globals.active_status = false;
        //textValue = 'Switch Button is OFF';
      });
      switchRiderOnOffStatus("offline");
    }
  }

  Future _confirmAcceptBooking(BuildContext context, request_id) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('Proceed with booking?'),
          content: const Text(
              'Accept selected booking?.'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('Proceed'),
              onPressed: () {
                changeStatus(request_id.toString(), "accept");
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFFe44933),
        content: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    (loaded == false) ? fetchRequests() : 0;
    (loaded == false) ? fetchRiderOnOffStatus() : 0;

    final requestCard = Card(

      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: requestsList == null ? 0 : requestsList.length,
              itemBuilder: (BuildContext context, int i) =>
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: <Widget>[

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  requestsList[i]["pickup_address"],
                                  style: TextStyle(fontSize: 19),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      requestsList[i]["request_created"],
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                    Material(
                                      elevation: 5.0,
                                      borderRadius: BorderRadius.circular(30.0),
                                      color: Colors.white,
                                      child: MaterialButton(
                                        minWidth: MediaQuery
                                            .of(context)
                                            .size
                                            .width *.3,
                                        onPressed: (){
                                          //Navigator.push(context, MaterialPageRoute(builder: (context) => RequestsScreen()));
                                        },
                                        child: Text(
                                          requestsList[i]["status"],
                                          style: TextStyle(fontSize: 15, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ],
                                )

                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
            )
            
          ],
        ),
      ),
    );

    final regUnregButton = Material(
        color: Colors.transparent,
        shape: CircleBorder(
            side: BorderSide(color: Colors.black38)
        ),
        child: IconButton(
          iconSize: 50,
          color: Colors.orangeAccent,
          icon: Icon(Icons.directions_car),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleListScreen()));
          },
        )
    );

    final completedDeliveriesButton = Material(
        color: Colors.transparent,
        shape: CircleBorder(
            side: BorderSide(color: Colors.black38)
        ),
        child: IconButton(
          iconSize: 50,
          color: Colors.orangeAccent,
          icon: Icon(Icons.assignment_turned_in),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteDeliveriesScreen()));
          },
        )
    );

    final declineRequestButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.white,
      child: MaterialButton(
        minWidth: MediaQuery
            .of(context)
            .size
            .width *.1,
        onPressed: (){
          Navigator.of(context).pop();
        },
        child: Icon(Icons.close)
      ),
    );


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
                        _confirmAcceptBooking(context, request['id']);
                      },
                      child: Text("Accept Booking",
                      textAlign: TextAlign.center,
                      style: style.copyWith(color: Colors.white70, fontSize: 17)),
                      ),
                    )


                      : SizedBox(width:0),
                  SizedBox(width: 15.0),
                  declineRequestButton,
                ],
              )
            ],
          );
        },
      );
    }

    void performStatusCode(request) {
      if(request['status_code'] == 1)
        _showRequestDetailsDialog(request);
      else if(request['status_code'] == 2)
        _trackRider(request);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
          title: Text("Rider Homepage", style: TextStyle(color: Colors.black),),
          centerTitle: true,
        ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Padding(
                padding: const EdgeInsets.all(0.0),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: requestsList == null ? 0 : requestsList.length,
                  itemBuilder: (BuildContext context, int i) =>
                      Card(
                        child: InkWell(
                          onTap: () {
                            performStatusCode(requestsList[i]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              children: <Widget>[

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "[" + requestsList[i]["distance"].toStringAsFixed(1) + "km] " + requestsList[i]["pickup_address"] + " - " + requestsList[i]['delivery_address'],
                                        style: TextStyle(fontSize: 19),
                                        overflow: TextOverflow.fade,
                                        maxLines: 1,
                                        softWrap: false,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            requestsList[i]['time_diff']['days_ago'].toString() + "d " + requestsList[i]['time_diff']['hours_ago'].toString() + "h ago" ,
                                            style: TextStyle(fontSize: 16, color: Colors.grey),
                                          ),
                                          Material(
                                            elevation: 5.0,
                                            borderRadius: BorderRadius.circular(30.0),
                                            color: Colors.white,
                                            child: MaterialButton(
                                              minWidth: MediaQuery
                                                  .of(context)
                                                  .size
                                                  .width *.1,
                                              onPressed: (){
                                              },
                                              child: Text(
                                                requestsList[i]["status"],
                                                style: TextStyle(fontSize: 15, color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )

                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                )
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(textValue),
                            SizedBox(width: 20,),
                            Transform.scale(
                                scale: 1.5,
                                child: Switch(
                                  onChanged: toggleSwitch,
                                  value: globals.active_status,
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.redAccent,
                                )
                            ),
                          ],
                        ),
                        regUnregButton,
                        completedDeliveriesButton,
                      ],
                    )
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
