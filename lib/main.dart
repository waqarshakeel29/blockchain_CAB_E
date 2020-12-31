import 'package:cab_e/map_screen.dart';
import 'package:cab_e/providers/network_provider.dart';
import 'package:cab_e/scanQR_screen.dart';
import 'package:cab_e/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cab_e/providers/order_provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  GetIt.I.registerSingleton(OrderProvider());
  GetIt.I.registerSingleton(NetworkProvider());
  runApp(MyApp());
}

// void main() {
//   runApp(MaterialApp(home: MyScan()));
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final networkProvider = GetIt.I<NetworkProvider>();

  @override
  Widget build(BuildContext context) {
    // init network provider
    networkProvider.init();

    return MaterialApp(
      title: 'CAB-E',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'LOGIN'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   backgroundColor: AppColor.primaryYellow,
      // ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Align(
                alignment: Alignment.center,
                child: Image(
                  image: AssetImage("assets/images/places.png"),
                  color: AppColor.primaryYellow,
                  height: 150,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Cab-E",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primaryDark),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              "LOGIN",
              style: TextStyle(fontSize: 20, color: AppColor.primaryDark),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 13.5, right: 13.5),
            child: Column(
              children: [
                Row(
                  children: [
                    Image(
                      image: AssetImage("assets/images/mobile.png"),
                      height: 40,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          child: TextField(
                            // controller: instructionController,
                            style: TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5)),
                              labelText: "PHONE NUMBER",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Divider(
                  thickness: 2,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13.5),
            child: RaisedButton(
              color: AppColor.primaryYellow,
              child: Padding(
                padding: const EdgeInsets.all(17.0),
                child: Text(
                  "LOGIN",
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MapScreen()));
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(13.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "FORGET PASSWORD?",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryDark,
                        fontSize: 15),
                  ),
                  Text(
                    "CREATE ACCOUNT",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryDark,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
