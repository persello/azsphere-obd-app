import 'package:flutter/cupertino.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/oobe/devicesearch.dart';

/// Connection page (second page), asks to enable hotspot.
class HotspotGuidePage extends StatefulWidget {
  HotspotGuidePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HotspotGuidePageState createState() => _HotspotGuidePageState();
}

class _HotspotGuidePageState extends State<HotspotGuidePage> {
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
                "The device should be preconfigured to connect to a network with defined SSID and password. You can create an hotspot with your phone with the following details:\r\n\r\nSSID: OBDAZURESPHERECONF\r\n\r\nPassword: AZUREOBD\r\n\r\nPlease remember that your mobile carrier may charge you for hotspot usage. If supported, enable the hotspot without mobile data.",
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
                                  title: "Searching",
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
