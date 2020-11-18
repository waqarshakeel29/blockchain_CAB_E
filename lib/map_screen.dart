import 'dart:convert';

import 'package:cab_e/payment_screen.dart';
import 'package:cab_e/providers/order_provider.dart';
import 'package:cab_e/shared/constants.dart';
import 'package:cab_e/wallet_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'custom_search.dart';
import 'order.dart';

class MapScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MapScreenState();
  }
}

class MapScreenState extends State<MapScreen> {
  final orderProvider = GetIt.I<OrderProvider>();

  GoogleMapController mapController;
  final Key _mapKey = UniqueKey();

  // Pickup - Dropoff - LagLngSource - LatLngDestination
  String pickUp = "";
  String dropOff = "";
  LatLng latLngSource = null;
  LatLng latLngDestination = null;

  PolylinePoints polylinePoints;
  // List of coordinates to join
  List<LatLng> polylineCoordinates = [];
  // Map storing polylines created by connecting
  // two points
  Map<PolylineId, Polyline> polylines = {};
  // Create the polylines for showing the route between two places

  final Set<Marker> _markers = {};

  PanelController panelController = PanelController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  BoxDecoration _boxDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: AppColor.primaryYellow),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20.0),
      topRight: Radius.circular(20.0),
      bottomLeft: Radius.circular(20.0),
      bottomRight: Radius.circular(20.0),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColor.primaryDark),
        title: Text(
          "CAB-E",
          style: TextStyle(
              color: AppColor.primaryDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColor.primaryYellow,
        elevation: 0.0,
      ),
      backgroundColor: Colors.transparent,
      body: SlidingUpPanel(
        controller: panelController,
        maxHeight: _isPathCreated
            ? MediaQuery.of(context).size.height * 0.40
            : MediaQuery.of(context).size.height * 0.30,
        minHeight: MediaQuery.of(context).size.height * 0.055,
        body: Stack(
          children: [
            GoogleMap(
              myLocationEnabled: false,
              mapType: MapType.terrain,
              polylines: Set<Polyline>.of(polylines.values),
              key: _mapKey,
              zoomControlsEnabled: false,
              markers: _markers,
              compassEnabled: true,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(30.3753, 69.3451),
                bearing: 90,
                tilt: 30,
                zoom: 5.0,
              ),
            )
          ],
        ),
        collapsed: GestureDetector(
          onTap: () {
            setState(() {
              if (panelController.isPanelClosed) {
                panelController.open();
              } else {
                panelController.close();
              }
            });
          },
          child: Container(
            color: AppColor.primaryDark,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Row(
                children: [
                  Text(
                    "Order a Ride",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  Expanded(child: SizedBox()),
                  Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  )
                ],
              ),
            ),
          ),
        ),
        panel: _isPathCreated ? confirmRide() : orderRide(),
        color: AppColor.primaryDark,
        margin: EdgeInsets.only(right: 30, left: 30),
      ),
      drawer: Drawer(
        child: Container(
          color: AppColor.primaryDark,
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Container(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Hello, Waqar',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    )),
              ),
              Divider(
                color: Colors.white,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => WalletScreen()));
                },
                child: ListTile(
                  title: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Wallet',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.home,
                          size: 35,
                          color: Colors.white,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Home',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.help,
                          size: 35,
                          color: Colors.white,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Help',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.info,
                          size: 35,
                          color: Colors.white,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'About',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.settings,
                          size: 35,
                          color: Colors.white,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Feedback',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Row(
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.developer_mode,
                          size: 35,
                          color: Colors.white,
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isPathCreated = false;
  void addMarker(LatLng latLng, String id) {
    try {
      _markers.remove(_markers
          .firstWhere((Marker marker) => marker.markerId.value == "current"));
    } catch (e) {
      print(e);
    }

    if (_isPathCreated) {
      _isPathCreated = false;
      polylineCoordinates.clear();
      _markers.clear();
    }

    _markers.add(Marker(
      draggable: false,
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId(id),
      position: latLng,
      // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    ));
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(latLng.latitude - 0.001, latLng.longitude),
      zoom: 15,
    )));
  }

  _createPolylines(Position start, Position destination) async {
    // Initializing PolylinePoints

    _isPathCreated = true;
    polylineCoordinates.clear();

    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_API_KEY, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    ////////////////TEST
    //Creating Bounds:
    var bounds = boundsFromLatLngList(result.points);
    Future.delayed(
        Duration(milliseconds: 200),
        () => mapController
            .animateCamera(CameraUpdate.newLatLngBounds(bounds, 100)));

    // Adding the coordinates to the list
////////////////////TEST

    print(result.points.toString());
    print("this is result------------------------------------------");
    setState(() {});
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // calculateDistance();

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: AppColor.primaryYellow,
      points: polylineCoordinates,
      width: 5,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
  }

  LatLngBounds boundsFromLatLngList(List<PointLatLng> list) {
    double x0, x1, y0, y1;
    for (PointLatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  String instructionText = "";
  String totalDistance = " ";
  String totalPrice = " ";
  String totalTime = " ";
  bool totalTimeMin = true;
  var distanceText = "00.00";
  var distanceValue = 0;
  var timeText = "00:00";
  var timeValue = 0;
  void getDistanceAndTime(sLat, sLng, dLat, dLng) async {
    var response = await http.get(
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$sLat,$sLng&destinations=$dLat,$dLng&key=$GOOGLE_API_KEY");
    Map<String, dynamic> map = json.decode(response.body);
    print(map);
    var m1 = map['rows'];
    Map<String, dynamic> m2 = m1[0];
    var m3 = m2['elements'];
    Map<String, dynamic> m4 = m3[0];
    Map<String, dynamic> m5 = m4['distance'];
    Map<String, dynamic> m6 = m4['duration'];
    setState(() {
      distanceText = m5['text'];
      distanceValue = m5['value'];
      totalDistance = (distanceValue / 1000).toStringAsFixed(1).toString();
      totalPrice = ((distanceValue / 1000) * 10).ceil().toString();
      timeText = m6['text'];
      timeValue = m6['value'];
      if (timeValue >= 3600) {
        totalTime = (timeValue / 3600).toStringAsFixed(1);
        totalTimeMin = false;
      } else {
        totalTime = (timeValue / 60).toStringAsFixed(1);
        totalTimeMin = true;
      }
    });
  }

  Widget orderRide() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home,
                color: AppColor.primaryYellow,
              ),
              SizedBox(
                width: 5,
              ),
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CustomSearchScaffold(text: pickUp)));
                  if (result != null) {
                    if (result.toString() == SELECT_FROM_MAP) {
                      // var res = await Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => PlacePicker(
                      //       apiKey:
                      //           GOOGLE_API_KEY, // Put YOUR OWN KEY here.
                      //       initialPosition: _center,
                      //       useCurrentLocation: false,
                      //     ),
                      //   ),
                      // );
                      // setState(() {
                      //   pickUp = res.formattedAddress;
                      //   print("RESULT ___ _ _ _ __  _ $pickUp");
                      //   latLngSource = LatLng(res.geometry.location.lat,
                      //       res.geometry.location.lng);
                      //   addMarker(latLngSource, "Source");
                      // });
                    } else {
                      setState(() {
                        pickUp = result.name;
                        print("RESULT ___ _ _ _ __  _ $pickUp");
                        latLngSource = LatLng(result.geometry.location.lat,
                            result.geometry.location.lng);
                        print("LAGLNG ___ _ _ _ __  _ $latLngSource");
                        addMarker(latLngSource, "Source");
                      });
                    }
//                              addMarker(latLngSource, "Source");
                  }
                },
                child: Container(
                  decoration: _boxDecoration,
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Row(
                      children: <Widget>[
                        (pickUp == "")
                            ? Text(
                                "Pickup Location",
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.5)),
                              )
                            : Flexible(
                                child: Text(
                                pickUp,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.9)),
                              )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home,
                color: AppColor.primaryYellow,
              ),
              SizedBox(
                width: 5,
              ),
              GestureDetector(
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CustomSearchScaffold(text: dropOff)));
                  if (result != null) {
                    if (result.toString() == SELECT_FROM_MAP) {
                      // var res = await Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => PlacePicker(
                      //       apiKey:
                      //           GOOGLE_API_KEY, // Put YOUR OWN KEY here.
                      //       initialPosition: _center,
                      //       useCurrentLocation: false,
                      //     ),
                      //   ),
                      // );
                      // setState(() {
                      //   pickUp = res.formattedAddress;
                      //   print("RESULT ___ _ _ _ __  _ $pickUp");
                      //   latLngSource = LatLng(res.geometry.location.lat,
                      //       res.geometry.location.lng);
                      //   addMarker(latLngSource, "Source");
                      // });
                    } else {
                      setState(() {
                        dropOff = result.name;
                        print("RESULT ___ _ _ _ __  _ $dropOff");
                        latLngDestination = LatLng(result.geometry.location.lat,
                            result.geometry.location.lng);
                        print("LAGLNG ___ _ _ _ __  _ $latLngDestination");
                        addMarker(latLngDestination, "Destination");
                      });
                    }
//                              addMarker(latLngSource, "Source");
                  }
                },
                child: Container(
                  decoration: _boxDecoration,
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 30,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Row(
                      children: <Widget>[
                        (dropOff == "")
                            ? Text(
                                "Destination Location",
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.5)),
                              )
                            : Flexible(
                                child: Text(
                                dropOff,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.9)),
                              )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.white),
          RaisedButton(
            color: AppColor.primaryYellow,
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Text(
                "CONFIRM",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryDark,
                    fontSize: 18),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(color: AppColor.primaryYellow),
            ),
            onPressed: () {
              int count = 2;
              // if (latLngSource == null) {
              //   count = count - 1;
              //   Fluttertoast.showToast(
              //       msg: "Source is not Selected!",
              //       backgroundColor: Colors.white,
              //       textColor: Colors.black,
              //       toastLength: Toast.LENGTH_LONG);
              // }
              // if (latLngDestination == null) {
              //   count = count - 1;
              //   Fluttertoast.showToast(
              //       msg: "Destination is not Selected!",
              //       backgroundColor: Colors.white,
              //       textColor: Colors.black,
              //       toastLength: Toast.LENGTH_LONG);
              //
              // }
              if (count == 2) {
                var source = Position(
                    latitude: latLngSource.latitude,
                    longitude: latLngSource.longitude);
                var destination = Position(
                    latitude: latLngDestination.latitude,
                    longitude: latLngDestination.longitude);

                ////
                FocusScope.of(context).unfocus();

                _markers.clear();

                //// Adding Source and Destination marker
                _markers.add(Marker(
                  draggable: false,
                  // This marker id can be anything that uniquely identifies each marker.
                  markerId: MarkerId("start"),
                  position: latLngSource,
                  // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
                ));
                _markers.add(Marker(
                  draggable: false,
                  // This marker id can be anything that uniquely identifies each marker.
                  markerId: MarkerId("destination"),
                  position: latLngDestination,
                  // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
                ));

                setState(() {
                  panelController.close();
                  _createPolylines(source, destination);
                  getDistanceAndTime(
                      latLngSource.latitude,
                      latLngSource.longitude,
                      latLngDestination.latitude,
                      latLngDestination.longitude);
                  Future.delayed(const Duration(milliseconds: 2000), () {
                    setState(() {
                      panelController.open();
                    });
                  });
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget confirmRide() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 70,
                  height: 70,
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: totalDistance + "\n",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryDark)),
                        TextSpan(
                            text: "KM",
                            style: TextStyle(
                                fontSize: 13, color: AppColor.primaryDark)),
                      ])),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                ),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: 100,
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: totalPrice + "\n",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryDark)),
                        TextSpan(
                            text: "Rs",
                            style: TextStyle(
                                fontSize: 15, color: AppColor.primaryDark)),
                      ])),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                ),
                Container(
                  alignment: Alignment.center,
                  width: 70,
                  height: 70,
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                            text: totalTime + "\n",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primaryDark)),
                        TextSpan(
                            text: totalTimeMin ? "Min" : "Hrs",
                            style: TextStyle(
                                fontSize: 15, color: AppColor.primaryDark)),
                      ])),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home,
                color: AppColor.primaryYellow,
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                // decoration: _boxDecoration,
                width: MediaQuery.of(context).size.width * 0.6,
                height: 30,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                          child: Text(
                        pickUp,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            color: AppColor.primaryYellow.withOpacity(0.9)),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home,
                color: AppColor.primaryYellow,
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                // decoration: _boxDecoration,
                width: MediaQuery.of(context).size.width * 0.6,
                height: 30,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                          child: Text(
                        dropOff,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            color: AppColor.primaryYellow.withOpacity(0.9)),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.white),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RaisedButton(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "CANCEL",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryDark,
                        fontSize: 18),
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  side: BorderSide(color: AppColor.primaryYellow),
                ),
                onPressed: () {
                  setState(() {
                    _isPathCreated = false;
                    totalTime = "";
                    totalDistance = "";
                    totalPrice = "";
                    polylineCoordinates.clear();
                    addMarker(latLngSource, "source");
                  });
                },
              ),
              RaisedButton(
                  color: AppColor.primaryYellow,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "CONFIRM",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryDark,
                          fontSize: 18),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(color: AppColor.primaryYellow),
                  ),
                  onPressed: () async {
                    // showDialog(
                    //   context: context,
                    //   builder: (BuildContext context) => CustomDialog(
                    //     title: "Success",
                    //     description:
                    //         "Ride has been finished! ",
                    //     buttonText: "Okay",
                    //   ),
                    // );

                    int orderNo = 1;
                    // if (myOrder.docs.length != 0) {
                    //   orderNo =
                    //       Order.fromMap(myOrder.docs[0].data()).userOrderNo + 1;
                    // }

                    Order order = Order();
                    order.userOrderNo = orderNo;
                    order.isCatered = false;
                    order.orderId = Uuid().generateV4();
                    order.sourceLat = latLngSource.latitude;
                    order.sourceLng = latLngSource.longitude;
                    order.destLat = latLngDestination.latitude;
                    order.destlng = latLngDestination.longitude;
                    order.destLocationName = dropOff;
                    order.sourceLocationName = pickUp;
                    order.instruction = instructionText;
                    order.creationTime = DateTime.now().millisecondsSinceEpoch;
                    // order.scheduledTime = selectedDate.millisecondsSinceEpoch;
                    order.userUid = "abc123";
                    order.fare = double.parse(totalPrice);

                    order.status = OrderStatus.findingDriver;
                    bool isUploaded = await orderProvider.uploadOrderNow(order);

                    if (isUploaded) {
                      // orderProvider.sendNotification(
                      //     'notifier', order.orderId);

                      orderProvider.listenOrdeR(
                          orderProvider.currentOrder.value.orderId);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                    fare: totalPrice,
                                  )));
                      // orderProvider.listenOrder(
                      //     orderProvider.currentOrder.value.orderId,
                      //     messengerCallback);
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }
}

