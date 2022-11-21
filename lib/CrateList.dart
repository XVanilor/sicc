import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sicc/Model/Crate.dart';
import 'package:sicc/CrateEdit.dart';
import 'package:sicc/Service/SiccApi.dart';
import 'package:uuid/uuid.dart';

class CrateList extends StatefulWidget {
  const CrateList({Key? key}) : super(key: key);

  @override
  State<CrateList> createState() => _CrateListState();
}

class _CrateListState extends State<CrateList> {
  final SiccApi api = SiccApi();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
          FutureBuilder(
            future: api.getCrates(),
            builder: (BuildContext context, AsyncSnapshot<List<Crate>> snapshot) {
              List<Crate>? crates = snapshot.data;

              if(SiccApi.apiBaseUrl == "" || SiccApi.creatorApiToken == "")
                {
                  return _configurationView();
                }

              if (crates != null) {
                // Sort crates by alphabetical order
                crates.sort((a, b) {
                  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                });

                Crate debugApiCrate = Crate(name: SiccApi.apiBaseUrl, uuid: SiccApi.creatorApiToken, items: []);
                crates.insert(0, debugApiCrate);

                return ListView(
                  children: crates
                      .map((Crate c) => ListTile(
                            title: Text(c.name),
                            subtitle: Text("${c.items.length} items"),
                            trailing: IconButton(
                                onPressed: () {
                                  showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: const Text("Are you sure ?"),
                                            content: const Text(
                                                "You will need to print the QR Code again in case of a mistake"),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'Cancel'),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                  onPressed: () async {
                                                    await api.deleteCrate(c);

                                                    setState(() {});
                                                    if (!mounted) return;
                                                    Navigator.pop(context, 'OK');
                                                  },
                                                  child: const Text('OK')),
                                            ],
                                          ));
                                },
                                icon: const Icon(Icons.delete, color: Colors.red)),
                            onTap: () {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CrateEdit(crate: c)))
                                    .then((value) => {setState(() {})});
                              });
                            },
                          ))
                      .toList(),
                );
              }
              else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            right: 30.0,
            bottom: 30.0,
            child: FloatingActionButton(
              onPressed: () {
                Item defaultItem =
                    Item(uuid: const Uuid().v4(), name: "New Item", quantity: 1);
                Crate newCrate = Crate(
                    uuid: const Uuid().v4(),
                    name: "New Crate",
                    items: [defaultItem]);

                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CrateEdit(crate: newCrate)))
                    .then((value) => {setState(() {})});
              },
              child: const Icon(Icons.add),
            ),
          )
    ]));
  }

  _configurationView() {

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          children: const <Widget>[
            Text(
                "Configuration",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40.0)
            ),
            Text(
              "Add your configuration manually",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15.0, color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
