import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class EthereumService {
  late Web3Client _client;
  late EthPrivateKey _credentials;
  late DeployedContract _contract;

  final String rpcUrl = "https://sepolia.infura.io/v3/CHANGE_ME";
  final String privateKey = "CHANGE_ME";
  final String contractAddress = "CHANGE_ME";

  EthereumService() {
    _client = Web3Client(rpcUrl, Client());
    _credentials = EthPrivateKey.fromHex(privateKey);
  }

  Future<void> initContract() async {
    String jsonContent = await rootBundle.loadString('assets/DIDRegistry.json');
    var jsonData = jsonDecode(jsonContent);

    if (jsonData["abi"] == null) {
      throw Exception("Invalid ABI file: Missing 'abi' key");
    }

    String abi = jsonEncode(jsonData["abi"]); // Extract ABI part
    _contract = DeployedContract(
      ContractAbi.fromJson(abi, "DIDRegistry"),
      EthereumAddress.fromHex(contractAddress),
    );
  }

  Future registerUser(String firstName, String lastName, String dateOfBirth) async {
    await initContract();
    final registerFunction = _contract.function("registerUser");

    final transaction = await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: registerFunction,
        parameters: [firstName, lastName, dateOfBirth],
      ),
      chainId: 11155111, // Sepolia Chain ID
    );
    return;
  }

  Future<Map<String, String>> getUser(String firstName, String lastName, String dateOfBirth) async {
    await initContract();
    final getUserFunction = _contract.function("getUser");

    final result = await _client.call(
      contract: _contract,
      function: getUserFunction,
      params: [firstName, lastName, dateOfBirth],
    );

    print(result);

    return {
      "firstName": result[0],
      "lastName": result[1],
      "dateOfBirth": result[2],
      "did": result[3]
    };
  }
}
