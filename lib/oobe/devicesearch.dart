import 'package:flutter/cupertino.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/globals.dart';

/// Device search and listing page (third one)
class DeviceSearchPage extends StatefulWidget {
  DeviceSearchPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DeviceSearchPageState createState() => _DeviceSearchPageState();
}

class _DeviceSearchPageState extends State<DeviceSearchPage> {
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
              child: Center(
            child: CupertinoActivityIndicator(
              animating: true,
            ),
          )),
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
                  onPressed: null,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
