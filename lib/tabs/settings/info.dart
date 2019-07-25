import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:package_info/package_info.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/globals.dart';

/// General settings page
class SettingsInfo extends StatefulWidget {
  SettingsInfo({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsInfoState createState() => _SettingsInfoState();

  Future<PackageInfo> getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }
}

class _SettingsInfoState extends State<SettingsInfo> {
  Future<PackageInfo> _packageInfo;
  String _version = "";
  String _buildNumber = "";

  @override
  Widget build(BuildContext context) {
    _packageInfo = widget.getPackageInfo();
    _packageInfo.then((PackageInfo pi) {
      setState(() {
        _version = pi.version;
        _buildNumber = pi.buildNumber;
      });
    });
    return CupertinoPageScaffold(
        backgroundColor: CustomCupertinoColors.systemGray6,
        child: CustomScrollView(
          slivers: <Widget>[
            CupertinoSliverNavigationBar(
                largeTitle: Text(widget.title), previousPageTitle: "Settings"),
            SliverFillRemaining(
              child: Column(
                children: <Widget>[
                  ListGroupSpacer(
                    title: "About the app",
                  ),
                  GenericListItem(child: Text("Azure Sphere Driving Statistics\r\nVersion $_version build $_buildNumber."))
                ],
              ),
            )
          ],
        ));
  }
}
