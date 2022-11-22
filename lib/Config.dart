import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'Service/SiccApi.dart';

class Config extends StatefulWidget {

  const Config({Key? key}) : super(key: key);

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {

  SharedPreferences? _prefs;

  void loadPrefs() async {
    SharedPreferences prefs  = await SharedPreferences.getInstance();
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

    final _formKey = GlobalKey<FormState>();
    String? apiUrl = "";
    String? privKey = "";
    String? username = "";

    final SiccApi api = SiccApi();

    return Scaffold(
        appBar: AppBar(title: const Text("Configuration")),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              children: <Widget>[
                const Text(
                    "Configuration",
                    style: TextStyle(fontSize: 40.0)
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: <Widget>[
                      const Text(
                        "You can either:",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      TextButton(
                          onPressed: () { /* TODO Redirect to Scan QR page */},
                          child: const Text("Scan a QR Code", style: TextStyle(fontSize: 20.0))
                      ),
                      const Text(
                        "OR",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Column(
                            children: <Widget>[
                              const Text(
                                "Configure your API manually",
                                style: TextStyle(fontSize: 20.0),
                              ),
                              const Text(
                                "Only if you have the following requirements!",
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.grey
                                ),
                              ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: <Widget>[
                                    TextFormField(
                                      onSaved: (value){apiUrl=value;},
                                      decoration: const InputDecoration(
                                          hintText: "https://mysiccapi.app"
                                      ),
                                      initialValue: _prefs?.getString(SiccApi.apiUrlKey) ?? "",
                                      validator: (value) {
                                        if(value == null || value.isEmpty || Uri.tryParse(value) == null)
                                        {
                                          return "Please enter a valid URL";
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      onSaved: (value){username=value;},
                                      decoration: const InputDecoration(
                                          hintText: "Your name"
                                      ),
                                      initialValue: _prefs?.getString("username") ?? "",
                                      validator: (value) {
                                        if(value == null || value.isEmpty)
                                        {
                                          return "Username cannot be empty";
                                        }
                                        return null;
                                      },
                                    ),
                                    TextFormField(
                                      onSaved: (value){privKey=value;},
                                      decoration: const InputDecoration(
                                          hintText: "Your Private API Token"
                                      ),
                                      initialValue: _getVanishedPrivateApiToken(),
                                      validator: (value) {
                                        if(value == null || value.isEmpty || !Uuid.isValidUUID(fromString: value))
                                        {
                                          return "Please enter valid UUIDv4";
                                        }
                                        return null;
                                      },
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {

                                        if (_formKey.currentState!.validate()) {

                                          _formKey.currentState?.save();

                                          try {

                                            bool configOk = await api.configure(apiUrl!, username!, privKey!);
                                            setState(() {});

                                            if(configOk)
                                            {
                                              if (!mounted) return;
                                              Navigator.pushReplacementNamed(context, "/");
                                            }

                                          } catch(e)
                                          {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text("Error"),
                                                content: const Text("Cannot configure the app. Is your token valid ?"),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(ctx).pop();
                                                    },
                                                    child: Container(
                                                      color: Colors.green,
                                                      padding: const EdgeInsets.all(14),
                                                      child: const Text("Try again"),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text('Check Configuration'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {

                                        await SiccApi.resetConfig();
                                        setState(() {});
                                      },
                                      style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red)),
                                      child: const Text('Purge'),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )
    );
  }

  _getVanishedPrivateApiToken()
  {
    final String token = _prefs?.getString(SiccApi.privateApiTokenKey) ?? "";
    return token;
    return (token != "" ? "${token[0]}**********************************${token[token.length - 1]}" : "");
  }

}