import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:azsphere_obd_app/globals.dart';
import 'package:azsphere_obd_app/classes/device.dart';
import 'package:azsphere_obd_app/oobe/addnetworks.dart';

import 'package:wifi/wifi.dart';

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

enum SearchStatus {
  WIFI_DISCONNECTED,
  SEARCHING,
  DEVICE_FOUND,
  DEVICE_BTN_WAIT,
  DEVICE_OOBE_DENIED,
  FINISHED
}

class _DeviceSearchPageState extends State<DeviceSearchPage> {
  final states = {
    SearchStatus.WIFI_DISCONNECTED: DevicePageControlsState(
        buttonEnabled: false,
        content:
            'Before continuing, connect to a Wi-Fi network or set up your hotspot with the given properties.',
        spinnerVisible: false,
        title: 'Connect'),
    SearchStatus.SEARCHING: DevicePageControlsState(
        buttonEnabled: false,
        content: null,
        spinnerVisible: true,
        title: 'Searching'),
    SearchStatus.DEVICE_BTN_WAIT: DevicePageControlsState(
        buttonEnabled: false,
        content:
            'Please press the \'A\' button on the device to confirm the connection.',
        spinnerVisible: false,
        title: 'Confirm'),
  };

  SearchStatus currentSearchStatus;
  DevicePageControlsState devicePageControlsState;
  Timer scanTimer;
  String ip;
  int currentAddressIndex = 0;
  bool goToNextIP = true;
  OBDScanner currentScanner;
  bool showNotice = false;

  void scanForDevices(Timer t) async {
    try {
      ip = await Wifi.ip;
    } catch (e) {
      ip = '127.0.0.1';
    }

    if (!ip.startsWith('192.168') &&
        currentSearchStatus != SearchStatus.WIFI_DISCONNECTED) {
      setState(() {
        currentSearchStatus = SearchStatus.WIFI_DISCONNECTED;
        devicePageControlsState = states[currentSearchStatus];
      });
    } else if (ip.startsWith('192.168') &&
        currentSearchStatus == SearchStatus.WIFI_DISCONNECTED) {
      setState(() {
        currentSearchStatus = SearchStatus.SEARCHING;
        devicePageControlsState = states[currentSearchStatus];
      });
    }

    final String subnet = ip.substring(0, ip.lastIndexOf('.'));

    if (goToNextIP && currentAddressIndex < 255) {
      goToNextIP = false;
      currentAddressIndex++;
      String address = subnet + '.' + currentAddressIndex.toString();

      currentScanner = OBDScanner(
          ipAddress: address,
          onConnectionChanged: scannerConnectionChangedDuringScan);

      currentScanner.connect();
    } else if (currentAddressIndex >= 255) {
      logger.v('Scanned all the addresses in the subnet, restarting.');
      currentAddressIndex = 0;
    }
  }

  void attachButtonPress() {
    logger.v('Attaching button A press event.');
    globalScanner.connect();
    globalScanner.onConnectionChanged = scannerConnectionChanged;
    globalScanner.onButtonAPressed = deviceButtonPressHandler;
  }

  void deviceButtonPressHandler(OBDScanner s) {
    logger.i('Device button A pressed.');
    goToNextPage();
  }

  void scannerConnectionChangedDuringScan(
      OBDScanner scanner, OBDScannerConnectionStatus status) {
    goToNextIP = true;
    if (status != OBDScannerConnectionStatus.STATUS_DISCONNECTED &&
        status != OBDScannerConnectionStatus.STATUS_UNKNOWN) {
      logger.i('Device found.');

      // Save the IP address
      scanner.saveIpAddress();

      // Make it global and wait for btn. press
      globalScanner = scanner;
      setState(() {
        currentSearchStatus = SearchStatus.DEVICE_BTN_WAIT;
        devicePageControlsState = states[currentSearchStatus];
      });
      scanTimer.cancel();
      scanner.closeConnection();

      // Socket actions on the board are delayed
      sleep(Duration(milliseconds: 1100));
      attachButtonPress();
    }
  }

  void scannerConnectionChanged(
      OBDScanner scanner, OBDScannerConnectionStatus status) {
    logger.d('Scanner connection status has changed to $status.');
    if (status == OBDScannerConnectionStatus.STATUS_DISCONNECTED) {
      logger.w('Device disconnected.');
      logger.i('Starting periodic timer.');
      scanTimer = Timer.periodic(Duration(milliseconds: 50), scanForDevices);
      globalScanner.onConnectionChanged = null;
      setState(() {
        currentSearchStatus = SearchStatus.SEARCHING;
        devicePageControlsState = states[currentSearchStatus];
      });
    }
  }

  void goToNextPage() {
    logger.i('Opening "Add networks" page.');
    globalScanner.onConnectionChanged = null;
    if (scanTimer != null) scanTimer.cancel();
    Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute(
            builder: (context) => AddNetworksPage(
                  title: 'Add networks',
                )))
        .then((f) {
      // When coming back again
      initPage();
    });
  }

  @override
  void initState() {
    super.initState();

    logger.v('Device search page is being initialized.');

    initPage();
  }

  void initPage() {
    Timer(Duration(seconds: 60), (() {
      setState(() {
        logger.v('Showing delay notice.');
        showNotice = true;
      });
    }));

    logger.i('Starting periodic scan timer.');

    scanTimer = Timer.periodic(Duration(milliseconds: 50), scanForDevices);
    currentSearchStatus = SearchStatus.SEARCHING;
    devicePageControlsState = states[currentSearchStatus];
  }

  @override
  void dispose() {
    super.dispose();

    logger.v('Device search page is being disposed.');

    logger.i('Stopping timer and closing connection to global scanner.');

    scanTimer?.cancel();
    globalScanner?.closeConnection();
    globalScanner?.onConnectionChanged = null;
  }

  @override
  Widget build(BuildContext context) {
    // logger.v('Building device search page.');
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  visible: devicePageControlsState.spinnerVisible,
                  child: CupertinoActivityIndicator(
                    animating: true,
                  ),
                ),
                devicePageControlsState.content != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Container(
                            width: 250,
                            child: Text(
                              devicePageControlsState.content,
                              textAlign: TextAlign.center,
                            )))
                    : Container()
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            child: AnimatedOpacity(
              opacity:
                  (showNotice && currentSearchStatus == SearchStatus.SEARCHING)
                      ? 1.0
                      : 0.0,
              duration: Duration(milliseconds: 300),
              child: Text(
                'The scan is taking longer than expected.\r\n\r\n- Check that the device is powered on.\r\n- Try again to follow the previous steps.\r\n- Reset the device.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CupertinoButton(
                    child: Text('Back'),
                    onPressed: () {
                      logger.v('Navigating back.');
                      scanTimer?.cancel();
                      Navigator.of(context, rootNavigator: true).pop();
                    }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
