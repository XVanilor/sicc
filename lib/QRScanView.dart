import "package:flutter/material.dart";
import 'QRScan.dart';

/// This class should only be used when dev wants to show a back navbar for QRScan view
/// (aka: Don't generate it with standard Home view)
class QRScanView extends StatelessWidget {

  const QRScanView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title: const Text('Scan me !')),
        body: const QRScan()
    );
  }



}