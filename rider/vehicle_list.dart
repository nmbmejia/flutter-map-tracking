import 'package:flutter/material.dart';

class VehicleListScreen extends StatefulWidget {
  VehicleListScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _VehicleListState createState() => _VehicleListState();
}

class _VehicleListState extends State<VehicleListScreen> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize:20.0);

  @override
  Widget build(BuildContext context) {

    final newButton = FloatingActionButton(
      onPressed: (){},
      child: Icon(Icons.add),
      mini: true,
      backgroundColor: Colors.green,
    );

    final requestCard = Card(

      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: <Widget>[

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Yamaha Sniper 150",
                    style: TextStyle(fontSize: 19),
                  ),
                  Text(
                    "Motorcycle · Added on 04/08/2021",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );

    List<Widget> buildActions() {
      return <Widget>[
        newButton
      ];
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
          title: Text("Your Vehicles", style: TextStyle(color: Colors.black),),
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
            itemCount: 1,
            itemBuilder: (BuildContext context, int i) =>
              requestCard
          )
        ),
      ),
    );
  }
}
