import 'package:flutter/material.dart';

class SearchDropoffScreen extends StatefulWidget {
  SearchDropoffScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SearchDropoffState createState() => _SearchDropoffState();
}

class _SearchDropoffState extends State<SearchDropoffScreen> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize:20.0);

  @override
  Widget build(BuildContext context) {

    final recipientAddress = TextFormField(
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        filled: true,
        icon: const Icon(Icons.room, color: Colors.blueAccent,),
        labelText: "Enter recipient address",
        labelStyle: TextStyle(color: Colors.blueGrey),
      ),
      keyboardType: TextInputType.streetAddress,
      onSaved: (value) {

      },
    );

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
                    "SM Lanang...",
                    style: TextStyle(fontSize: 19),
                  ),
                  Text(
                    "Matina Pangi RD",
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
          title: Text("Home", style: TextStyle(color: Colors.black),),
          centerTitle: true,
          actions: buildActions(),
        ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            recipientAddress,
            ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: 10,
                itemBuilder: (BuildContext context, int i) =>
                requestCard
            ),
          ],
        ),
      ),
    );
  }
}
