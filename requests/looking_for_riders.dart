import 'package:flutter/material.dart';
import '../buy_load_screen.dart';
import '../requests_screen.dart';
import 'map_tracking.dart';


class LookingForRidersScreen extends StatefulWidget {
  LookingForRidersScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LookingForRidersScreenState createState() => _LookingForRidersScreenState();
}

class _LookingForRidersScreenState extends State<LookingForRidersScreen> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize:20.0);

  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration(seconds: 5), () {
      // 5 seconds over, navigate to Page2.
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BuyLoadScreen()));
    });


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
          title: Text("Looking For Riders ...", style: TextStyle(color: Colors.black),),
          centerTitle: true,
        ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              FlatButton(
                onPressed: () {

                },
                child: Image(
                  image: AssetImage('assets/images/gofer/loader.gif'),
                ),
              ),
              SizedBox(height:15.0),
              Text("You will now be redirected to the list page while we are Looking for available riders around the area...", style: TextStyle(color: Colors.black54),),
            ],
          ),
        ),
      ),
    );
  }
}
