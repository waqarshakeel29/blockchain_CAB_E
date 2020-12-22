import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cab_e/payment_screen.dart';
import 'package:cab_e/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import 'order.dart';

class MyScan extends StatefulWidget {
  Order order;
  MyScan(this.order);
  @override
  _MyScanState createState() => _MyScanState();
}

class _MyScanState extends State<MyScan> {
  Uint8List bytes = Uint8List(0);
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
        backgroundColor: Colors.white,
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      "You need to scan QR to pay the fare.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 25,
                          color: AppColor.primaryDark,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        this._buttonGroup(),
                        SizedBox(height: 70),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buttonGroup() {
    return MaterialButton(
      minWidth: MediaQuery.of(context).size.width * 0.6,
      color: AppColor.primaryYellow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Text(
        "SCAN QR",
        style:
            TextStyle(color: AppColor.primaryDark, fontWeight: FontWeight.bold),
      ),
      onPressed: _scan,
    );
  }

  Future _scan() async {
    String barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      print(barcode + " asdasdasdasd ---------- sdasdasd");
      Future.delayed(
          Duration(milliseconds: 1000),
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PaymentScreen(fare: barcode,order: widget.order))));
    }
  }
}