// class CustomDialog extends StatelessWidget {
//   final String title, description, buttonText;
//   final Image image;

//   CustomDialog({
//     @required this.title,
//     @required this.description,
//     @required this.buttonText,
//     this.image,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(Consts.padding),
//       ),
//       elevation: 0.0,
//       backgroundColor: Colors.transparent,
//       child: dialogContent(context),
//     );
//   }

//   dialogContent(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         Container(
//           padding: EdgeInsets.only(
//             top: Consts.avatarRadius + Consts.padding,
//             bottom: Consts.padding,
//             left: Consts.padding,
//             right: Consts.padding,
//           ),
//           margin: EdgeInsets.only(top: Consts.avatarRadius),
//           decoration: new BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.rectangle,
//             borderRadius: BorderRadius.circular(Consts.padding),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black26,
//                 blurRadius: 10.0,
//                 offset: const Offset(0.0, 10.0),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min, // To make the card compact
//             children: <Widget>[
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 24.0,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//               SizedBox(height: 16.0),
//               Text(
//                 description,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16.0,
//                 ),
//               ),
//               SizedBox(height: 24.0),
//               Align(
//                 alignment: Alignment.bottomRight,
//                 child: FlatButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // To close the dialog
//                   },
//                   child: Text(buttonText),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Positioned(
//           left: Consts.padding,
//           right: Consts.padding,
//           child: CircleAvatar(
//             backgroundColor: Colors.blueAccent,
//             radius: Consts.avatarRadius,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class Consts {
//   Consts._();
//   static const double padding = 16.0;
//   static const double avatarRadius = 66.0;
// }
