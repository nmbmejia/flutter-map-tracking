import 'package:flutter/material.dart';
import 'package:tagcash/apps/buy_load/models/AddressSearch.dart';
import 'package:tagcash/apps/buy_load/models/place_service.dart';
import 'package:tagcash/apps/buy_load/requests/looking_for_riders.dart';
import 'package:tagcash/apps/buy_load/app_globals.dart' as globals;
import 'package:tagcash/apps/buy_load/search_dropoff.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;
import 'package:tagcash/models/user_data.dart';
import 'package:tagcash/providers/user_provider.dart';
import 'map.dart';
import 'dart:convert';


class NewRequestsScreen extends StatefulWidget {
  NewRequestsScreen({Key key, this.title, @optionalTypeArgs this.addressType, @optionalTypeArgs this.addressData}) : super(key: key);
  //final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;
  String addressData = "";
  String addressType = "";


  @override
  _NewRequestsState createState() => _NewRequestsState();
}




class _NewRequestsState extends State<NewRequestsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize:20.0);
  final _controller = TextEditingController();

  TextEditingController recipientAddressController = TextEditingController();
  TextEditingController receiverAddressController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();

  TextEditingController receiverDetailAddress = TextEditingController();
  TextEditingController receiverDetailID = TextEditingController();
  TextEditingController receiverDetailNumber = TextEditingController();

  TextEditingController itemCategory = TextEditingController();
  TextEditingController itemWeight = TextEditingController();

  TextEditingController additionalInstructions = TextEditingController();

  String _streetNumber = '';
  String _street = '';
  String _city = '';
  String _zipCode = '';
  String totalDistance = "";
  String totalFee = "";
  bool _isFavorite = false;
  bool _isIdRequired = false;


  Future _confirmBooking(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('Proceed with booking?'),
          content: const Text(
              'Please confirm your booking.'),
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
                newRequest(context);
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


  void newRequest(BuildContext context) async {
    /*setState(() {
      isLoading = true;
    });*/
    bool noError = false;
    if(recipientAddressController.text == "") {
      showInSnackBar("Recipient address cannot be blank");
      noError = true;
    }
    else if(receiverAddressController.text == "") {
      showInSnackBar("Receiver address cannot be blank");
      noError = true;
    }
    else if(receiverDetailAddress.text == "" || receiverDetailID.text == "" || receiverDetailNumber.text == "") {
      showInSnackBar("Fields in Receiver details cannot be blank");
      noError = true;
    }
    else if(itemCategory.text == "" || itemWeight.text == "") {
      showInSnackBar("Fields in Item details cannot be blank");
      noError = true;
    }
    else if(recipientAddressController.text == receiverAddressController.text) {
      showInSnackBar("Receipent and Receiver address cannot be the same");
      noError = true;
    }

    if(!noError) {
      print('API Call: newRequest()');
      var apiBodyObj = {};
      apiBodyObj['access_token'] = AppConstants.accessToken;
      apiBodyObj['pickup_username'] = "143400";
      apiBodyObj['pickup_address'] = recipientAddressController.text;
      apiBodyObj['pickup_contact_number'] = contactNumberController.text;
      apiBodyObj['from_lat'] = globals.delivery_recipientAddressLAT;
      apiBodyObj['from_lng'] = globals.delivery_recipientAddressLONG;
      apiBodyObj['delivery_username'] = "143400";
      apiBodyObj['delivery_address'] = receiverDetailAddress.text;
      apiBodyObj['delivery_contact_number'] = receiverDetailNumber.text;
      apiBodyObj['to_lat'] = globals.delivery_receiverAddressLAT;
      apiBodyObj['to_lng'] = globals.delivery_receiverAddressLONG;
      apiBodyObj['distance'] = totalDistance;
      apiBodyObj['category'] = itemCategory.text;
      apiBodyObj['notes'] = additionalInstructions.text;
      apiBodyObj['favourite_status'] = _isFavorite == true ? 1:0;
      apiBodyObj['required_id_status'] = _isIdRequired == true ? 1:0;

      await NetworkHelper.request("GoferBike/RequestPickUp", apiBodyObj).then((
          response) {
        if(response['status'] == "success") {
          showInSnackBar("Created successfully!");
        }
        else if(response['error'] == "switch_to_user_perspective")  showInSnackBar("Switch to user!");
        else if(response['error'] == "failed_to_add_the_pick_up")  showInSnackBar("Failed to add pickup");
        else if(response['error'] == "request_not_completed")  showInSnackBar("Request not completed");
      });

      Navigator.pushReplacement(_scaffoldKey.currentContext, MaterialPageRoute(builder: (context) => LookingForRidersScreen()));
    }
  }

  void calculateFee() async {
    if(totalDistance.isNotEmpty) {
      totalFee = "";
      print('API Call: newRequest()');
      var apiBodyObj = {};
      apiBodyObj['access_token'] = AppConstants.accessToken;
      apiBodyObj['distance'] = totalDistance;

      await NetworkHelper.request("GoferBike/GetAmountFromDistance", apiBodyObj).then((response) {
        if (response['status'] == "success") {
          setState(() {
            totalFee = response['pick_up_fee'].toString();
          });
          showInSnackBar("You will have to pay " + totalFee + " for a distance of " + totalDistance + " km.");
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // FocusScope.of(context).unfocus();

    Future<void> _showReceiverDetailsDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Receiver Details'),
            insetPadding: EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: receiverDetailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      filled: true,
                      icon: const Icon(Icons.home, color: Colors.blueAccent,),
                      labelText: "Complete address",
                      labelStyle: TextStyle(color: Colors.blueGrey),
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: receiverDetailID,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      filled: true,
                      icon: const Icon(Icons.person, color: Colors.blueAccent,),
                      labelText: "Receivers ID",
                      labelStyle: TextStyle(color: Colors.blueGrey),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: receiverDetailNumber,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      filled: true,
                      icon: const Icon(Icons.call, color: Colors.blueAccent,),
                      labelText: "Mobile number",
                      labelStyle: TextStyle(color: Colors.blueGrey),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
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
                  receiverDetailAddress.clear();
                  receiverDetailID.clear();
                  receiverDetailNumber.clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> _showItemDetailsDialog() async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Receiver Details'),
            insetPadding: EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: itemCategory,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(

                      filled: true,
                      icon: const Icon(Icons.category, color: Colors.deepOrange,),
                      labelText: "Category",
                      labelStyle: TextStyle(color: Colors.blueGrey),
                    ),
                    keyboardType: TextInputType.multiline,
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    controller: itemWeight,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      filled: true,
                      icon: const Icon(Icons.line_weight, color: Colors.deepOrange,),
                      labelText: "Item weight (Less than 1kg, 2kg, 3kg, ...)",
                      labelStyle: TextStyle(color: Colors.blueGrey),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 20.0),
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
                  itemCategory.text = "";
                  itemWeight.text = "";
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    if(widget.addressData != "" && widget.addressType == "recipient" && globals.delivery_recipientAddress == "") {
      globals.delivery_recipientAddress = widget.addressData;
      recipientAddressController.text = widget.addressData;
    }
    else if(widget.addressData != "" && widget.addressType == "receiver" && globals.delivery_receiverAddress == "") {
      globals.delivery_receiverAddress = widget.addressData;
      receiverAddressController.text = widget.addressData;
    }
    if(globals.delivery_recipientAddress != "") recipientAddressController.text = globals.delivery_recipientAddress;
    if(globals.delivery_receiverAddress != "") receiverAddressController.text = globals.delivery_receiverAddress;
    widget.addressData = "";

    final recipientAddress = TextFormField(
      readOnly: true,
      controller: recipientAddressController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        filled: true,
        icon: const Icon(Icons.room, color: Colors.blueAccent,),
        labelText: "Enter pickup address",
        labelStyle: TextStyle(color: Colors.blueGrey),
        border: new OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(25.0),
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () => {
            globals.delivery_recipientAddress = "",
            recipientAddressController.text = "",
          },
          icon: Icon(Icons.clear),
        ),
      ),
      keyboardType: TextInputType.streetAddress,
      onSaved: (value) {

      },
        onChanged: (text) async {
          final sessionToken = "33e37ad8-8d0a-49bc-b7eb-5a7e60a539da";
          final Suggestion result = await showSearch(
            context: context,
            delegate: AddressSearch(sessionToken, "recipient"),
          );
        },
      /*onTap: () async {
        final sessionToken = "33e37ad8-8d0a-49bc-b7eb-5a7e60a539da";
        final Suggestion result = await showSearch(
          context: context,
          delegate: AddressSearch(sessionToken, "recipient"),
        );
        // This will change the text displayed in the TextField
        /*if (result != null) {
          final placeDetails = await PlaceApiProvider(sessionToken)
              .getPlaceDetailFromId(result.placeId);
          setState(() {
            _controller.text = result.description;
            _streetNumber = placeDetails.streetNumber;
            _street = placeDetails.street;
            _city = placeDetails.city;
            _zipCode = placeDetails.zipCode;
          });*/

      }*/
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(addressType:"recipient"))).then((value) {
          setState(() {
            totalDistance = globals.totalDistance;
          });
          if(globals.totalDistance.isNotEmpty) calculateFee();
        });
      }
    );

    final receiverAddress = TextFormField(
        readOnly: true,
      controller: receiverAddressController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        filled: true,
        icon: const Icon(Icons.room, color: Colors.deepOrange),
        labelText: "Enter destination address",
        labelStyle: TextStyle(color: Colors.blueGrey),
        border: new OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(25.0),
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () => {
            globals.delivery_receiverAddress = "",
            receiverAddressController.text = "",
          },
          icon: Icon(Icons.clear),
        ),
      ),
        keyboardType: TextInputType.streetAddress,
        onSaved: (value) {

        },
        onChanged: (text) async {
          /*final sessionToken = "33e37ad8-8d0a-49bc-b7eb-5a7e60a539da";
          final Suggestion result = await showSearch(
            context: context,
            delegate: AddressSearch(sessionToken, "receiver"),
          );*/
        },
        /*onTap: () async {
          final sessionToken = "33e37ad8-8d0a-49bc-b7eb-5a7e60a539da";
          final Suggestion result = await showSearch(
            context: context,
            delegate: AddressSearch(sessionToken, "receiver"),
          );
        }*/
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MapScreen(addressType:"receiver"))).then((value) {
            setState(() {
              totalDistance = globals.totalDistance;
            });
            if(globals.totalDistance.isNotEmpty) calculateFee();
          });
        }
    );

    final contactNumber = TextFormField(
        controller: contactNumberController,
        decoration: InputDecoration(
          icon: const Icon(Icons.call, color: Colors.green),
          labelText: "Pickup Contact Number",
          labelStyle: TextStyle(color: Colors.blueGrey),
          border: new OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(25.0),
            ),
          ),
        ),
        keyboardType: TextInputType.phone,
    );

    final receiverDetailsBtn = ButtonTheme(
      minWidth: MediaQuery.of(context).size.width * .4,
      height: 55.0,
      child: RaisedButton(
        color: (receiverDetailAddress.text.isNotEmpty && receiverDetailID.text.isNotEmpty && receiverDetailNumber.text.isNotEmpty) ? Colors.blueAccent : Colors.white54,
        onPressed: () {_showReceiverDetailsDialog();},
        child: Column(
          children: [
            Icon(Icons.account_circle, color: Colors.orangeAccent),
            SizedBox(height:5.0),
            Text("Receiver Details", style: TextStyle(color: Colors.black54),)
          ],
        ),
      ),
    );

    final deliveryInstructions = TextFormField(
      controller: additionalInstructions,
      decoration: InputDecoration(
        border: new OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(25.0),
          ),
        ),
        labelText: "Additional instructions (e.g No mayo, less ice, add more sauce)",
      ),
      maxLines: 2,
    );


    final itemDetailsBtn = ButtonTheme(
      minWidth: MediaQuery.of(context).size.width * .4,
      height: 55.0,
      child: RaisedButton(
        color: (itemCategory.text.isNotEmpty && itemWeight.text.isNotEmpty) ? Colors.blueAccent : Colors.white54,
        onPressed: () {_showItemDetailsDialog();},
        child: Column(
          children: [
            Icon(Icons.category, color: Colors.orangeAccent),
            SizedBox(height:5.0),
              Text("Item Details", style: TextStyle(color: Colors.black54),)
          ],
        ),
      ),
    );

    final idRequiredBtn = InkWell(
      onTap: (){
        setState(() {
          _isIdRequired = !_isIdRequired;
        });
      },
      child: Row(
        children: [
          Icon(_isIdRequired ? Icons.check_box : Icons.check_box_outline_blank),
          SizedBox(width: 15.0),
          Text("Require Receiver ID"),
        ],
      ),
    );


    final favoritesBtn = InkWell(
      onTap: (){
        setState(() {
          _isFavorite = !_isFavorite;
        });
      },
      child: Row(
        children: [
          Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          SizedBox(width: 15.0),
          Text("Add to favorites"),
        ],
      ),
    );

    final bookButton = Material(
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.green,
      child: MaterialButton(
        minWidth: MediaQuery
            .of(context)
            .size
            .width * .4,
        onPressed: (){_confirmBooking(context);},
        child: Text("BOOK NOW",
            textAlign: TextAlign.center,
            style: style.copyWith(color: Colors.white70)),
      ),
    );


    /*final btmPanel = DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.0,
      maxChildSize: 0.4,

      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Container(
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
            child:
          ),
        );
      },
    );*/



    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        title: Text("Enter Delivery Details", style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  SizedBox(height: 15.0,),
                  recipientAddress,
                  SizedBox(height: 15.0,),
                  receiverAddress,
                  SizedBox(height: 20.0),
                  contactNumber,
                  SizedBox(height: 20.0,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      receiverDetailsBtn,
                      itemDetailsBtn
                    ],
                  ),
                  SizedBox(height: 20.0,),
                  deliveryInstructions,
                  SizedBox(height:20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      favoritesBtn,
                      idRequiredBtn,
                    ],
                  ),
                  SizedBox(height:20.0),


                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black12,
                  ),
                  SizedBox(height: 10.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.directions_bike, color: Colors.black, size: 45,),
                                  Text("Goferbike", style:TextStyle(color:Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.credit_card, color: Colors.black, size: 45,),
                                  Text("4812", style:TextStyle(color:Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.confirmation_number, color: Colors.black, size: 45,),
                                  Text("Voucher", style:TextStyle(color:Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black12,
                  ),
                  SizedBox(height: 15),
                  Visibility(
                    visible: (totalDistance.isNotEmpty) ? true : false,
                    child: Text("Pay " + totalFee + " for total delivery distance of "+ totalDistance+" km", style: TextStyle(color: Colors.black45, fontSize: 14),),
                  ),
                  SizedBox(height: 15),
                  bookButton,
                  SizedBox(height: 30),

                ],

              ),
            ),

          ],
        ),
      ),
    );
  }
}
