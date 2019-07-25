import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:azsphere_obd_app/iosstyles.dart';
import 'package:azsphere_obd_app/globals.dart';
import 'package:azsphere_obd_app/tabs/settings/info.dart';

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
                  ListGroupSpacer(
                    title: "View",
                  ),
                  ListSubMenu(
                    text: "Menu",
                    badgeCount: 6,
                    icon: CupertinoIcons.car,
                    iconBackground: CupertinoColors.activeGreen,
                    isLast: true,
                    onPressed: () {},
                  ),
                  ListSubMenu(
                    text: "Menu",
                    badgeCount: 6,
                    icon: CupertinoIcons.car,
                    iconBackground: CupertinoColors.activeGreen,
                    isLast: true,
                    onPressed: () {},
                  ),
                  ListSubMenu(
                    text: "Menu",
                    badgeCount: 6,
                    icon: CupertinoIcons.car,
                    iconBackground: CupertinoColors.activeGreen,
                    isLast: true,
                    onPressed: () {},
                  ),
                  ListSubMenu(
                    text: "Menu",
                    badgeCount: 6,
                    icon: CupertinoIcons.car,
                    iconBackground: CupertinoColors.activeGreen,
                    isLast: true,
                    onPressed: () {},
                  ),
                  ListSubMenu(
                    text: "Menu",
                    badgeCount: 6,
                    icon: CupertinoIcons.car,
                    iconBackground: CupertinoColors.activeGreen,
                    isLast: true,
                    onPressed: () {},
                  ),
                  ListGroupSpacer(height: 40),
                  ListSubMenu(
                    text: "About",
                    icon: CupertinoIcons.info_filled,
                    iconBackground: CustomCupertinoColors.teal,
                    isLast: true,
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true)
                          .push(CupertinoPageRoute(
                              builder: (context) => SettingsInfo(
                                    title: "About",
                                  )));
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
