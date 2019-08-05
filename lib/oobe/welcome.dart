import 'package:flutter/cupertino.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/tabs/settings/info.dart';
import 'package:azsphere_obd_app/oobe/connection.dart';
import 'package:carousel_slider/carousel_slider.dart';

/// Welcome page, the first page that appears.
class WelcomePage extends StatefulWidget {
  WelcomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
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
            "assets/1.png",
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
                    "Welcome to the Azure Sphere Driving Statistics app. This application allows you to continuously get some parameters from your car.",
                    textAlign: TextAlign.center),
                Text(
                    "By communicating with an OBD adapter created with an Azure Sphere Starter Kit and an OBD-2 mikroBUS™ click, the data from your car's ECU (electronic control unit) can be analyzed by this application.",
                    textAlign: TextAlign.center),
                    Text(
                    "By periodically downloading your data from the adapter we can show you some maps and charts with useful insights about your driving habits.",
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
                    child: Text("About"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true)
                          .push(CupertinoPageRoute(
                              builder: (context) => SettingsInfo(
                                    title: "About",
                                    previousTitle: widget.title,
                                  )));
                    }),
                CupertinoButton(
                  child: Text("Continue"),
                  color: CustomCupertinoColors.systemBlue,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(CupertinoPageRoute(
                            builder: (context) => ConnectionPage(
                                  title: "Connect",
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
