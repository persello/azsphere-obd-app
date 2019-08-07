import 'package:flutter/cupertino.dart';

import 'package:carousel_slider/carousel_slider.dart';

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
          Image.asset(
            "assets/4.png",
            height: 350,
          ),
          Container(
            child: CarouselSlider(
              height: 80,
              viewportFraction: 1.0,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 6),
              pauseAutoPlayOnTouch: Duration(seconds: 12),
              items: <Widget>[
                Text(
                    "The device is configured to connect to a pre-set network with defined properties.",
                    textAlign: TextAlign.center),
                Text(
                    "You can create an hotspot with your phone and get the board automatically connected.",
                    textAlign: TextAlign.center),
                Text(
                    "Set your hotspot's SSID (name) to \"OBDAZURESPHERECONF\" and its password to \"AZUREOBD\"",
                    textAlign: TextAlign.center),
                Text(
                    "Remember that your mobile carrier may charge you for hotspot usage. If in doubt, disable mobile data first.",
                    textAlign: TextAlign.center),
              ],
            ),
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
