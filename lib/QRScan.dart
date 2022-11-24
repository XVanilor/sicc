import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sicc/Home.dart' as HomePage;
import "package:sicc/Service/SEPManager.dart";
import 'package:sicc/CrateEdit.dart';
import 'package:sicc/Model/Crate.dart';
import 'package:sicc/Service/SiccApi.dart';

class QRScan extends StatefulWidget {
  const QRScan({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScanState();
}

class _QRScanState extends State<QRScan> {

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  SiccApi api = SiccApi();
  Barcode? result;
  QRViewController? controller;

  late SharedPreferences _prefs;

  bool dialogOpened = false;
  bool crateLoaded = false;
  String username = "";

  void _loadPrefs() async {
    SharedPreferences prefs  = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      _loadPrefs();
    });
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 4,
              child: _QRView(context),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  _QRView(BuildContext context) {

    if(result != null) {
      // QR Code was scanned. Enroll our user
      final rawData = result!.code ?? "No data";

      if (!rawData.startsWith("siccapp://")) {
        _showDialog("Unrecognized QR Code. In case of an error, please ask your app administrator", (){});
      }
      else {
        SEPQrData? qrData = SEPManager.decodeQRData(rawData);
        if (qrData == null) {
          _showDialog("Unrecognized QR Code. In case of an error, please ask your app administrator", (){});
        }
        // QR Code is valid. Processing user's enrollment
        else {
          // Api is configured. Retrieve the crate directly and move on
          if (SiccApi.isConfigured(_prefs)) {
            _getCrate(context, qrData.crateUuid);
          }
          // Api is not configured. Asks for username and starts enrollment process
          else {
            _showUsernameConfigurationDialog(qrData);
          }
        }
      }
    }

    return QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
        borderColor: Colors.orange,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 300,
      )
    );
  }

  Future<void> _showDialog(String message, VoidCallback _callback) async {

    if(dialogOpened) {
      return;
    }

    await Future.delayed(Duration.zero, (){});
    dialogOpened = true;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Close'),
              onPressed: () {

                dialogOpened = false;
                Navigator.of(context).pop();
                _callback();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _showUsernameConfigurationDialog(SEPQrData qrData) async {

    if(dialogOpened) {
      return;
    }

    await Future.delayed(Duration.zero, (){});
    dialogOpened = true;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Configuration"),
          content: TextField(
            onChanged: (value) { username = value; },
            controller: TextEditingController(text: username),
            decoration: const InputDecoration(hintText: "Your name"),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Apply'),
              onPressed: () {

                api.configureEnrollment(qrData.apiUrl, username, qrData.enrollmentToken).then((configurationSucceed) {

                  setState((){});

                  if(configurationSucceed)
                  {
                    dialogOpened = false;
                    _getCrate(context, qrData.crateUuid);
                  }
                }).onError((error, stackTrace)  {

                  dialogOpened = false;
                  setState(() {});

                  _showDialog(error.toString(), (){});

                });

                // Update app with configuration data
                setState(() {});
                Navigator.of(context).pop();

              },
            )
          ],
        );
      },
    );
  }

  void _getCrate(BuildContext context, String crateUuid) {

    if(!crateLoaded) {
        api.getCrate(crateUuid).then((Crate? crate){

          crateLoaded = true;
          setState(() {});

          if(crate == null)
          {
            _showDialog("Crate was not found in inventory", (){

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => HomePage.Home(HomePage.Page.crateList)),
                  (r){
                    return false;
                  });
            });
          }
          else
          {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => CrateEdit(crate: crate, isNameEditable: false)));
          }
        });
      }
  }
}