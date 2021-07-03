import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/apps/buy_load/request_screen_new.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class RequestsScreen extends StatefulWidget {
  RequestsScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<RequestsScreen> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize:20.0);
  List requestsList = new List();
  bool loaded = false;

  void fetchRequests() async {
    /*setState(() {
      isLoading = true;
    });*/
    print('API Call: fetchRequests()');
    var apiBodyObj = {};
    apiBodyObj['access_token'] = AppConstants.accessToken;
    apiBodyObj['is_rider'] = 0;
    apiBodyObj['page_offset'] = 1;
    apiBodyObj['page_count'] = 100;
    await NetworkHelper.request("GoferBike/ListRequests", apiBodyObj).then((
        response) {
      List responseList = response['result'];
      setState(() {
        requestsList = responseList;
      });

    });

    loaded = true;
  }



  @override
  Widget build(BuildContext context) {

    // ignore: unnecessary_statements
    (loaded == false) ? fetchRequests() : 0;

    final newButton = FloatingActionButton(
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewRequestsScreen()));
      },
      child: Icon(Icons.add),
      mini: true,
      backgroundColor: Colors.green,
    );
    List<Widget> buildActions() {
      return <Widget>[
        newButton
      ];
    };

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
                          Text(request['distance'].toString(), style: TextStyle(color: Colors.black87, fontSize: 14),),
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
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
          title: Text("Home", style: TextStyle(color: Colors.black),),
          centerTitle: true,
          actions: buildActions(),
        ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: requestsList == null ? 0 : requestsList.length,
            itemBuilder: (BuildContext context, int i) =>
              Card(
                child: InkWell(
                  onTap: () {
                    _showRequestDetailsDialog(requestsList[i]);
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
                              requestsList[i]["pickup_address"].toString(),
                              style: TextStyle(fontSize: 19),
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  requestsList[i]["request_created"].toString(),
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
                                    },
                                    child: Text(
                                      requestsList[i]["status"].toString(),
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
      ),
    );
  }
}
