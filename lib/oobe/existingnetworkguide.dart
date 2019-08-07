import 'package:flutter/cupertino.dart';

import 'package:access_settings_menu/access_settings_menu.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/oobe/devicesearch.dart';

import 'package:carousel_slider/carousel_slider.dart';

/// Connection page (second page), guide for connecting to an existing network.
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
          Image.asset(
            "assets/3.png",
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
                    "First, be sure you can access the device's command line interface, then install the Azure Sphere SDK.",
                    textAlign: TextAlign.center),
                Text(
                    "Open the Azure Sphere Command Line on your PC and run the following command:\r\n\r\nazsphere device wifi add -s SSID -k PASSWORD.",
                    textAlign: TextAlign.center),
                Text(
                    "SSID and PASSWORD are respectively your network's name and its password.",
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
