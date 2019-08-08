import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/classes/device.dart';
import 'package:azsphere_obd_app/globals.dart';

class AddNetworksPage extends StatefulWidget {
  AddNetworksPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddNetworksPageState createState() => _AddNetworksPageState();
}

class _AddNetworksPageState extends State<AddNetworksPage> {
  List<WiFiNetwork> networks = List<WiFiNetwork>();

  @override
  void initState() {
    super.initState();
    //globalScanner.connect();
    globalScanner.onConnectionChanged = connectionChanged;
    globalScanner.onMessageReceived = messageReceived;
    requestNetworks();
  }

  void requestNetworks() {
    globalScanner
        .sendMessage(TCPMessage(header: MessageHeader_ScanWiFiNetworks));
    globalScanner
        .sendMessage(TCPMessage(header: MessageHeader_KnownWiFiNetworks));
  }

  void connectionChanged(OBDScanner s, OBDScannerConnectionStatus status) {
    if (status == OBDScannerConnectionStatus.STATUS_DISCONNECTED) {
      s.connect();
    }
  }

  void messageReceived(OBDScanner s, TCPMessage m) {
    if (m.header == MessageHeader_ScanWiFiNetworks ||
        m.header == MessageHeader_KnownWiFiNetworks) {
      setState(() {
        networks = globalScanner.networks;
      });
      // Let's update after each ping
    } else if (m.header == MessageHeader_Ping) {
      requestNetworks();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort the list every time by RSSI
    if (networks.length > 1) {
      networks.sort((a, b) {
        // RSSI is negative!
        return -(a.rssi.compareTo(b.rssi));
      });
    }

    return CupertinoPageScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 120),
            child: Center(
              child: Text(
                widget.title,
                style: CustomCupertinoTextStyles.lightBigTitle,
              ),
            ),
          ),
          Container(
              height: 400,
              child: ListView.builder(
                itemCount: globalScanner.networks.length,
                itemBuilder: (BuildContext context, int index) {
                  // TODO: correct RSSI
                  return new ListWiFiItem(
                      networks[index].ssid,
                      WiFiNetwork.rssiToDots(networks[index].rssi),
                      networks[index].isConnected,
                      networks[index].isProtected,
                      networks[index].isSaved,
                      (s, b) {},
                      (s, b) {});
                },
              )),
          Container(
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CupertinoButton(
                    child: Text("Back"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      globalScanner.closeConnection();
                    }),
                CupertinoButton(
                  child: Text("Save to device"),
                  color: CustomCupertinoColors.systemBlue,
                  onPressed: () {},
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
