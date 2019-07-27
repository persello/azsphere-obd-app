import 'package:flutter/cupertino.dart';

import 'package:access_settings_menu/access_settings_menu.dart';

import 'package:azsphere_obd_app/iosstyles.dart';

class ConnectionPage extends StatefulWidget {
  ConnectionPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  void showDataAlert({BuildContext context, Widget child}) {
    showCupertinoModalPopup(
        context: context, builder: (BuildContext context) => child);
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
                widget.title,
                style: CustomCupertinoTextStyles.lightBigTitle,
              ),
            ),
            padding: EdgeInsets.only(top: 120),
          ),
          Container(
            child: Text(
                "In order to search for the device, we need to momentarily disable WiFi and enable your hotspot. This could lead to data charges if you have mobile data enabled. Please turn off mobile data if you aren't sure about your plan.",
                textAlign: TextAlign.center),
            padding: EdgeInsets.symmetric(horizontal: 32),
          ),
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
                  onPressed: () {
                    showDataAlert(
                      context: context,
                      child: CupertinoActionSheet(
                        title: Text("Mobile data warning"),
                        message: Text(
                            "Please disable mobile data if you think you could be charged for hotspot usage."),
                        cancelButton: CupertinoActionSheetAction(
                          child: Text("Cancel"),
                          isDefaultAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        actions: <Widget>[
                          CupertinoActionSheetAction(
                            child: Text("Go to mobile connection settings"),
                            onPressed: () {
                              AccessSettingsMenu.openSettings(
                                  settingsType:
                                      "ACTION_NETWORK_OPERATOR_SETTINGS");
                              Navigator.pop(context);
                            },
                          ),
                          CupertinoActionSheetAction(
                            child: Text("Continue and search for devices"),
                            onPressed: () {},
                          )
                        ],
                      ),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
