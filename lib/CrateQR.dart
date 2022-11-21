import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CrateQR extends StatelessWidget {

  final String qrData;
  final String crateName;

  const CrateQR({Key? key, required this.qrData, required this.crateName}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: const Text("Screenshot me !")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              QrImage(
                data: qrData,
                version: QrVersions.auto,
                size: 325,
                gapless: false,
              ),
              FittedBox(
                  fit: BoxFit.cover,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      crateName.toUpperCase(),
                      style: const TextStyle(fontSize: 100),
                    ),
                  )

              ),

            ],
          )
        )
    );
  }
}