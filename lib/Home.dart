import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Config.dart';
import '/Service/SiccApi.dart';
import 'QRScan.dart';
import 'CrateList.dart';

enum Page {
  crateList, qrScan
}

class Home extends StatelessWidget {

  Page selectedPage = Page.crateList;

  Home(this.selectedPage, {super.key});

  Future<SharedPreferences> _loadPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: _loadPrefs(),
        builder: (BuildContext context, AsyncSnapshot<SharedPreferences>snapshot) {

          // Check if API if configured
          if (snapshot.hasData && snapshot.data != null && !SiccApi.isConfigured(snapshot.data!))
          {
            // If not, send Configuration page
            return const Config();
          }

          // If API is configured, get to home
          return _home(context);
        });
  }

  _home(BuildContext context) {

    return DefaultTabController(
            initialIndex:selectedPage.index,
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