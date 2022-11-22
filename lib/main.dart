import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sicc/Config.dart';
import 'package:sicc/Home.dart';
import 'Service/SiccApi.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(const SICCMain());
}

class SICCMain extends StatefulWidget {

  const SICCMain({super.key});

  @override
  State<StatefulWidget> createState() => _SICCMainState();

}

class _SICCMainState extends State<SICCMain> {

  late SharedPreferences _prefs;

  void loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
    });
  }

  @override
  void initState() {
    loadPrefs();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    
    
    return MaterialApp(
      initialRoute: (SiccApi.isConfigured(_prefs) ? "/" : "/config"),
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const Home(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/config': (context) => const Config(),
      },
    );
  }
}