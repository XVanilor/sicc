import 'package:flutter/material.dart';
import 'package:sicc/CrateQR.dart';
import 'package:sicc/Model/Crate.dart';
import 'package:sicc/Service/SiccApi.dart';
import 'package:uuid/uuid.dart';

class CrateEdit extends StatefulWidget {
  final Crate crate;

  const CrateEdit({Key? key, required this.crate}) : super(key: key);

  @override
  State<CrateEdit> createState() => _CrateEditState();
}

class _CrateEditState extends State<CrateEdit> {
  bool changeMade = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Edit a Crate"), actions: <Widget>[
          IconButton(
              onPressed: () {
                setState(() {
                  Item newItem = Item(
                      uuid: const Uuid().v4(), name: "New Item", quantity: 1);
                  widget.crate.items.add(newItem);
                  changeMade = true;
                });
              },
              icon: const Icon(Icons.add)),
          IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () async {
                // Generate the QRCode with embarked UUIDv4 of the crate
                /**
                    @TODO
                    Implement 2 types of API token: Creator's and Reader's. Reader's may be anonymous. It's like public and private key, everyone has your Creator Token (public key) but you're the only one to have access to your Reader Token
                    We need to ensure that no one from outside (ie: which did not scan the QR) can access RW to our data
                    Then, we need to pass a shared secret into the QR: This might be the Creator's public (but restricted) API token
                    The goal is to ensure that only user with physical access to the QR code is allowed to use it
                 */
                String qrCodeData =
                    "siccapp://${SiccApi.apiBaseUrl.replaceAll("https://", "").replaceAll("http://", "")}::${SiccApi.creatorApiToken}::${widget.crate.uuid}";
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CrateQR(qrData: qrCodeData, crateName: widget.crate.name))
                );
              }),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save data to API
              SiccApi api = SiccApi();
              api.saveCrate(widget.crate);

              // Go back to main activity
              Navigator.pop(context);
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
                      child:  Text(
                        widget.crate.name,
                        style: const TextStyle(
                          fontSize: 25.0,
                          //fontStyle: FontStyle.italic,
                          //fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.crate.items.length,
                  itemBuilder: (context, index) {
                    return _itemView(widget.crate, index);
                  },
                )
              ],
            ),
          ),
        ));
  }

  _itemView(Crate crate, itemIndex) {
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
                    changeMade = true;
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
                            crate.items[itemIndex].quantity--;

                            if (widget.crate.items[itemIndex].quantity <= 0) {
                              widget.crate.items.removeAt(itemIndex);
                            }

                            changeMade = true;
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
                            changeMade = true;
                          });
                        },
                        child: const Icon(Icons.add, color: Colors.blue),
                      ),
                    ]))
          ],
        ));
  }
}
