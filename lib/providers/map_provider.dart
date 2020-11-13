import 'package:flutter/material.dart';

import '../order.dart';

class MapProvider {
  ValueNotifier<Order> currentOrder = ValueNotifier(null);
  ValueNotifier<bool> isFindingOrder = ValueNotifier(false);
}
