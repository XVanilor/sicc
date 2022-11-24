import 'package:flutter/material.dart';
import 'Config.dart';
import 'Home.dart' as HomePage;
import 'QRScan.dart';

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
        '/': (context) => HomePage.Home(HomePage.Page.crateList),
        '/config': (context) => const Config(),
        '/qrscan': (context) => const QRScan()
      },
    );
  }
}