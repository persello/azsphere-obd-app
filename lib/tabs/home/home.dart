import 'dart:async';
import 'dart:io';

import 'package:azsphere_obd_app/classes/device.dart';
import 'package:azsphere_obd_app/classes/vehicle.dart';
import 'package:azsphere_obd_app/customcontrols.dart';
import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:azsphere_obd_app/tabs/settings/carproperties.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wifi/wifi.dart';

import '../../globals.dart';

/// General settings page
class HomeTab extends StatefulWidget {
  HomeTab({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool isWiFiConnected = false;
  bool syncInProgress = false;
  bool searchingForScanner = false;
  String myIp;
  int lastIpByteTried = 0;
  bool lastScanWasDefaultIp = false;
  Timer rtDataTimer;

  void newDataFromScanner(OBDScanner scanner, TCPMessage message) {
    logger.v('Updating UI with new data from scanner.');

    // Just update the UI data taken from the globalScanner object
    setState(() {
      globalScanner = scanner;
    });
  }

  void pollScannerProperties(OBDScanner scanner) {
    logger.v('Polling real-time properties from scanner.');
    scanner.sendMessage(TCPMessage(header: MessageHeader_SDSize));
    scanner.sendMessage(TCPMessage(header: MessageHeader_SDMounted));
  }

  /// Called when the current scanner instance changes its connection status
  void scannerConnectionChanged(
      OBDScanner scanner, OBDScannerConnectionStatus status) async {
    // Scanner found during search
    if (status == OBDScannerConnectionStatus.STATUS_CONNECTED &&
        searchingForScanner) {
      logger.i('Device found at address ${scanner.ipAddress}.');

      // This also updates the globalScanner indicator
      setState(() {
        // Stop eventual connection indicators
        searchingForScanner = false;
      });

      // We are now connected, let's save the IP address
      StoredSettings.saveIp(scanner.ipAddress);

      // Make it global
      globalScanner = scanner;

      // Now this function is called by the global scanner
      scanner.onConnectionChanged = null;
      globalScanner.onConnectionChanged = scannerConnectionChanged;

      // Update the UI when the scanner answers with data taken from
      globalScanner.onMessageReceived = newDataFromScanner;

      // Start the timer that polls the real-time data that the UI should display
      rtDataTimer = new Timer.periodic(Duration(seconds: 5), (timer) {
        pollScannerProperties(globalScanner);
      });

      // Wrong address during search
    } else if (status == OBDScannerConnectionStatus.STATUS_DISCONNECTED &&
        searchingForScanner &&
        globalScanner?.status != OBDScannerConnectionStatus.STATUS_CONNECTED) {
      // Every five addresses try last successful IP
      if (lastIpByteTried % 5 == 0 && !lastScanWasDefaultIp) {
        scanner.ipAddress = await StoredSettings.restoreIp();
        scanner.connect();
        lastScanWasDefaultIp = true;
      } else {
        // Try next IP address
        String ipToTry = myIp.substring(0, myIp.lastIndexOf('.'));
        ipToTry += ('.' + lastIpByteTried.toString());
        scanner.ipAddress = ipToTry;
        scanner.connect();

        // Increment index
        if (lastIpByteTried == 255) {
          lastIpByteTried = 0;
          searchingForScanner = false;
          logger.w('Scanned every address of the subnet. No devices found.');
        } else {
          lastIpByteTried++;
        }

        lastScanWasDefaultIp = false;
      }

      // Device disconnected after search
    } else if (status == OBDScannerConnectionStatus.STATUS_DISCONNECTED &&
        !searchingForScanner) {
      logger.w('Restarting scan after disconnection or not found.');

      // Stop the poll timer
      rtDataTimer?.cancel();

      // Come on, let's search again (like you did last summer)
      setState(() {
        searchingForScanner = false;
      });

      // Yeah, let's search again (like you did last year)
      searchScanner();
    }
  }

  void searchScanner() async {
    myIp = (await Wifi.ip) ?? '';

    setState(() {
      isWiFiConnected = myIp.startsWith('192.168');
    });

    if (isWiFiConnected &&
        globalScanner?.status != OBDScannerConnectionStatus.STATUS_CONNECTED) {
      logger.d('My IP is $myIp.');
      logger.d('Wi-Fi network is ${isWiFiConnected ? "" : "not "}connected.');

      logger.i('Scanner is not connected, starting to search.');

      // Update
      searchingForScanner = true;

      // Get last successful IP from settings
      String lastSuccessfulIp = await StoredSettings.restoreIp();

      logger.d('The last IP of the device was $lastSuccessfulIp.');

      OBDScanner scanner = new OBDScanner(ipAddress: lastSuccessfulIp);

      // Try the first connection
      scanner.onConnectionChanged = scannerConnectionChanged;
      scanner.connect();

      // Then when the connection happens, or fails, a loop of events will start.
      // The scannerConnectionChanged function will start a scan every time the previous one will fail.
    }
  }

  void getCarFromMemory() async {
    logger.i('Getting car properties from storage.');
    Vehicle x = await Vehicle.restore();
    setState(() {
      car = x;
    });
  }

  @override
  void initState() {
    logger.v('Home page is being initialized.');

    // Update car object
    getCarFromMemory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // logger.v('Building home page.');

    if (!searchingForScanner) searchScanner();

    return CupertinoPageScaffold(
      backgroundColor: CustomCupertinoColors.systemGray6,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(largeTitle: Text(widget.title)),
          SliverFillRemaining(
            child: Column(
              children: <Widget>[
                ListGroupSpacer(title: 'Connection status'),

                // Connection indicator (car: yellow has voltage, green is connected)
                GenericListItem(
                  isLast: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      // Phone icon
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.phone_iphone,
                                color: CustomCupertinoColors.black,
                              ),
                            ),
                            Text('Phone'),
                          ],
                        ),
                      ),

                      // Connector
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  color: CustomCupertinoColors.systemGray,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  child: Container(
                                    height: 12,
                                    width: 12,
                                    color: isWiFiConnected
                                        ? ((globalScanner?.status ??
                                                    OBDScannerConnectionStatus
                                                        .STATUS_DISCONNECTED) ==
                                                OBDScannerConnectionStatus
                                                    .STATUS_CONNECTED
                                            ? CustomCupertinoColors.systemGreen
                                            : CustomCupertinoColors
                                                .systemYellow)
                                        : CustomCupertinoColors.systemRed,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: CustomCupertinoColors.systemGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Board icon
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.developer_board,
                                color: CustomCupertinoColors.black,
                              ),
                            ),
                            Text('Logger'),
                          ],
                        ),
                      ),

                      // Connector
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  color: CustomCupertinoColors.systemGray,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  child: Container(
                                    height: 12,
                                    width: 12,
                                    color: ((globalScanner?.status ??
                                                OBDScannerConnectionStatus
                                                    .STATUS_DISCONNECTED) ==
                                            OBDScannerConnectionStatus
                                                .STATUS_CONNECTED)
                                        ? CustomCupertinoColors.systemYellow
                                        : CustomCupertinoColors.systemRed,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: CustomCupertinoColors.systemGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Car icon

                      Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                CupertinoIcons.car,
                                color: CustomCupertinoColors.black,
                              ),
                            ),
                            Text('Car'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                ListGroupSpacer(title: 'Data storage'),

                // Available memory on the SD card
                ListButton(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  onPressed: () {
                    logger.i('Opening "GIVE THIS PAGE A NAME" page.');
                  },
                  children: <Widget>[
                    Container(
                      width: 200,
                      child: Text(
                        globalScanner?.status ==
                                OBDScannerConnectionStatus.STATUS_CONNECTED
                            ? globalScanner?.sdCardMounted ?? 0
                                ? 'Your data uses 0.15 GB out of ${OBDScanner.byteSizeToString(1024 * globalScanner?.sdCardSize ?? 0)} available in the card.'
                                : 'Please insert a FAT or exFAT microSD card in the slot.'
                            : 'The device is disconnected.',
                        overflow: TextOverflow.fade,
                        style: CustomCupertinoTextStyles.blackStyle,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      height: 100,
                      child: CircleProgressBar(
                        backgroundColor: CustomCupertinoColors.systemGray5,
                        foregroundColor: CustomCupertinoColors.systemBlue,
                        value: .24,
                      ),
                    ),
                  ],
                ),

                // Sync status: syncing
                if (syncInProgress)
                  ListButton(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    onPressed: () {
                      logger.i('Opening "GIVE THIS PAGE A NAME" page.');
                    },
                    isLast: true,
                    children: <Widget>[
                      Container(
                        width: 200,
                        child: Text(
                          'Sync in progress...\r\n01:13 remaining.',
                          overflow: TextOverflow.fade,
                          style: CustomCupertinoTextStyles.blackStyle,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        height: 100,
                        child: CircleProgressBar(
                          backgroundColor: CustomCupertinoColors.systemGray5,
                          foregroundColor: CustomCupertinoColors.systemYellow,
                          value: .68,
                        ),
                      ),
                    ],
                  ),

                // Sync status: synced
                if (!syncInProgress)
                  GenericListItem(
                    isLast: true,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 200,
                            child: Text(
                              'Most recent data is from yesterday, 11:30.',
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            height: 100,

                            // TODO: Ask user to press B button or to turn ignition off to get this trip's data (when indicator is green).
                            // Do not use while driving.
                            // During sync, no data will be saved if you're driving.
                            child: CupertinoButton(
                              child: Text('Sync now'),
                              onPressed: globalScanner?.status ==
                                      OBDScannerConnectionStatus
                                          .STATUS_CONNECTED
                                  ? () {
                                      // Start sync
                                      logger.i('Sync button pressed.');
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Car data
                ListGroupSpacer(title: 'Your car'),
                ListButton(
                  onPressed: () {
                    logger.i('Opening "Car Properties" page.');
                    Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(
                        builder: (context) => SettingsCarProperties(
                          title: 'Vehicle information',
                          previousTitle: widget.title,
                        ),
                      ),
                    );
                  },
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        // Image
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: CustomCupertinoColors.systemGray6,
                              height: 80,
                              width: 80,
                              child: (car.imagePath == null
                                  ? Icon(CupertinoIcons.photo_camera_solid,
                                      size: 40,
                                      color: CustomCupertinoColors.systemGray4)
                                  : FittedBox(
                                      child: Image.file(File(car.imagePath)),
                                      fit: BoxFit.cover,
                                    )),
                            ),
                          ),
                        ),

                        // Text fields
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              (car.brand == '')
                                  ? 'Unknown brand'
                                  : car.brand ?? 'Unknown brand',
                              style: CustomCupertinoTextStyles.blackStyle,
                            ),
                            Text(
                              (car.model == '')
                                  ? 'Unknown model'
                                  : car.model ?? 'Unknown model',
                              style: CustomCupertinoTextStyles.blackStyle,
                            ),
                            Text(
                              (car.vin == '')
                                  ? 'Unknown VIN'
                                  : car.vin ?? 'Unknown VIN',
                              style: CustomCupertinoTextStyles.secondaryStyle,
                            ),
                          ],
                        )
                      ],
                    ),

                    // Chevron
                    Icon(
                      CupertinoIcons.right_chevron,
                      color: CustomCupertinoColors.systemGray4,
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
