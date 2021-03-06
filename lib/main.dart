import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/browser.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Client httpClient;
  late Web3Client ethClient;
  String rpcUrl = 'HTTP://127.0.0.1:7545';

  @override
  void initState() {
    initialSetup();
    super.initState();
  }

  Future<void> initialSetup() async {
    httpClient = Client();
    ethClient = Web3Client(rpcUrl, httpClient);

    await getCredentials();
    await getDeployedContract();
    await getContractFunctions();
  }

  String privateKey =
      'e646e58e34d0b95b884a2e340282ab275833ff3bf21a55db371f5dcd0091b6f8';
  late Credentials credentials;
  late EthereumAddress myAddress;

  Future<void> getCredentials() async {
    credentials = await EthPrivateKey.fromHex(privateKey);
    myAddress = await credentials.extractAddress();
  }

  late String abi;
  late EthereumAddress contractAddress;

  Future<void> getDeployedContract() async {
    String abiString = await rootBundle.loadString('src/abis/SupplyChain.json');
    var abiJson = jsonDecode(abiString);
    abi = jsonEncode(abiJson['abi']);

    contractAddress =
        EthereumAddress.fromHex(abiJson['networks'][5777]['address']);
  }

  late DeployedContract contract;
  late ContractFunction initializeCargo;
  late ContractFunction cargoBought;
  late ContractFunction customsCheck;
  late ContractFunction cargoShipping;
  late ContractFunction cargoReceieved;
  late ContractFunction viewCargo;

  Future<void> getContractFunctions() async {
    contract = DeployedContract(
        ContractAbi.fromJson(abi, "SupplyChain"), contractAddress);

    initializeCargo = contract.function('initializeCargo');
    cargoBought = contract.function('cargoBought');
    customsCheck = contract.function('customsCheck');
    cargoShipping = contract.function('cargoShipping');
    cargoReceieved = contract.function('cargoReceieved');
    viewCargo = contract.function('viewCargo');
  }

  Future<List<dynamic>> readContract(
    ContractFunction functionName,
    List<dynamic> functionArgs,
  ) async {
    var queryResult = await ethClient.call(
      contract: contract,
      function: functionName,
      params: functionArgs,
    );

    return queryResult;
  }

  Future<void> writeContract(
    ContractFunction functionName,
    List<dynamic> functionArgs,
  ) async {
    await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: functionName,
        parameters: functionArgs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Supply Chain Block Chain"),
        ),
        body: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(
                onPressed: () async {
                  var result = await readContract(initializeCargo, []);
                },
                child: Text("Initialize Cargo")),
            Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(
                onPressed: () async {
                  var result = await readContract(cargoBought, []);
                },
                child: Text("Buy Cargo")),
            Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(
                onPressed: () async {
                  var result = await readContract(customsCheck, []);
                },
                child: Text("Customs Check")),
            Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(
                onPressed: () async {
                  var result = await readContract(cargoShipping, []);
                },
                child: Text("Ship Cargo")),
            Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(
                onPressed: () async {
                  var result = await readContract(cargoReceieved, []);
                },
                child: Text("Cargo Received")),
            Padding(padding: EdgeInsets.all(5)),
            ElevatedButton(
                onPressed: () async {
                  var result = await readContract(viewCargo, []);
                },
                child: Text("View Cargo")),
          ],
        ));
  }
}
