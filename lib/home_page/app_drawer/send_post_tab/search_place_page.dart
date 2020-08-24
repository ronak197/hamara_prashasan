import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class SearchResult {
  String searchString, name, address;
  LatLng pos;
  SearchResult(
      {@required this.name,
      @required this.pos,
      @required this.searchString,
      @required this.address});
}

class SearchPlace extends StatefulWidget {
  final Function addPlaces;
  SearchPlace({@required this.addPlaces});
  @override
  _SearchPlaceState createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {
  final apiKey = "AIzaSyA4ZokZx9JRs-T1z0EpZxzqHVKlZ-sZkC0";
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _myLocation =
      CameraPosition(target: LatLng(0, 0));
  List<SearchResult> allResults = [], currentResults = [];
  double searchCode;
  TextEditingController _searchcontroller;
  Set<Marker> places = new Set<Marker>();
  bool showSuggestions = false;

  void searchPlaces(String s) async {
    if (s.length >= 4) {
      double mysearchCode = Random().nextDouble();
      searchCode = mysearchCode;
      await Future.delayed(Duration(milliseconds: 500));
      if (mysearchCode == searchCode) {
        s = s.replaceAll(" ", "%20");
        String url =
            "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?key=$apiKey&input=$s&inputtype=textquery&fields=name,geometry,formatted_address";
        var response = await http.get(url);
        print("Response Body: ${response.body}");
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          currentResults.clear();
          for (var loc in data['candidates']) {
            var coord = loc['geometry']['location'];
            SearchResult sr = new SearchResult(
                name: loc['name'],
                pos: new LatLng(coord['lat'], coord['lng']),
                searchString: s,
                address: loc['formatted_address']);
            currentResults.add(sr);
          }
          showSuggestions = true;
          setState(() {});
        }
        print(currentResults);
      }
    }
  }

  void onTapLocation(int index) {
    var place = currentResults[index];
    showSuggestions = false;
    places.add(
      new Marker(
        markerId: new MarkerId(place.name),
        position: place.pos,
        consumeTapEvents: true,
      ),
    );
    _controller.future.then(
      (mapController) => mapController.animateCamera(
        CameraUpdate.newLatLngZoom(place.pos, 12.0),
      ),
    );
    setState(() {});
  }

  void onTapMarker(Marker m) {
    setState(() {
      m = m.copyWith(
          iconParam:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));
    });
  }

  @override
  void initState() {
    super.initState();
    _searchcontroller = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    double suggestionsHeight = min(currentResults.length * 80.0, 200.0) + 20;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
        title: TextField(
          controller: _searchcontroller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          onTap: () {
            setState(() {
              showSuggestions = true;
            });
          },
          onChanged: searchPlaces,
          onSubmitted: searchPlaces,
          style: Theme.of(context)
              .textTheme
              .headline2
              .copyWith(color: Colors.black),
          cursorColor: Colors.black54,
          minLines: 1,
          maxLines: 1,
          maxLength: 100,
          maxLengthEnforced: true,
          enabled: true,
          decoration: InputDecoration(
            hintText: 'Search Place...',
            hintStyle: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(color: Colors.grey[600]),
            counterText: "",
            contentPadding: EdgeInsets.all(12.0),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              currentResults.clear();
              _searchcontroller.clear();
              setState(() {});
            },
          ),
        ],
        bottom: showSuggestions && currentResults.length > 0
            ? PreferredSize(
                child: Container(
                  height: suggestionsHeight,
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    children: new List<Widget>.generate(
                      currentResults.length,
                      (index) {
                        var place = currentResults[index];
                        return ListTile(
                          onTap: () {
                            onTapLocation(index);
                          },
                          title: Text(
                            place.name,
                            style: Theme.of(context).textTheme.headline2,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            place.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                .copyWith(color: Colors.grey),
                          ),
                          trailing: Icon(Icons.location_searching),
                        );
                      },
                    ),
                  ),
                ),
                preferredSize: Size.fromHeight(suggestionsHeight),
              )
            : null,
      ),
      floatingActionButton: places.length > 0
          ? RaisedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.addPlaces(places.toList());
              },
              color: Color(0xff1010fc),
              elevation: 20,
              padding: EdgeInsets.all(15),
              child: Text(
                places.length > 1 ? "Add all Places" : "Add Place",
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            )
          : null,
      body: GestureDetector(
        onTap: () {
          /* if (!FocusScope.of(context).hasPrimaryFocus)
            FocusScope.of(context).unfocus(); */
        },
        child: GoogleMap(
          initialCameraPosition: _myLocation,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          markers: places,
          onTap: (pos) {
            var marker;
            try {
              marker = places.firstWhere((marker) => marker.position == pos);
            } catch (e) {
              print(e);
            }
            print(marker);
            if (marker != null) onTapMarker(marker);
          },
        ),
      ),
    );
  }
}
