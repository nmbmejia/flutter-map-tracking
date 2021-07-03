import 'package:flutter/material.dart';
import 'package:tagcash/components/app_top_bar.dart';
import 'package:tagcash/apps/buy_load/requests_screen.dart';
import 'package:tagcash/apps/buy_load/riders_screen.dart';
import 'package:tagcash/services/networking.dart';
import 'package:tagcash/models/app_constants.dart' as AppConstants;

class BuyLoadScreen extends StatefulWidget {
  BuyLoadScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _BuyLoadState createState() => _BuyLoadState();
}

class _BuyLoadState extends State<BuyLoadScreen> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize:20.0);
  var riderStatus = "";
  var riderStatusCode = "-1";
  bool loaded = false;

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFFe44933),
        content: Text(value),
      ),
    );
  }

  void getRiderStatus() async {
    /*setState(() {
      isLoading = true;
    });*/
    print('API Call: GoferBike/RiderStatus()');
    var apiBodyObj = {};
    apiBodyObj['access_token'] = AppConstants.accessToken;
    await NetworkHelper.request("GoferBike/RiderStatus", apiBodyObj).then((
        response) {
      if(response['status'] == "success") {
        setState(() {
          riderStatusCode = response['rider_status']['status_code'];
          riderStatus = response['rider_status']['rider_status'];

        });
      }
      loaded = true;
    });
  }

  void registerAsRider() async {
    /*setState(() {
      isLoading = true;
    });*/
    print('API Call: GoferBike/RiderRegistration');
    var apiBodyObj = {};
    apiBodyObj['access_token'] = AppConstants.accessToken;
    await NetworkHelper.request("GoferBike/RiderRegistration", apiBodyObj).then((
        response) {
      var result = response;
      if(result['result'] == "rider_registration_completed_successfully") {
        showInSnackBar("Registration sent!");
        setState(() {
          riderStatusCode = "1";
          riderStatus = "pending";
        });
      }
      else if(result['result'] == "user_should_be_level_3_verified") {
        showInSnackBar("You need to be KYC level 3 verified");
      }
      else if(result['result'] == "failed_to_register_as_goffer") {
        showInSnackBar("Failed to register as rider");
      }
      else if(result['result'] == "request_not_completed") {
        showInSnackBar("Request not completed");
      }
    });
  }

  Future _errorRider(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('Proceed with booking?'),
          content: const Text(
              'Thou shall not pass.'),
          actions: <Widget>[
            FlatButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                //registerAsRider();
              },
            ),
          ],
        );
      },
    );
  }

  Future _confirmRiderApplication(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('Proceed with booking?'),
          content: const Text(
              'Confirm application as Rider (will take 1-2 days)'),
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
                Navigator.of(context).pop();
                registerAsRider();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_statements
    (loaded == false) ? getRiderStatus() : 0;

    final riderButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.white,
      child: MaterialButton(
        minWidth: MediaQuery
            .of(context)
            .size
            .width * .4,
        onPressed: (){
          if(riderStatusCode.toString() != "3") {
            _errorRider(context);
          }
          else Navigator.push(context, MaterialPageRoute(builder: (context) => RidersScreen()));
        },
        child: Text("Rider",
            textAlign: TextAlign.center,
            style: style.copyWith(color: Colors.blueGrey)),
      ),
    );




    final myRequestsButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.white,
      child: MaterialButton(
        minWidth: MediaQuery
            .of(context)
            .size
            .width *.4,
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => RequestsScreen()));
        },
        child: Text("Requests",
            textAlign: TextAlign.center,
            style: style.copyWith(color: Colors.blueGrey)),
      ),
    );

    final logo = Image(
      image: AssetImage('assets/images/gofer/goferlogo.png'),
    );



    final signUpButton = InkWell(
      onTap: () {
        if(riderStatusCode == "0" || riderStatusCode == "2")
          _confirmRiderApplication(context);
      },
      child: Text(
          (riderStatusCode == "0") ? "Not a rider yet? Click to apply now!" :
          (riderStatusCode == "1") ? "Rider application is already pending" :
          (riderStatusCode == "2") ? "Rider status has been declined. You can re-apply again." : ""

          , style: TextStyle(fontSize: 14, color: Colors.white70))
    );

    return Scaffold(
      appBar: AppTopBar(
        appBar: AppBar(),
        title: 'Gofer Delivery',
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/gofer/zzz.jpg'),
              fit: BoxFit.cover,
            )
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              logo,
              SizedBox(height: 45.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  riderButton,
                  myRequestsButton,
                ],
              ),
              SizedBox(height:15.0),
              signUpButton,
              SizedBox(height: 45.0),
            ],
          ),
        ),
      ),
    );
  }
}
