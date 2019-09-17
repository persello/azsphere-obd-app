import 'package:flutter/cupertino.dart';

import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:azsphere_obd_app/oobe/existingnetworkguide.dart';
import 'package:azsphere_obd_app/oobe/hotspotguide.dart';

import '../globals.dart';

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
    // logger.v('Building connection page.');
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
            'assets/2.png',
            height: 350,
          ),
          Container(
            child: Text(
                'In order to search for the device, you\'ll need to connect the phone and the device to the same network. ',
                textAlign: TextAlign.center),
            padding: EdgeInsets.symmetric(horizontal: 32),
          ),
          Container(
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CupertinoButton(
                    child: Text('Back'),
                    onPressed: () {
                      logger.i('Navigating back.');
                      Navigator.of(context, rootNavigator: true).pop();
                    }),
                CupertinoButton(
                  child: Text('Continue'),
                  color: CustomCupertinoColors.systemBlue,
                  onPressed: () {
                    logger.i('Opening action sheet.');
                    showDataAlert(
                      context: context,
                      child: CupertinoActionSheet(
                        title: Text('Connection method'),
                        message: Text('Please choose how to proceed.'),
                        cancelButton: CupertinoActionSheetAction(
                          child: Text('Cancel'),
                          isDefaultAction: true,
                          onPressed: () {
                            logger.i('Closing action sheet.');
                            Navigator.pop(context);
                          },
                        ),
                        actions: <Widget>[
                          CupertinoActionSheetAction(
                            child: Text('Use an existing network (PC needed)'),
                            onPressed: () {
                              logger.i('Opening "Existing network" page.');
                              Navigator.of(context, rootNavigator: true)
                                ..pop(context)
                                ..push(CupertinoPageRoute(
                                    builder: (context) =>
                                        ExistingNetworkGuidePage(
                                            title: 'Existing network')));
                            },
                          ),
                          CupertinoActionSheetAction(
                            child: Text('Use my phone\'s mobile hotspot'),
                            onPressed: () {
                              logger.i('Opening "Mobile hotspot" page.');
                              Navigator.of(context, rootNavigator: true)
                                ..pop(context)
                                ..push(CupertinoPageRoute(
                                    builder: (context) => HotspotGuidePage(
                                        title: 'Mobile hotspot')));
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
