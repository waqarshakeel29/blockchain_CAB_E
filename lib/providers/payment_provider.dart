import 'package:flutter/material.dart';

import '../order.dart';

class PaymentProvider {
  ValueNotifier<Order> currentOrder = ValueNotifier(null);

  setOrder(Order order) {
    currentOrder.value = order;
  }
}
