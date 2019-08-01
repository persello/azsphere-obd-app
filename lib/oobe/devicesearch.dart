import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/globals.dart';
import 'package:wifi/wifi.dart';

/// Device search and listing page (third one)
class DeviceSearchPage extends StatefulWidget {
  DeviceSearchPage({Key key, this.title}) : super(key: key);

  final String title;
  List<String> availableIpAddresses = List<String>();

  @override
  _DeviceSearchPageState createState() => _DeviceSearchPageState();

  void scan() async {
    final String ip = await Wifi.ip;
    final String subnet = ip.substring(0, ip.lastIndexOf('.'));

    for (int j = 0; j <= 255; j++) {
      String address = subnet + "." + j.toString();
      print("Trying to connect to $address.");
      await Socket.connect(address, 15500, timeout: Duration(milliseconds: 10))
          .then((Socket _socket) {
        _socket.listen(data);
      }).catchError((e) {
        if (e.toString().startsWith("SocketException: OS Error")) {
          availableIpAddresses.add(address);
        }
      });
    }
  }

  void data(data) {
    print("DATA RECEIVED: " + new String.fromCharCodes(data).trim());
  }
}

class _DeviceSearchPageState extends State<DeviceSearchPage> {
  @override
  Widget build(BuildContext context) {
    widget.scan();

    return CupertinoPageScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Center(
              child: Text(
                widget.title,
                style: CustomCupertinoTextStyles.lightBigTitle,
              ),
            ),
            padding: EdgeInsets.only(top: 120),
          ),
          Container(
              child: Center(
            child: CupertinoActivityIndicator(
              animating: true,
            ),
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
                    }),
                CupertinoButton(
                  child: Text("Continue"),
                  color: CustomCupertinoColors.systemBlue,
                  onPressed: null,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
