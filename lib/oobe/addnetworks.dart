import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/classes/device.dart';
import 'package:azsphere_obd_app/globals.dart';

/// OOBE page in which you can view and add networks to the device
class AddNetworksPage extends StatefulWidget {
  AddNetworksPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddNetworksPageState createState() => _AddNetworksPageState();
}

class _AddNetworksPageState extends State<AddNetworksPage> {
  List<WiFiNetwork> _networks = List<WiFiNetwork>();
  TextEditingController _passwordTextController = TextEditingController();
  bool _overlayShown = false;
  bool _passwordLongEnough = false;

  @override
  void initState() {
    super.initState();

    // Controller for text input
    _passwordTextController.addListener(passwordListener);

    // Device events
    globalScanner.onConnectionChanged = connectionChanged;
    globalScanner.onMessageReceived = messageReceived;

    // First thing to do: request networks from the device
    requestNetworks();
  }

  void passwordListener() {

    // Minimum passphrase length
    if (_passwordTextController.text.length >= 8) {
      setState(() {

        // This variable enables/disables the continue button
        _passwordLongEnough = true;
      });
    } else {
      setState(() {
        _passwordLongEnough = false;
      });
    }
  }

  /// First requests the available networks, then the already known ones.
  /// 
  /// Note: Requesting a scan may put the device in an unresponsive state
  /// for about 5 seconds.
  void requestNetworks() {
    globalScanner
        .sendMessage(TCPMessage(header: MessageHeader_ScanWiFiNetworks));
    globalScanner
        .sendMessage(TCPMessage(header: MessageHeader_KnownWiFiNetworks));
  }

  /// On disconnection navigate to scan page.
  void connectionChanged(OBDScanner s, OBDScannerConnectionStatus status) {
    if (status == OBDScannerConnectionStatus.STATUS_DISCONNECTED) {
      if (_overlayShown) {
        Navigator.of(context).pop();
      }
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  /// When the last of the two messages is received we get the network list.
  /// 
  /// The network list is parsed internally by the object.
  void messageReceived(OBDScanner s, TCPMessage m) {
    // The last of the two messages
    if (m.header == MessageHeader_KnownWiFiNetworks) {
      setState(() {
        _networks = globalScanner.networks;
      });
      globalScanner.networks.clear();

      // Let's update after each ping
    } else if (m.header == MessageHeader_Ping) {
      requestNetworks();
    }
  }

  // TODO: Investigate disconnection on removal (ping expired?)
  // TODO: Show spinner when waiting for change
  void displayRemovalWarning(BuildContext context, String ssid) {
    _overlayShown = true;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text("Remove network"),
        message: Text(
            "Are you sure you want to remove $ssid from the list of the known networks? You may not be able to reconnect even after a reset if you don't have a PC with you."),
        cancelButton: CupertinoActionSheetAction(
          child: Text("Cancel"),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
            _overlayShown = false;
          },
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text("Remove $ssid"),
            onPressed: () {
              Navigator.pop(context);
              globalScanner.sendMessage(TCPMessage(
                  header: MessageHeader_RemoveNetwork, arguments: ssid));
              requestNetworks();
              _overlayShown = false;
            },
            isDestructiveAction: true,
          ),
        ],
      ),
    );
  }

  /// Shows a dialog requesting a password for the network named [ssid].
  void displayPasswordDialog(String ssid) {
    _overlayShown = true;
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text("Password required"),
        content: new Container(
          child: Column(
            children: <Widget>[
              Text(
                  "Insert $ssid's password.\r\nKeep in mind that the connection may drop because the device could change network. If it happens, connect the phone to the same Wi-Fi and we'll search again for it automatically.\r\nThe device won't connect if the password is wrong."),
              Container(
                child: CupertinoTextField(
                  placeholder: "Password",
                  obscureText: true,
                  controller: _passwordTextController,
                ),
                padding: EdgeInsets.fromLTRB(6, 20, 6, 0),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
              _passwordTextController.clear();
              _overlayShown = false;
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text("Continue"),
            onPressed: _passwordLongEnough
                ? (() {
                    Navigator.of(context).pop();

                    // Send the new network parameters
                    globalScanner.sendMessage(TCPMessage(
                        header: MessageHeader_AddNetwork,
                        arguments: "$ssid#${_passwordTextController.text}"));
                    requestNetworks();
                    _overlayShown = false;
                  })
                : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sort the list every time by RSSI
    if (_networks.length > 1) {
      _networks.sort((a, b) {
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
            child: Visibility(
              visible: _networks.length == 0,
              child: CupertinoActivityIndicator(
                animating: true,
              ),
            ),
          ),
          Container(
            height: 400,
            child: Visibility(
              visible: _networks.length > 0,
              child: ListView.builder(
                itemCount: globalScanner.networks.length,
                itemBuilder: (BuildContext context, int index) {
                  return new ListWiFiItem(
                      _networks[index].ssid,
                      WiFiNetwork.rssiToDots(_networks[index].rssi),
                      _networks[index].isConnected,
                      _networks[index].isProtected,
                      _networks[index].isSaved, (ssid, protected) {
                    if (protected) {
                      displayPasswordDialog(ssid);
                    } else {
                      globalScanner.sendMessage(TCPMessage(
                          header: MessageHeader_AddNetwork,
                          arguments: "$ssid"));
                      requestNetworks();
                    }
                  }, (ssid, protected) {
                    displayRemovalWarning(context, ssid);
                  });
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CupertinoButton(
                    child: Text("Back"),
                    onPressed: () {
                      globalScanner.closeConnection();
                      globalScanner.onConnectionChanged = null;
                      globalScanner.onMessageReceived = null;
                      Navigator.of(context, rootNavigator: true).pop();
                    }),
                CupertinoButton(
                  child: Text("Finish"),
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
