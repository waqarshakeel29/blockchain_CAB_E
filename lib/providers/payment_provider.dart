import 'package:cab_e/model/paymentInfo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'network_provider.dart';
import '../model/order.dart';

class PaymentProvider {
  final networkProvider = GetIt.I<NetworkProvider>();

  ValueNotifier<Order> currentOrder = ValueNotifier(null);
  ValueNotifier<PaymentInfo> payment = ValueNotifier(null);

  setOrder(Order order) {
    currentOrder.value = order;
  }

  setDetails(String id, String source, String destination, String fare) {
    var p = PaymentInfo();
    p.id = id;
    p.fare = fare;
    p.source = source;
    p.destination = destination;
    payment.value = p;
  }

  payBill() {
    networkProvider.sendTo(
        BigInt.parse("1"),
        BigInt.parse("2"),
        BigInt.parse(double.parse(payment.value.fare)
            .toInt()
            .toString())); //result contains last transaction hash
  }
}
