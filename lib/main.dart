import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAOIWqlr04y3whCTniOlAN9-mcWM2i1Hfc",
      appId: "1:240147061006:android:f36365cf1061307007df5f",
      messagingSenderId: "240147061006",
      projectId: "taxagorgeta.firebasestorage.app",
      databaseURL: "https://taxagorgeta-default-rtdb.firebaseio.com/",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? _taxa;
  String? _valorComTaxa;
  String? _valorDaTaxa;
  TextEditingController _valorController = TextEditingController();
  TextEditingController _taxaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gettaxaInf();
  }

  // Função para pegar a versão do Firebase
  Future<void> _gettaxaInf() async {
    final event = await _database.child('taxa').once();
    setState(() {
      _taxa = event.snapshot.value?.toString();
    });
  }

  // Função para atualizar a versão no Firebase
  Future<void> _atualizarTaxa() async {
    if (_taxaController.text.isNotEmpty) {
      await _database.child('taxa').set(_taxaController.text);
      _gettaxaInf();
      _taxaController.clear();
    }
  }

  Future<void> _calcularTaxa() async {
    if (_valorController.text.isNotEmpty && _taxa != null) {
      double valor = double.parse(_valorController.text);
      double taxa = double.parse(_taxa!);

      double valorDaTaxa = valor * taxa / 100;
      setState(() {
        _valorDaTaxa = valorDaTaxa.toStringAsFixed(2);
      });

      double valorComTaxa = valor + (valor * taxa / 100);
      setState(() {
        _valorComTaxa = valorComTaxa.toStringAsFixed(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("taxa do Firebase")),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _taxaController,
                decoration: InputDecoration(labelText: "Digite a nova taxa"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _atualizarTaxa,
              child: Text("Atualizar taxa"),
            ),
            _taxa != null
                ? Text("Taxa atual: $_taxa%")
                : CircularProgressIndicator(),
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _valorController,
                decoration: InputDecoration(
                  labelText: "Digite o valor da conta",
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _calcularTaxa,
              child: Text("Calcular valor com taxa"),
            ),
            _valorComTaxa == null
                ? Container()
                :Text("Valor com taxa: $_valorComTaxa"),
            _valorDaTaxa == null
                ? Container()
                :Text("Valor da taxa: $_valorDaTaxa"),
          ],
        ),
      ),
    );
  }
}
