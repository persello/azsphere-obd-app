import 'package:azsphere_obd_app/customcontrols.dart';
import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardTab extends StatefulWidget {
  DashboardTab({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Column(
      children: <Widget>[
        Container(height: 60),
        AspectRatio(
          aspectRatio: 1.2,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(18),
                child: Container(
                  child: CircleProgressBar(
                    foregroundColor: CustomCupertinoColors.systemRed,
                    backgroundColor: CustomCupertinoColors.systemRed.withOpacity(0.1),
                    value: 0,
                    thickness: 18,
                    internalThickness: 18,
                    horizontal: true,
                    angleSpan: 0.5,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(42),
                child: Container(
                  child: CircleProgressBar(
                    foregroundColor: CustomCupertinoColors.systemYellow,
                    backgroundColor: CustomCupertinoColors.systemYellow.withOpacity(0.1),
                    value: 0,
                    thickness: 18,
                    internalThickness: 18,
                    horizontal: true,
                    angleSpan: 0.5,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(66),
                child: Container(
                  child: CircleProgressBar(
                    foregroundColor: Color.fromARGB(255, 200, 242, 0),
                    backgroundColor: Color.fromARGB(255, 200, 242, 0).withOpacity(0.1),
                    value: 0,
                    thickness: 18,
                    internalThickness: 18,
                    horizontal: true,
                    angleSpan: 0.5,
                  ),
                ),
              ),
              Container(
                  height: 90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        mainAxisAlignment: MainAxisAlignment.center,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 22, right: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: 8,
                                width: 8,
                                color: CustomCupertinoColors.systemRed,
                              ),
                            ),
                          ),
                          Text('0', style: new TextStyle(fontSize: 48, fontWeight: FontWeight.w600)),
                          SizedBox.fromSize(size: new Size(4, 12)),
                          Text(
                            'km/h',
                            style: new TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                                color: CustomCupertinoColors.systemGray),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        mainAxisAlignment: MainAxisAlignment.center,
                        textBaseline: TextBaseline.alphabetic,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 10, right: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: 6,
                                width: 6,
                                color: CustomCupertinoColors.systemYellow,
                              ),
                            ),
                          ),
                          Text('0', style: new TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                          SizedBox.fromSize(size: new Size(4, 12)),
                          Text(
                            'rpm',
                            style: new TextStyle(
                                color: CustomCupertinoColors.systemGray, fontWeight: FontWeight.w300),
                          ),
                          VerticalDivider(thickness: 2, color: CustomCupertinoColors.black),
                          Container(
                            padding: EdgeInsets.only(top: 10, right: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: 6,
                                width: 6,
                                color: Color.fromARGB(255, 200, 242, 0),
                              ),
                            ),
                          ),
                          Text('0', style: new TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                          SizedBox.fromSize(size: new Size(4, 12)),
                          Text(
                            '%',
                            style: new TextStyle(
                                color: CustomCupertinoColors.systemGray, fontWeight: FontWeight.w300),
                          ),
                        ],
                      )
                    ],
                  )),
            ],
          ),
        ),
      ],
    ));
  }
}
