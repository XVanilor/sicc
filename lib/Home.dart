import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sicc/Config.dart';
import 'package:sicc/Service/SiccApi.dart';
import 'QRScan.dart';
import 'CrateList.dart';

class Home extends StatelessWidget {

  int selectedPage;
  Home(this.selectedPage, {super.key});

  Future<SharedPreferences> _loadPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: _loadPrefs(),
        builder: (BuildContext context, AsyncSnapshot<SharedPreferences>snapshot) {

          if (snapshot.hasData && snapshot.data != null && !SiccApi.isConfigured(snapshot.data!)) {
            return const Config();
          }

          return _home(context);
        });
  }

  _home(BuildContext context) {

    return DefaultTabController(
            initialIndex:selectedPage,
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
          );
  }
}