import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:android_intent/android_intent.dart';
import 'package:flutter/services.dart' show SystemChrome, rootBundle;

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cab_e/payment_screen.dart';
import 'package:cab_e/providers/order_provider.dart';
import 'package:cab_e/shared/constants.dart';
import 'package:cab_e/wallet_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:http/http.dart' as http;
import 'custom_search.dart';
import 'order.dart';
import 'scanQR_screen.dart';

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

  Uint8List driverIconUint;

  PanelController panelController = PanelController();

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    FirebaseFirestore.instance
        .collection("order")
        .where('userUid', isEqualTo: "1") //provider.appUser.uid)
        .where('isCatered', isEqualTo: false)
        .get()
        .then((value) async {
      if (value.size != 0) {
        orderProvider.currentOrder.value = Order.fromMap(value.docs[0].data());
        setPathRouteInfo(orderProvider.currentOrder.value);
        orderProvider.currentOrder.notifyListeners();
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // var time = prefs.getInt('counter');
        // var difference = DateTime.now().millisecondsSinceEpoch - time;
        // difference = (difference / 1000).floor();
        // if (difference >= 120) {
        // difference = 0;
        // }
        // findMessenger(difference);
        orderProvider.listenOrder(
            orderProvider.currentOrder.value.orderId, messengerCallback);
      } else {
        // _getCurrentAtStart();
      }
    });
  }

  void setPathRouteInfo(Order order) {
    totalDistance = "24";
    totalTime = "24";

    totalPrice = order.fare.toString();
    pickUp = order.sourceLocationName;
    dropOff = order.destLocationName;
    instructionText = order.instruction;
    // instructionController.text = order.instruction;
    latLngSource = LatLng(order.sourceLat, order.sourceLng);
    latLngDestination = LatLng(order.destLat, order.destlng);
  }

  // _getCurrentAtStart() {
  //   _gpsService("Enable GPS",
  //       'This app will require GPS services, please enable it first');
  //   final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  //   geolocator
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
  //       .then((Position position) {
  //     setState(() {
  //       _currentPosition = position;
  //       mapController
  //           .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //         target: LatLng(
  //             _currentPosition.latitude - 0.001, _currentPosition.longitude),
  //         zoom: 17,
  //       )));
  //       _onAddMarkerButtonPressed();
  //     });
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }

  /*Check if gps service is enabled or not*/
  Future _gpsService(String title, String note) async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      _checkGps(title, note);
      return null;
    } else
      return true;
  }

  ////GPS
  Future _checkGps(String title, String note) async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(title),
                content: Text(note),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        final AndroidIntent intent = AndroidIntent(
                            action:
                                'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true).pop();
                      })
                ],
              );
            });
      }
    }
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
  void initState() {
    super.initState();
    driverIconAssigned();
  }

  void driverIconAssigned() async {
    driverIconUint = await getBytesFromAsset('assets/images/places.png', 100);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

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
      body: Stack(
        children: [
          SlidingUpPanel(
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
            panel: (() {
              print("YES_2 ------------------------ ");
              if (orderProvider.currentOrder.value == null) {
                if (_isPathCreated) {
                  return confirmRide();
                } else {
                  return orderRide();
                }
                // if (orderProvider.currentOrder.value.driverId != null &&
                //     orderProvider.currentOrder.value.driverId != "" &&
                //     orderProvider.currentOrder.value.isCatered == false) {
                //   FirebaseFirestore.instance
                //       .collection("order")
                //       .doc(orderProvider.currentOrder.value.orderId)
                //       .update({
                //     "orderStatus": OrderStatus.orderCompleted.index,
                //     "isCatered": true
                //   }).then((_) {
                //     print("success-Completed!");
                //   });

                //   print("YES_1 ------------------------ ");
                //   setState(() {
                //     orderProvider.orderListener.cancel();
                //     Future.delayed(
                //         Duration(milliseconds: 1000),
                //         () => Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //                 builder: (context) => MyScan(

                //                     ))));
                //   });
                // }
                return orderRide();
              } else if (orderProvider.currentOrder.value.status ==
                  OrderStatus.findingDriver) {
                return confirmRide();
              } else if (orderProvider.currentOrder.value.status ==
                  OrderStatus.findingDriverFailed) {
                setState(() {
                  orderProvider.orderListener.cancel();
                  orderProvider.isFindingOrder.value = false;
                  panelController.close();
                  FirebaseFirestore.instance
                      .collection("order")
                      .doc(orderProvider.currentOrder.value.orderId)
                      .update({
                    "orderStatus": OrderStatus.findingDriverFailed.index,
                    "isCatered": true
                  }).then((_) {
                    panelController.open();
                    print("success-Failed!");
                  });
                  orderProvider.currentOrder.value = null;
                  return orderRide();
                });
              } else if (orderProvider.currentOrder.value.status ==
                  OrderStatus.driverOnWay) {
                setState(() {
                  orderProvider.isFindingOrder.value = false;
                  updateMessengerMarker(
                      LatLng(orderProvider.currentOrder.value.driverLat,
                          orderProvider.currentOrder.value.driverLng),
                      "driver");
                });
                return onTheWayRide();
              } else if (orderProvider.currentOrder.value.status ==
                  OrderStatus.orderCancelled) {
                Fluttertoast.showToast(
                    msg: "Order Cancelled",
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    toastLength: Toast.LENGTH_LONG);
                setState(() {
                  instructionText = "";
                  // instructionController.text = "";
                  orderProvider.orderListener.cancel();
                  orderProvider.isFindingOrder.value = false;
                  // _showMaps = true;
                  panelController.close();
                  FirebaseFirestore.instance
                      .collection("order")
                      .doc(orderProvider.currentOrder.value.orderId)
                      .update({
                    "orderStatus": OrderStatus.orderCancelled.index,
                    "isCatered": true
                  }).then((_) {
                    panelController.open();
                    print("success-Cancelled!");
                  });
                  _markers.clear();
                  // orderProvider.currentOrder.value = null;
                });
                onOrderCancelled();
                pickUp = "";
                dropOff = "";
                // dateTime = "Date/Time";
                _getCurrentLocation();
                return orderRide();
              } else if (orderProvider.currentOrder.value.status ==
                  OrderStatus.orderCompleted) {
                Order tempOrder = null;
                Fluttertoast.showToast(
                    msg: "Order Completed",
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    toastLength: Toast.LENGTH_LONG);
                setState(() {
                  // instructionText = "";
                  // instructionController.text = "";
                  orderProvider.orderListener.cancel();
                  orderProvider.isFindingOrder.value = false;
                  // _showMaps = true;
                  panelController.close();
                  FirebaseFirestore.instance
                      .collection("order")
                      .doc(orderProvider.currentOrder.value.orderId)
                      .update({
                    "orderStatus": OrderStatus.orderCompleted.index,
                    "isCatered": true
                  }).then((_) {
                    panelController.open();
                    print("success-Completed!");
                  });
                  _markers.clear();
                  tempOrder = orderProvider.currentOrder.value;
                  orderProvider.currentOrder.value = null;
                });
                onOrderCancelled();
                pickUp = "";
                dropOff = "";
                // dateTime = "Date/Time";
                _getCurrentLocation();
                // Future.delayed(
                //     Duration(milliseconds: 1000),
                //         () => Navigator.of(context).push(createRoute(OrderCompletePage(order: tempOrder)))
                // );
                setState(() {
                  orderProvider.orderListener.cancel();
                  Future.delayed(
                      Duration(milliseconds: 1000),
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyScan())));
                });
                return orderRide();
              }
            }()),
            color: AppColor.primaryDark,
            margin: EdgeInsets.only(right: 30, left: 30),
          ),
          orderProvider.isFindingOrder.value == true
              ? Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  color: Colors.black.withOpacity(0.5),
                  child: SpinKitRipple(
                    color: AppColor.primaryDark,
                    size: double.maxFinite,
                  ),
                )
              : Container(),
        ],
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
                    order.userUid = "1";
                    order.fare = double.parse(totalPrice);

                    order.status = OrderStatus.findingDriver;

                    bool isUploaded = await orderProvider.uploadOrderNow(order);

                    if (isUploaded) {
                      // orderProvider.sendNotification(
                      //     'notifier', order.orderId);

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => PaymentScreen(
                      //               fare: totalPrice,
                      //             )));

                      orderProvider.listenOrder(
                          orderProvider.currentOrder.value.orderId,
                          messengerCallback);
                      findMessenger(120);
                    }
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget onTheWayRide() {
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
        ],
      ),
    );
  }

  void findMessenger(int findingDurationSec) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // SharedPreferences = SharedPreferences.getInstance();
    if (orderProvider.currentOrder.value.status == OrderStatus.findingDriver) {
      // await prefs.setInt('counter', DateTime.now().millisecondsSinceEpoch);
      setState(() {
        print("CLOSEEEEEEEE ---------- ");
        panelController.close();
        orderProvider.isFindingOrder.value = true;
        print("TRUEEEEEE - ---- - - -" +
            orderProvider.isFindingOrder.value.toString());
      });
      Timer(Duration(seconds: findingDurationSec), () {
        if (orderProvider.currentOrder.value.status ==
            OrderStatus.findingDriver) {
          setState(() {
            orderProvider.isFindingOrder.value = false;
            // isDistanceCal = true;
            FirebaseFirestore.instance
                .collection("order")
                .doc(orderProvider.currentOrder.value.orderId)
                .update({
              "orderStatus": OrderStatus.findingDriverFailed.index,
              "isCatered": true
            }).then((_) {
              print("success-Failed-in-Timer!");
              setState(() {
                orderProvider.currentOrder.value = null;
                // isDistanceCal = true;
              });
            });
            AwesomeDialog(
                context: context,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "No Driver Found",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: AppColor.primaryDark),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(
                        "It seems like no driver is available right now.",
                        style: TextStyle(
                            fontSize: 18, color: Colors.black.withOpacity(0.6)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                onDissmissCallback: () {
                  panelController.open();
                },
                customHeader: Container(
                  width: double.maxFinite,
                  height: double.maxFinite,
                  child: Icon(
                    Icons.warning,
                    size: 50,
                    color: Colors.white,
                  ),
                  decoration: BoxDecoration(
                      color: AppColor.primaryDark, shape: BoxShape.circle),
                ),
                animType: AnimType.BOTTOMSLIDE,
                btnOkColor: AppColor.primaryDark,
                btnOkOnPress: () async {})
              ..show();
          });
        }
      });
    }
  }

  void addMessengerMarker(LatLng latLng, String id) {
    try {
      _markers.remove(_markers
          .firstWhere((Marker marker) => marker.markerId.value == "driver"));
    } catch (e) {
      print(e);
    }

    _markers.add(Marker(
      draggable: false,
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId(id),
      position: latLng,
      // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      // icon: messengerIcon,
      icon: BitmapDescriptor.fromBytes(driverIconUint),
    ));
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(latLng.latitude - 0.008, latLng.longitude),
      zoom: 15,
    )));
    setState(() {});
  }

  void messengerCallback() {
    try {
      addMessengerMarker(
          LatLng(orderProvider.currentOrder.value.driverLat,
              orderProvider.currentOrder.value.driverLng),
          "driver");
      _markers.add(Marker(
        draggable: false,
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId("start"),
        position: LatLng(orderProvider.currentOrder.value.sourceLat,
            orderProvider.currentOrder.value.sourceLng),
        // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        // icon: sourceIcon,
        // icon: BitmapDescriptor.fromBytes(sourceIconUint),
      ));
      _markers.add(Marker(
          draggable: false,
          // This marker id can be anything that uniquely identifies each marker.
          markerId: MarkerId("destination"),
          position: LatLng(orderProvider.currentOrder.value.destLat,
              orderProvider.currentOrder.value.destlng),
          // icon:
          // BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          // icon: BitmapDescriptor.fromBytes(sourceIconUint),
          rotation: 0.5));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void updateMessengerMarker(LatLng latLng, String id) {
    try {
      _markers.remove(_markers
          .firstWhere((Marker marker) => marker.markerId.value == "driver"));
    } catch (e) {
      print(e);
    }

    _markers.add(Marker(
      draggable: false,
      // This marker id can be anything that uniquely identifies each marker.
      markerId: MarkerId(id),
      position: latLng,
      // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      // icon: messengerIcon,
      icon: BitmapDescriptor.fromBytes(driverIconUint),
    ));
    setState(() {});
  }

  void onOrderCancelled() {
    setState(() {
      _isPathCreated = false;
      // isDistanceCal = false;
      totalTime = "";
      totalDistance = "";
      totalPrice = "";
      polylineCoordinates.clear();
    });
  }

  _getCurrentLocation() async {
    if (_isPathCreated) {
      _isPathCreated = false;
      polylineCoordinates.clear();
      _markers.clear();
    }
  }
}
