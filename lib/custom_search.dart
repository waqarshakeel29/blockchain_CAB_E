import 'package:cab_e/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:math';
import 'custom_auto_complete.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: GOOGLE_API_KEY);
//final searchScaffoldKey = GlobalKey<ScaffoldState>(debugLabel: "searchScreen");
//final homeScaffoldKey = GlobalKey<ScaffoldState>();

Future<Null> displayPrediction(BuildContext context, Prediction p) async {
  if (p != null) {
    // get detail (lat/lng)
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    Navigator.pop(context, detail.result);
//
//    scaffold.showSnackBar(
//      SnackBar(content: Text("${p.description} - $lat/$lng")),
//    );
  }
}

class CustomSearchScaffold extends PlacesAutocompleteWidget {
  String text;
  CustomSearchScaffold({String text})
      : super(
          apiKey: GOOGLE_API_KEY,
          sessionToken: Uuid().generateV4(),
          language: "en",
          components: [Component(Component.country, "pak")],
        ) {
    this.text = text;
  }

  @override
  _CustomSearchScaffoldState createState() =>
      _CustomSearchScaffoldState(text: this.text);
}

class _CustomSearchScaffoldState extends PlacesAutocompleteState {
  String text;
  _CustomSearchScaffoldState({String text}) {
    this.text = text;
//    setState(() {
//      this.doSearch(text);
//    });
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      toolbarHeight: 80,
      automaticallyImplyLeading: false,
      title: Row(
        children: <Widget>[
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.arrow_back, color: AppColor.primaryYellow),
            ),
            onTap: () {
              Navigator.pop(context, "23");
            },
          ),
          Expanded(
            child: AppBarPlacesAutoCompleteTextField(),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
    );

    final body = Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.pop(context, SELECT_FROM_MAP);
          },
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
            child: Card(
              elevation: 5,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.map,
                      color: AppColor.primaryYellow,
                    ),
                  ),
                  Text(
                    "Select from map",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: PlacesAutocompleteResult(
            onTap: (p) {
              displayPrediction(context, p);
            },
            logo: Container(),
          ),
        )
      ],
    );
    return Scaffold(/*key: searchScaffoldKey,*/ appBar: appBar, body: body);
  }

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);
//    searchScaffoldKey.currentState.showSnackBar(
//      SnackBar(content: Text(response.errorMessage)),
//    );
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);
//    if (response != null && response.predictions.isNotEmpty) {
//      searchScaffoldKey.currentState.showSnackBar(
//        SnackBar(content: Text("Got answer")),
//      );
//    }
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
