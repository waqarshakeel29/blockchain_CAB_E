import 'package:cab_e/main.dart';
import 'package:cab_e/map_screen.dart';
import 'package:cab_e/providers/network_provider.dart';
import 'package:cab_e/shared/constants.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'package:intl/intl.dart';

import 'order.dart';

class EndScreen extends StatefulWidget {
  EndScreen({Key key, this.fare, this.order}) : super(key: key);
  String fare;
  Order order;
  @override
  State<StatefulWidget> createState() {
    return EndScreenState();
  }
}

class EndScreenState extends State<EndScreen> {
  final networkProvider = GetIt.I<NetworkProvider>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE dd MMM').format(now);
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Thanks for the Payment",
          style: TextStyle(
              color: AppColor.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        Align(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Source",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Spacer(
                              flex: 2,
                            ),
                            Text(
                              widget.order.sourceLocationName,
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
                              "Paid Fare",
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
                        FutureBuilder(
                          future: networkProvider.getBalance(BigInt.parse("1")),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  Text(
                                    'Your Remaining Balance',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    '${snapshot.data[0]}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30),
                                  ),
                                ],
                              );
                            } else
                              return Text('Loading...');
                          },
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
        MaterialButton(
          minWidth: MediaQuery.of(context).size.width * 0.6,
          color: AppColor.primaryYellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Text(
            "Home",
            style: TextStyle(
                color: AppColor.primaryDark, fontWeight: FontWeight.bold),
          ),
          onPressed: () async {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MapScreen()));

            // getBalance("0x6096dBD5203A87C9a6426AEd4257Fd83fF02B20C");
          },
        ),
      ],
    ));
  }
}
