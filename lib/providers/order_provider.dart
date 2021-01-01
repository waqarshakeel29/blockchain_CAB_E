import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/order.dart';

class OrderProvider {
  ValueNotifier<Order> currentOrder = ValueNotifier(null);
  ValueNotifier<bool> isFindingOrder = ValueNotifier(false);
  StreamSubscription<DocumentSnapshot> orderListener = null;

//   void sendNotification(String functionName, String orderId) async {
//     final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
//       functionName: functionName,
//     );
// //                                      Map<String, dynamic> data = {};
//     Map<String, dynamic> data = {"orderId": orderId};
// //                                      data.putIfAbsent("data", () => order.toJson());
//     HttpsCallableResult resp = await callable.call(data);

// //    final result = Map<String, dynamic>.from(resp.data);
//   }

  Future<bool> uploadOrderNow(Order order) async {
    currentOrder.value = order;
    await FirebaseFirestore.instance
        .collection("order")
        .doc(order.orderId)
        .set(order.toMap())
        .timeout(Duration(seconds: 5), onTimeout: () {
      return false;
    });
    return true;
  }

  void listenOrder(String orderId, VoidCallback _onTap) {
    var col = FirebaseFirestore.instance.collection("order").doc(orderId);
    orderListener = col.snapshots().listen((event) {
      if (event.exists) {
        currentOrder = ValueNotifier(Order.fromMap(event.data()));
        if (currentOrder.value.driverLat != null) {
          print("LISTEN ------- " +
              currentOrder.value.status.index.toString() +
              " ---- " +
              currentOrder.value.driverId);
          currentOrder.notifyListeners();
          _onTap();
        }
      }
    });

    // FirebaseFirestore.instance
    //     .collection("order")
    //     .doc(orderId)
    //     .snapshots()
    //     .listen((event) {
    //       if(event.exists) {
    //           currentOrder = ValueNotifier(Order.fromMap(event.data()));
    //           if(currentOrder.value.status != OrderStatus.orderCompleted) {
    //           if (currentOrder.value.messengerLat != null) {
    //             print("LISTEN ------- " + currentOrder.value.toString());
    //             currentOrder.notifyListeners();
    //             _onTap();
    //           }
    //         }
    //       }
    //     });
  }

}
