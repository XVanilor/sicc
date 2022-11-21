import 'package:flutter/material.dart';
import 'QRScan.dart';
import 'CrateList.dart';

void main() {
  runApp(const SICCMain());
}

class SICCMain extends StatelessWidget {
  const SICCMain({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.format_list_bulleted)),
                Tab(icon: Icon(Icons.qr_code_outlined))
              ],
            ),
            title: const Text('SICC Application'),
          ),
          body: const TabBarView(
            children: [CrateList(), QRScan()],
          ),
        ),
      ),
    );
  }
}