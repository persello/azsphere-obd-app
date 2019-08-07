import 'package:flutter/cupertino.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/oobe/existingnetworkguide.dart';
import 'package:azsphere_obd_app/oobe/hotspotguide.dart';

/// Connection page (second page), asks to enable hotspot.
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
          Image.asset(
            "assets/2.png",
            height: 350,
          ),
          Container(
            child: Text(
                "In order to search for the device, you'll need to connect the phone and the device to the same network. ",
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
                        title: Text("Connection method"),
                        message: Text("Please choose how to proceed."),
                        cancelButton: CupertinoActionSheetAction(
                          child: Text("Cancel"),
                          isDefaultAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        actions: <Widget>[
                          CupertinoActionSheetAction(
                            child: Text("Use an existing network (PC needed)"),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                ..pop(context)
                                ..push(CupertinoPageRoute(
                                    builder: (context) =>
                                        ExistingNetworkGuidePage(
                                            title: "Existing network")));
                            },
                          ),
                          CupertinoActionSheetAction(
                            child: Text("Use my phone's mobile hotspot"),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                ..pop(context)
                                ..push(CupertinoPageRoute(
                                    builder: (context) => HotspotGuidePage(
                                        title: "Mobile hotspot")));
                            },
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
