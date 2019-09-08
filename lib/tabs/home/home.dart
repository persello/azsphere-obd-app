import 'dart:io';

import 'package:azsphere_obd_app/tabs/settings/carproperties.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:azsphere_obd_app/customcontrols.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../globals.dart';

/// General settings page
class HomeTab extends StatefulWidget {
  HomeTab({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
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
                ListGroupSpacer(title: "Connection status"),

                // Connection indicator (car: yellow has voltage, green is connected)
                GenericListItem(
                  isLast: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      // Phone icon
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.phone_iphone,
                                color: CustomCupertinoColors.black,
                              ),
                            ),
                            Text("Phone"),
                          ],
                        ),
                      ),

                      // Connector
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  color: CustomCupertinoColors.systemGray,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  child: Container(
                                    height: 12,
                                    width: 12,
                                    color: CustomCupertinoColors.systemGreen,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: CustomCupertinoColors.systemGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Board icon
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.developer_board,
                                color: CustomCupertinoColors.black,
                              ),
                            ),
                            Text("Logger"),
                          ],
                        ),
                      ),

                      // Connector
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Divider(
                                  color: CustomCupertinoColors.systemGray,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  child: Container(
                                    height: 12,
                                    width: 12,
                                    color: CustomCupertinoColors.systemYellow,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: CustomCupertinoColors.systemGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Car icon

                      Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                CupertinoIcons.car,
                                color: CustomCupertinoColors.black,
                              ),
                            ),
                            Text("Car"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                ListGroupSpacer(title: "Data storage"),

                // Available memory on the SD card
                ListButton(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  onPressed: () {},
                  children: <Widget>[
                    Container(
                      width: 160,
                      child: Text(
                        "Your data uses 0.15 GB out of 7.96 GB available in the card.",
                        overflow: TextOverflow.fade,
                        style: CustomCupertinoTextStyles.blackStyle,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      height: 100,
                      child: CircleProgressBar(
                        backgroundColor: CustomCupertinoColors.systemGray5,
                        foregroundColor: CustomCupertinoColors.systemBlue,
                        value: .24,
                      ),
                    ),
                  ],
                ),

                // Sync status: syncing
                ListButton(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  onPressed: () {},
                  isLast: true,
                  children: <Widget>[
                    Container(
                      width: 160,
                      child: Text(
                        "Sync in progress...\r\n01:13 remaining.",
                        overflow: TextOverflow.fade,
                        style: CustomCupertinoTextStyles.blackStyle,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      height: 100,
                      child: CircleProgressBar(
                        backgroundColor: CustomCupertinoColors.systemGray5,
                        foregroundColor: CustomCupertinoColors.systemYellow,
                        value: .68,
                      ),
                    ),
                  ],
                ),

                // Sync status: synced
                GenericListItem(
                  isLast: true,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 160,
                          child: Text(
                            "Most recent data is from yesterday, 11:30.",
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          height: 100,

                          // Ask user to press B button or to turn ignition off to get this trip's data (when indicator is green).
                          // Do not use while driving.
                          // During sync, no data will be saved if you're driving.
                          child: CupertinoButton(
                            child: Text("Sync now"),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Car data
                ListGroupSpacer(title: "Your car"),
                ListButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                      CupertinoPageRoute(
                        builder: (context) => SettingsCarProperties(
                          title: "Vehicle information",
                          previousTitle: widget.title,
                        ),
                      ),
                    );
                  },
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: CustomCupertinoColors.systemGray6,
                              height: 80,
                              width: 80,
                              child: Icon(
                                CupertinoIcons.photo_camera_solid,
                                size: 40,
                                color: CustomCupertinoColors.systemGray4,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              car.brand ?? "Unknown brand",
                              style: CustomCupertinoTextStyles.blackStyle,
                            ),
                            Text(
                              car.model ?? "Unknown model",
                              style: CustomCupertinoTextStyles.blackStyle,
                            ),
                            Text(
                              car.vin ?? "Unknown VIN",
                              style: CustomCupertinoTextStyles.secondaryStyle,
                            ),
                          ],
                        )
                      ],
                    ),

                    // Chevron
                    Icon(
                      CupertinoIcons.right_chevron,
                      color: CustomCupertinoColors.systemGray4,
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
