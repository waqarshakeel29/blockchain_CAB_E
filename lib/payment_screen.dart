import 'package:cab_e/constants.dart';
import 'package:cab_e/providers/network_provider.dart';
import 'package:cab_e/providers/payment_provider.dart';
import 'package:cab_e/shared/constants.dart';
import 'package:cab_e/EndScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:intl/intl.dart';

import 'model/order.dart';

class PaymentScreen extends StatefulWidget {
  PaymentScreen({Key key, this.fare, this.order}) : super(key: key);
  String fare;
  Order order;
  @override
  State<StatefulWidget> createState() {
    return PaymentScreenState();
  }
}

class PaymentScreenState extends State<PaymentScreen> {
  final networkProvider = GetIt.I<NetworkProvider>();
  final paymentProvider = GetIt.I<PaymentProvider>();

  @override
  void initState() {
    paymentProvider.setDetails("1", widget.order.sourceLocationName,
        widget.order.destLocationName, widget.fare);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE dd MMM').format(now);
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Payment",
          style: TextStyle(
              color: AppColor.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        SizedBox(
          height: 20,
        ),
        Align(
          child: Container(
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 30,
                ),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Waqar Shakeel",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                SizedBox(
                  height: 40,
                ),
                Divider(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 40, right: 40, top: 10, bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Date",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Spacer(
                              flex: 2,
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              "Source",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            SizedBox(width: 42),
                            Container(
                              width: 150,
                              child: Text(
                                widget.order.sourceLocationName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Destination",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Spacer(
                              flex: 2,
                            ),
                            Text(
                              widget.order.destLocationName,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Trip Fare",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Spacer(
                              flex: 2,
                            ),
                            Text(
                              widget.fare != null
                                  ? widget.fare + " PKR"
                                  : "0 PKR",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Subtotal",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Spacer(
                              flex: 2,
                            ),
                            Text(
                              widget.fare != null
                                  ? widget.fare + " PKR"
                                  : "0 PKR",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Spacer(
                              flex: 2,
                            ),
                            Text(
                              widget.fare != null
                                  ? widget.fare + " PKR"
                                  : "0 PKR",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            decoration: new BoxDecoration(
                color: AppColor.primaryYellow,
                borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(20.0),
                  topRight: const Radius.circular(20.0),
                  bottomLeft: const Radius.circular(20.0),
                  bottomRight: const Radius.circular(20.0),
                )),
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        MaterialButton(
          minWidth: MediaQuery.of(context).size.width * 0.6,
          color: AppColor.primaryYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Text(
            "Pay Now",
            style: TextStyle(
                color: AppColor.primaryDark, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            print("ASDFASDASDFASDA-------");
            var result = await networkProvider.sendTo(
                BigInt.parse("1"),
                BigInt.parse("2"),
                BigInt.parse(double.parse(widget.fare)
                    .toInt()
                    .toString())); //result contains last transaction hash

            setState(() {
              // lastTransactionHash = result;
              print("ASDFASDASDFASDA-------");
              // print(lastTransactionHash);
              // _scaffoldStateKey.currentState.showSnackBar(
              //     new SnackBar(content: new Text("Wrong Credencials!")));
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EndScreen(
                            fare: widget.fare,
                            order: widget.order,
                          )));
            });
            // getBalance("0x6096dBD5203A87C9a6426AEd4257Fd83fF02B20C");
          },
        ),
      ],
    ));
  }

  // final _scaffoldStateKey = GlobalKey<ScaffoldState>(debugLabel: "Login");
}
