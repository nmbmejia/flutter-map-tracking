import 'package:flutter/material.dart';
import 'package:tagcash/apps/buy_load/models/place_service.dart';

import '../map.dart';
import '../request_screen_new.dart';


class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch(this.sessionToken, this.searchType) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final sessionToken;
  String searchType;
  PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
      IconButton(
        tooltip: 'Map',
        icon: Icon(Icons.map),
        onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MapScreen(addressType:searchType)));
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
          query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
        padding: EdgeInsets.all(16.0),
        child: Text(''),
      )
          : snapshot.hasData
          ? ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title:
          Text((snapshot.data[index] as Suggestion).description),
          onTap: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NewRequestsScreen(addressType : searchType, addressData : (snapshot.data[index] as Suggestion).description)));
            //close(context, snapshot.data[index] as Suggestion);
          },
        ),
        itemCount: snapshot.data.length,
      )
          : Container(child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('...')
            )),
    );
  }
}