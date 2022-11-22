import 'package:flutter/material.dart';
import 'package:sicc/Config.dart';
import 'package:sicc/Home.dart';
import 'package:sicc/QRScan.dart';

void main() {

  runApp(SICCMain());
}

class SICCMain extends StatelessWidget {

  const SICCMain({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      initialRoute: "/",
      routes: {
        '/': (context) => Home(0),
        '/config': (context) => const Config(),
        '/qrscan': (context) => const QRScan()
      },
    );
  }
}