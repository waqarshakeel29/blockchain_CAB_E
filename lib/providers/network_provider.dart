import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import '../constants.dart';

class NetworkProvider {
  Client httpClient;
  Web3Client ethClient;

  init() {
    httpClient = new Client();
    ethClient = new Web3Client(
        "https://ropsten.infura.io/v3/06f24ed76b204d98a4543e04cded9f6c",
        httpClient);
    // ethClient = new Web3Client("HTTP://10.0.2.2:7545", httpClient);
  }

  Future<String> sendTo(
      BigInt senderId, BigInt receiverId, BigInt amount) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddressHex);

    var response = await submit("sendTo", [senderId, receiverId, amount]);
    // hash of the transaction
    return response;
  }

  Future<List<dynamic>> getBalance(BigInt id) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddressHex);
    // getBalance transaction
    List<dynamic> result = await query("getBalance", [id]);
    // returns list of results, in this case a list with only the balance
    return result;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(PRIVATE_ADDRESS);

    DeployedContract contract = await loadContract();

    final ethFunction = contract.function(functionName);

    var result = await ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: ethFunction,
          parameters: args,
        ),
        fetchChainIdFromNetworkId: true);
    return result;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final data = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return data;
  }

  Future<DeployedContract> loadContract() async {
    String abiCode = await rootBundle.loadString("assets/abi.json");
    String contractAddress = CONTRACT_ADDRESS;

    final contract = DeployedContract(ContractAbi.fromJson(abiCode, "Payment"),
        EthereumAddress.fromHex(contractAddress));
    return contract;
  }
}
