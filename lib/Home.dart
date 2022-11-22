import 'package:flutter/material.dart';
import 'package:sicc/Config.dart';
import 'QRScan.dart';
import 'CrateList.dart';

class Home extends StatelessWidget {

  const Home({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
        home: Builder(
          builder: (context) => DefaultTabController(
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
                  actions: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Config())
                        );
                      },
                      icon: const Icon(Icons.settings),
                    )
                  ],
                  automaticallyImplyLeading: false
              ),
              body: const TabBarView(
                children: [CrateList(), QRScan()],
              ),
            ),
          ),
        )
    );
  }
}