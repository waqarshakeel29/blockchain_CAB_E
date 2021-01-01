import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'network_provider.dart';

class WalletProvider {
  final networkProvider = GetIt.I<NetworkProvider>();
  ValueNotifier<double> balance = ValueNotifier(null);

  getBalance() {
    return networkProvider.getBalance(BigInt.parse("1"));
  }
}
