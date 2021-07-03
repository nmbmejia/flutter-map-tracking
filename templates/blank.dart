import 'package:flutter/material.dart';


class NewRequestsScreen extends StatefulWidget {
  NewRequestsScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _NewRequestsState createState() => _NewRequestsState();
}

class _NewRequestsState extends State<NewRequestsScreen> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize:20.0);

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
          title: Text("Home", style: TextStyle(color: Colors.black),),
          centerTitle: true,
        ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.all(0.0),

        ),
      ),
    );
  }
}
