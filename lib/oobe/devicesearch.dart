import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/globals.dart';
import 'package:flutter/semantics.dart';
import 'package:wifi/wifi.dart';
import 'package:azsphere_obd_app/classes/device.dart';

/// Device search and listing page (third one)
class DeviceSearchPage extends StatefulWidget {
  DeviceSearchPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DeviceSearchPageState createState() => _DeviceSearchPageState();
}

class DevicePageControlsState {
  DevicePageControlsState(
      {this.buttonEnabled, this.content, this.spinnerVisible, this.title});

  bool spinnerVisible;
  bool buttonEnabled;
  String title;
  String content;
}

enum CurrentStatus {
  WIFI_DISCONNECTED,
  SEARCHING,
  DEVICE_FOUND,
  DEVICE_BTN_WAIT,
  DEVICE_OOBE_DENIED,
  FINISHED
}

class _DeviceSearchPageState extends State<DeviceSearchPage> {
  final states = {
    CurrentStatus.WIFI_DISCONNECTED: DevicePageControlsState(
        buttonEnabled: false,
        content:
            "Before continuing, connect to a Wi-Fi network or set up your hotspot with the given properties.",
        spinnerVisible: false,
        title: "Connect"),
    CurrentStatus.SEARCHING: DevicePageControlsState(
        buttonEnabled: false,
        content: null,
        spinnerVisible: true,
        title: "Searching"),
    CurrentStatus.DEVICE_FOUND: DevicePageControlsState(
        buttonEnabled: false,
        content: null,
        spinnerVisible: true,
        title: "Found"),
    CurrentStatus.DEVICE_BTN_WAIT: DevicePageControlsState(
        buttonEnabled: false,
        content:
            "Please press the \"A\" button on the device to confirm the connection.",
        spinnerVisible: false,
        title: "Confirm"),
    CurrentStatus.DEVICE_OOBE_DENIED: DevicePageControlsState(
        buttonEnabled: false,
        content:
            "This device has already been set-up. If you want to reconfigure it, you'll need to reset it first.",
        spinnerVisible: false,
        title: "Error"),
    CurrentStatus.FINISHED: DevicePageControlsState(
        buttonEnabled: true,
        content: "We'll now proceed to adding some networks to the device.",
        spinnerVisible: false,
        title: "Connected")
  };

  List<OBDScanner> availableScanners = List<OBDScanner>();
  CurrentStatus currentSearchStatus;
  DevicePageControlsState devicePageControlsState;
  Timer scanTimer;
  String ip;
  bool goToNextIP = true;
  int j = 0;
  OBDScanner currentScanner;

  void initializeScan(Timer t) async {
    ip = await Wifi.ip;

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));

    if (goToNextIP && j < 255) {
      goToNextIP = false;
      j++;
      String address = subnet + "." + j.toString();
      print("Trying to connect to $address.");

      currentScanner = OBDScanner(
          ipAddress: address, onConnectionChanged: scannerStatusChanged);

      currentScanner.connect();
    } else if (j >= 255) {
      // TODO: loop finished
    }
  }

  void scannerStatusChanged(OBDScanner scanner, OBDScannerStatus status) {
    goToNextIP = true;
    if (status != OBDScannerStatus.STATUS_DISCONNECTED &&
        status != OBDScannerStatus.STATUS_UNKNOWN) {
      print("${scanner.ipAddress} is available!");
      if (!availableScanners.contains(scanner)) {
        availableScanners.add(scanner);
      }
      scanner.closeConnection();
    }
  }

  @override
  void initState() {
    super.initState();
    scanTimer = Timer.periodic(Duration(milliseconds: 50), initializeScan);
    currentSearchStatus = CurrentStatus.SEARCHING;
    devicePageControlsState = states[currentSearchStatus];
  }

  @override
  void dispose() {
    super.dispose();
    if (scanTimer != null) {
      scanTimer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Center(
              child: Text(
                devicePageControlsState.title,
                style: CustomCupertinoTextStyles.lightBigTitle,
              ),
            ),
            padding: EdgeInsets.only(top: 120),
          ),
          Container(
              child: Center(
            child: Visibility(
              visible: devicePageControlsState.spinnerVisible,
              child: CupertinoActivityIndicator(
                animating: true,
              ),
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
