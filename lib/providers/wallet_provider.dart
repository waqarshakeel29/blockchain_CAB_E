import 'package:flutter/material.dart';

class WalletProvider {
  ValueNotifier<double> balance = ValueNotifier(null);

  double getBalance() {
    return balance.value;
  }
}
