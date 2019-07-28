import 'package:flutter/cupertino.dart';

import 'package:access_settings_menu/access_settings_menu.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/oobe/devicesearch.dart';

/// Connection page (second page), asks to enable hotspot.
class ExistingNetworkGuidePage extends StatefulWidget {
  ExistingNetworkGuidePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ExistingNetworkGuidePageState createState() =>
      _ExistingNetworkGuidePageState();
}

class _ExistingNetworkGuidePageState extends State<ExistingNetworkGuidePage> {
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
                "You'll need to access the device's settings via the command line, so you must have access to it.\r\n\r\n After installing the Azure Sphere SDK on your computer add your WiFi network with the following command:\r\n\r\nazsphere device wifi add -s <SSID> -k <PASSWORD>\r\n\r\nWhere SSID and PASSWORD are your network's name and passphrase. Please add the same network to which this phone is connected.",
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
                    Navigator.of(context, rootNavigator: true)
                        .push(CupertinoPageRoute(
                            builder: (context) => DeviceSearchPage(
                                  title: "Searching device",
                                )));
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
