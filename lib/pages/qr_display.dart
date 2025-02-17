import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRDisplayPage extends StatefulWidget {
  @override
  _QRDisplayPageState createState() => _QRDisplayPageState();
}

class _QRDisplayPageState extends State<QRDisplayPage> {
  String did = "";

  @override
  void initState() {
    super.initState();
    _loadDID();
  }

  Future<void> _loadDID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      did = prefs.getString("did") ?? "N/A";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display QR Code')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show this QR to authenticate',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  did.isEmpty || did == "N/A"
                      ? CircularProgressIndicator()  // Show loading indicator if DID is not yet loaded
                      : QrImageView(
                    data: did,
                    version: QrVersions.auto,
                    size: 300.0,
                  ),
                  SizedBox(height: 20),
                  Text('DID: $did', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
