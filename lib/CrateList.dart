import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/Model/Crate.dart';
import 'CrateEdit.dart';
import '/Service/SiccApi.dart';
import 'package:uuid/uuid.dart';

class CrateList extends StatefulWidget {
  const CrateList({Key? key}) : super(key: key);

  @override
  State<CrateList> createState() => _CrateListState();
}

class _CrateListState extends State<CrateList> {

  final SiccApi api = SiccApi();

  late SharedPreferences _prefs;
  bool isLoaded = false;

  void _loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
      isLoaded = true;
    });
  }

  @override
  void initState() {
    _loadPrefs();
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return !isLoaded ? const CircularProgressIndicator() : Scaffold(
        body: Stack(children: <Widget>[
          FutureBuilder(
            future: api.getCrates(),
            builder: (BuildContext context, AsyncSnapshot<List<Crate>> snapshot) {

              List<Crate>? crates = snapshot.data;
              if (crates != null) {

                // Extract all crates from tree
                List<Crate> crate_queue = crates.toList();
                List<Crate> crates_flat = [];

                int queueSize = crate_queue.length;
                while(queueSize > 0)
                {
                    Crate c = crate_queue.removeLast();
                    queueSize--;
                    queueSize += c.crates.length;
                    crate_queue.addAll(c.crates);

                    crates_flat.add(c);
                }

                // Sort crates by alphabetical order
                crates_flat.sort((a, b) {
                  return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                });

                return ListView(
                  children: crates_flat
                      .map((Crate c) => ListTile(
                    title: Text(c.name),
                    subtitle: Text("${c.countItems()} items${c.countChildCrates() > 0 ? " ${c.countChildCrates()} crates" : ""}"),
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
                            MaterialPageRoute(builder: (context) => CrateEdit(crate: c, isNameEditable: false,))
                        )
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
                    items: [defaultItem],
                    crates: []
                );

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CrateEdit(crate: newCrate, isNameEditable: true)))
                    .then((value) => {setState(() {})});
              },
              child: const Icon(Icons.add),
            ),
          ),
          Positioned(
            left: 30.0,
            bottom: 40.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    "Loggued as ${_prefs.getString(SiccApi.username) ?? ""}",
                    style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12.0)
                ),
                FutureBuilder(
                  future: api.getPIN(),
                  builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {

                    if(!snapshot.hasData && snapshot.data != null){
                      return const Text("Unable to retrieve PIN",  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14.0));
                    }
                    return Text(
                        "PIN Code: ${snapshot.data}",
                        style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12.0)
                    );
                  }
                )
              ]
            )
          )
        ]));
  }
}