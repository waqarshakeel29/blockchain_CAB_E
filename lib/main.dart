import 'dart:ffi';

import 'package:cab_e/map_screen.dart';
import 'package:cab_e/providers/network_provider.dart';
import 'package:cab_e/providers/payment_provider.dart';
import 'package:cab_e/providers/wallet_provider.dart';
import 'package:cab_e/scanQR_screen.dart';
import 'package:cab_e/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:cab_e/providers/order_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'authServices.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  GetIt.I.registerSingleton(OrderProvider());
  GetIt.I.registerSingleton(NetworkProvider());
  GetIt.I.registerSingleton(PaymentProvider());
  GetIt.I.registerSingleton(WalletProvider());
  runApp(MyApp());
}

// void main() {
//   runApp(MaterialApp(home: MyScan()));
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final networkProvider = GetIt.I<NetworkProvider>();

  // Future registerUser(String mobile, BuildContext context) async {

  // }

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
      home: AuthService().handleAuth(), //MyHomePage(title: 'LOGIN')
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
  String phoneNo, smssent, verificationId;
  get verifiedSuccess => null;

  Future<void> verfiyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResent]) {
      this.verificationId = verId;
      smsCodeDialoge(context).then((value) {
        print("Code Sent");
      });
    };
    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential auth) {};
    final PhoneVerificationFailed verifyFailed = (FirebaseAuthException e) {
      print('${e.message}');
    };
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: numberController.text,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verifyFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }

  Future<bool> smsCodeDialoge(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter OTP'),
            content: TextField(
              onChanged: (value) {
                this.smssent = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              FlatButton(
                color: Colors.black,
                onPressed: () {
                  if (FirebaseAuth.instance.currentUser != null) {
                    // Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MapScreen()),
                    );
                  } else {
                    Navigator.of(context).pop();
                    signIn(smssent);
                  }
                  // FirebaseAuth.instance.currentUser.then((user) {
                  //   if (user != null) {
                  //   } else {}
                  // });
                },
                child: Text(
                  'done',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        });
  }

  Future<void> signIn(String smsCode) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    await FirebaseAuth.instance.signInWithCredential(credential).then((user) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(),
        ),
      );
    }).catchError((e) {
      print(e);
    });
  }

  // String phoneNo, verId, smsCode;
  // bool codeSent = false;

  var numberController = TextEditingController();
  var codeController = TextEditingController();

  // Future<void> verifyPhone(phoneNo) async {
  //   final PhoneVerificationCompleted verified =
  //       (AuthCredential authCredential) {
  //     AuthService().signIn(authCredential);
  //   };
  //   final PhoneVerificationFailed failed =
  //       (FirebaseAuthException authException) {
  //     print('${authException.message}');
  //   };
  //   final PhoneCodeSent sent = (String verId, [int forceId]) {
  //     this.verId = verId;
  //     setState(() {
  //       this.codeSent = true;
  //     });
  //   };
  //   final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
  //     this.verId = verId;
  //   };

  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //     phoneNumber: numberController.text,
  //     timeout: Duration(seconds: 60),
  //     verificationCompleted: verified,
  //     verificationFailed: failed,
  //     codeSent: sent,
  //     codeAutoRetrievalTimeout: autoTimeout,
  //   );
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      //   backgroundColor: AppColor.primaryYellow,
      // ),
      body: ListView(
        // mainAxisSize: MainAxisSize.max,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            controller: numberController,
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
                // codeSent
                //     ?
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
                            controller: codeController,
                            style: TextStyle(fontSize: 15),
                            decoration: InputDecoration(
                              hintStyle: TextStyle(
                                  color: Colors.black.withOpacity(0.5)),
                              labelText: "VERIFICATION CODE",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number),
                      ),
                    ))
                  ],
                )
                // : Container(),
                // codeSent
                //     ? Divider(
                //         thickness: 2,
                //       )
                //     : Container(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(13.5),
            child: RaisedButton(
              color: AppColor.primaryYellow,
              child: Padding(
                  padding: const EdgeInsets.all(17.0),
                  child:
                      // codeSent
                      // ?
                      Text(
                    "LOGIN",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColor.primaryDark,
                        fontSize: 18),
                  )
                  // : Text(
                  //     "VERIFY",
                  //     style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         color: AppColor.primaryDark,
                  //         fontSize: 18),
                  //   ),
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
                side: BorderSide(color: AppColor.primaryYellow),
              ),
              onPressed: verfiyPhone,
              // () {
              // codeSent
              //     ? AuthService().signInWithOTP(smsCode, this.verId)
              //     : verifyPhone(numberController.text);

              // FirebaseAuth _auth = FirebaseAuth.instance;
              // _auth.verifyPhoneNumber(
              //     phoneNumber: numberController.text,
              //     timeout: Duration(seconds: 60),
              //     verificationCompleted: (AuthCredential authCredential) {
              //       var _credential = PhoneAuthProvider.credential(
              //           verificationId: verificationId, smsCode: smsCode);
              //       _auth
              //           .signInWithCredential(authCredential)
              //           .then((var result) {
              //         // Navigator.pushReplacement(
              //         //     context,
              //         //     MaterialPageRoute(
              //         //         builder: (context) => HomeScreen(result.user)));
              //         print("LOGIN --------- " + result.toString());
              //       }).catchError((e) {
              //         print(e);
              //       });
              //     },
              //     verificationFailed: (var authException) {
              //       print(authException.message);
              //     },
              //     codeSent: (String verificationId,
              //         [int forceResendingToken]) {
              //       //show dialog to take input from the user
              //       showDialog(
              //           context: context,
              //           barrierDismissible: false,
              //           builder: (context) => AlertDialog(
              //                 title: Text("Enter SMS Code"),
              //                 content: Column(
              //                   mainAxisSize: MainAxisSize.min,
              //                   children: <Widget>[
              //                     TextField(
              //                       controller: codeController,
              //                     ),
              //                   ],
              //                 ),
              //                 actions: <Widget>[
              //                   FlatButton(
              //                     child: Text("Done"),
              //                     textColor: Colors.white,
              //                     color: Colors.redAccent,
              //                     onPressed: () {
              //                       FirebaseAuth auth = FirebaseAuth.instance;
              //                       var smsCode = codeController.text.trim();
              //                       var _credential =
              //                           PhoneAuthProvider.credential(
              //                               verificationId: verificationId,
              //                               smsCode: smsCode);
              //                       auth
              //                           .signInWithCredential(_credential)
              //                           .then((var result) {
              //                         Navigator.push(
              //                             context,
              //                             MaterialPageRoute(
              //                                 builder: (context) =>
              //                                     MapScreen()));
              //                       }).catchError((e) {
              //                         print(e);
              //                       });
              //                     },
              //                   )
              //                 ],
              //               ));
              //     },
              //     codeAutoRetrievalTimeout: (String verificationId) {
              //       verificationId = verificationId;
              //       print(verificationId);
              //       print("Timout");
              //     });
              // },
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
