import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cab_e/payment_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class MyScan extends StatefulWidget {
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
        backgroundColor: Colors.grey[300],
        body: Builder(
          builder: (BuildContext context) {
            return ListView(
              children: <Widget>[
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
            );
          },
        ),
      ),
    );
  }

  Widget _buttonGroup() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 120,
            child: InkWell(
              onTap: _scan,
              child: Card(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Image.asset('images/scanner.png'),
                    ),
                    Divider(height: 20),
                    Expanded(flex: 1, child: Text("Scan")),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
                  builder: (context) => PaymentScreen(fare: barcode))));
    }
  }
}
