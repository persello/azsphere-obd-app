import 'package:azsphere_obd_app/tabs/settings/carproperties.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:azsphere_obd_app/tabs/settings/info.dart';
import 'package:azsphere_obd_app/oobe/welcome.dart';

/// General settings page
class SettingsTab extends StatefulWidget {
  SettingsTab({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomCupertinoColors.systemGray6,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(largeTitle: Text(widget.title)),
          SliverFillRemaining(
            child: Column(
              children: <Widget>[
                ListGroupSpacer(),
                ListSubMenu(
                  text: "General",
                  icon: CupertinoIcons.settings_solid,
                  iconBackground: CustomCupertinoColors.systemGray,
                  onPressed: () {},
                ),
                ListSubMenu(
                  text: "Connection",
                  icon: CustomCupertinoIcons.syncarrows,
                  iconBackground: CustomCupertinoColors.systemBlue,
                  onPressed: () {},
                ),
                ListSubMenu(
                  text: "Device",
                  icon: CupertinoIcons.car,
                  iconBackground: CustomCupertinoColors.systemOrange,
                  onPressed: () {},
                ),
                ListSubMenu(
                  text: "Menu",
                  icon: CupertinoIcons.car,
                  iconBackground: CustomCupertinoColors.systemIndigo,
                  isLast: true,
                  onPressed: () {},
                ),
                ListGroupSpacer(height: 40),
                ListSubMenu(
                  text: "Vehicle information",
                  icon: CupertinoIcons.car,
                  iconBackground: CustomCupertinoColors.systemGreen,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(builder: (context) => SettingsCarProperties(title: "Vehicle information", previousTitle: "Settings")));
                  },
                ),
                ListSubMenu(
                  text: "About",
                  icon: CustomCupertinoIcons.info_filled,
                  iconBackground: CustomCupertinoColors.systemTeal,
                  isLast: true,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(CupertinoPageRoute(
                            builder: (context) => SettingsInfo(
                                  title: "About",
                                  previousTitle: widget.title,
                                )));
                  },
                ),
                ListGroupSpacer(height: 40),
                ListSubMenu(
                  text: "INTERNAL-STARTOOBE",
                  icon: CupertinoIcons.eye_solid,
                  iconBackground: CustomCupertinoColors.systemPink,
                  isLast: true,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(CupertinoPageRoute(
                            builder: (context) => WelcomePage(
                                  title: "Welcome",
                                )));
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
