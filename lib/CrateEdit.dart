import 'CrateQR.dart';
import '/Model/Crate.dart';
import '/Service/SEPManager.dart';
import '/Service/SiccApi.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CrateEdit extends StatefulWidget {

  final bool isNameEditable;
  final returnToHomeOnBackward;
  final Crate crate;

  const CrateEdit({Key? key, required this.crate, required this.isNameEditable, this.returnToHomeOnBackward = false})
      : super(key: key);

  @override
  State<CrateEdit> createState() => _CrateEditState();
}

class _CrateEditState extends State<CrateEdit> {
  bool changeSaved = false;

  late SharedPreferences _prefs;
  SiccApi api = SiccApi();

  void loadPrefs() async {
    SharedPreferences prefs  = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPrefs();
  }

  @override
  Widget build(BuildContext context) {

    BuildContext ourContext = context;

    return Scaffold(
        appBar: AppBar(
            title: const Text("Edit a Crate"),
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    
                    if(changeSaved)
                      {
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) =>
                                AlertDialog(
                                  title: const Text("Alert"),
                                  content: const Text("Save your modifications ? They will be lost otherwise"),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(ourContext);
                                      },
                                      child: const Text('Quit Without Saving'),
                                    ),
                                    TextButton(
                                        onPressed: () async {

                                          await api.saveCrate(widget.crate);

                                          if (!mounted) return;
                                          Navigator.pop(context);
                                          Navigator.pop(ourContext);
                                        },
                                        child: const Text('Save and Quit')),
                                  ],
                                )
                        );
                      }
                    
                    else
                      {
                        if(widget.returnToHomeOnBackward) {
                          Navigator.pushReplacementNamed(context, "/");
                        } else {
                          Navigator.pop(context);
                        }
                      }
                  },
                );
              },
            ),
            actions: <Widget>[
          IconButton(
              onPressed: () {

                // Choose between adding a crate or an item
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Alert'),
                      content: const Text('Would you like to add a crate or an item ?'),
                      actions: <Widget>[
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          child: const Text('Crate'),
                          onPressed: () {

                            Item defaultItem = Item(uuid: const Uuid().v4(), name: "New Item", quantity: 1);
                            Crate newChildCrate = Crate(
                                uuid: const Uuid().v4(),
                                name: "New Crate",
                                items: [defaultItem],
                                crates: [],
                                parentUuid: widget.crate.uuid
                            );

                            widget.crate.crates.add(newChildCrate);
                            changeSaved = true;

                            setState(() {});

                            Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CrateEdit(crate: newChildCrate, isNameEditable: true)))
                                .then((value) => {setState(() {})});
                          },
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: Theme.of(context).textTheme.labelLarge,
                          ),
                          child: const Text('Item'),
                          onPressed: () {

                            setState(() {
                              Item newItem = Item(uuid: const Uuid().v4(), name: "New Item", quantity: 1);
                              widget.crate.items.add(newItem);
                              changeSaved = true;
                            });

                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.add)),
          IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () async {

                // Generate the QRCode with embarked UUIDv4 of the crate
                String qrCodeData = SEPManager.encodeQRData(
                    _prefs.getString(SiccApi.apiUrlKey) ?? "nullurl",
                    _prefs.getString(SiccApi.enrollmentToken) ?? "nulltoken",
                    widget.crate.uuid
                );
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CrateQR(qrData: qrCodeData, crateName: widget.crate.name))
                );
              }),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {

              // Save data to API
              api.saveCrate(widget.crate);
              // Go back to previous page
              Navigator.pop(context, "/");
            },
          )
        ]),
        body: Container(
          margin: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: _crateNameView(),
                    )
                ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: widget.crate.crates.length,
                itemBuilder: (context, index) {
                  return _crateView(widget.crate.crates[index]);
                },
              ),
                const Divider(),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.crate.items.length,
                  itemBuilder: (context, index) {
                    return _itemView(index);
                  },
                )
              ],
            ),
          ),
        ));
  }

  _itemView(itemIndex) {
    return Container(
        margin: const EdgeInsets.only(bottom: 10.0, top: 10.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                decoration:
                    const InputDecoration(border: UnderlineInputBorder()),
                autofocus: false,
                maxLines: 1,
                initialValue: widget.crate.items[itemIndex].name,
                onChanged: (text) {
                  setState(() {
                    widget.crate.items[itemIndex].name = text;
                    changeSaved = true;
                  });
                },
              ),
            ),
            Expanded(
                flex: 0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          setState(() {
                            widget.crate.items[itemIndex].quantity--;

                            if (widget.crate.items[itemIndex].quantity <= 0) {
                              widget.crate.items.removeAt(itemIndex);
                            }

                            changeSaved = true;
                          });
                        },
                        child:
                            const Icon(Icons.remove, color: Colors.deepOrange),
                      ),
                      Text(widget.crate.items[itemIndex].quantity.toString(),
                          style: const TextStyle(fontSize: 16.0)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            widget.crate.items[itemIndex].quantity++;
                            changeSaved = true;
                          });
                        },
                        child: const Icon(Icons.add, color: Colors.blue),
                      ),
                    ]))
          ],
        )
    );
  }

  _crateView(Crate c)
  {
    return Transform.translate(
        offset: const Offset(-16,0),
        child: ListTile(
        title: Text(c.name),
        subtitle: Text("${c.countItems()} items${c.countChildCrates() > 0 ? " ${c.countChildCrates()} crates" : ""}"),
        trailing: Transform.translate(offset: const Offset(26,0), child: IconButton(
            onPressed: () {
              showDialog<String>(
                  context: context,
                  builder: (BuildContext context) =>
                      AlertDialog(
                        title: const Text("Are you sure ?"),
                        content: const Text("You will need to print the QR Code again in case of a mistake"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(
                                context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                              onPressed: () {

                                setState(() {
                                  api.deleteCrate(c);
                                });

                                Navigator.pop(context, 'OK');
                              },
                              child: const Text('OK')),
                        ],
                      )
              );
            },
            icon: const Icon(Icons.delete, color: Colors.red))),
        onTap: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CrateEdit(crate: c, isNameEditable: false))
            )
                .then((value) => {setState(() {})});
          });
        })
    );
  }

  _crateNameView() {
    if (widget.isNameEditable) {
      return TextFormField(
        decoration: const InputDecoration(border: UnderlineInputBorder()),
        autofocus: false,
        maxLines: 1,
        initialValue: widget.crate.name,
        style: const TextStyle(fontSize: 25.0),
        onChanged: (text) {
          setState(() {
            widget.crate.name = text;
            changeSaved = true;
          });
        },
      );
    } else {
      return Text(
          widget.crate.name,
          style: const TextStyle(
            fontSize: 25.0,
            //fontStyle: FontStyle.italic,
            //fontWeight: FontWeight.bold
          )
      );
    }
  }
}
