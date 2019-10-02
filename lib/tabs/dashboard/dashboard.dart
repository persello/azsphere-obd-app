import 'package:azsphere_obd_app/customcontrols.dart';
import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bezier_chart/bezier_chart.dart';

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
          // Top spacer
          Container(height: 60),

          // Dashboard container
          AspectRatio(
            aspectRatio: 1.2,

            // Dashboard stack
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                // Outer indicator
                Padding(
                  padding: EdgeInsets.all(18),
                  child: Container(
                    child: CircleProgressBar(
                      foregroundColor: CustomCupertinoColors.systemRed,
                      backgroundColor: CustomCupertinoColors.systemRed.withOpacity(0.3),
                      value: 0,
                      thickness: 18,
                      internalThickness: 18,
                      dashboardMode: true,
                      angleSpan: 0.75,
                    ),
                  ),
                ),

                // Middle indicator
                Padding(
                  padding: EdgeInsets.all(42),
                  child: Container(
                    child: CircleProgressBar(
                      foregroundColor: CustomCupertinoColors.systemYellow,
                      backgroundColor: CustomCupertinoColors.systemYellow.withOpacity(0.3),
                      value: 0,
                      thickness: 18,
                      internalThickness: 18,
                      dashboardMode: true,
                      angleSpan: 0.75,
                    ),
                  ),
                ),

                // Inner indicator
                Padding(
                  padding: EdgeInsets.all(66),
                  child: Container(
                    child: CircleProgressBar(
                      foregroundColor: Color.fromARGB(255, 200, 242, 0),
                      backgroundColor: Color.fromARGB(255, 200, 242, 0).withOpacity(0.3),
                      value: 0,
                      thickness: 18,
                      internalThickness: 18,
                      dashboardMode: true,
                      angleSpan: 0.75,
                    ),
                  ),
                ),

                // Labels container
                Container(
                  height: 90,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      // Speed indicator
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

                      // Second line
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // RPM indicator
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              color: CustomCupertinoColors.systemYellow,
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: <Widget>[
                                  Text('0',
                                      style: new TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: CustomCupertinoColors.white)),
                                  SizedBox.fromSize(size: new Size(4, 12)),
                                  Text(
                                    'rpm',
                                    style: new TextStyle(
                                        color: CustomCupertinoColors.white.withOpacity(.8),
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          VerticalDivider(color: CustomCupertinoColors.black),

                          // Throttle indicator
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              color: Color.fromARGB(255, 200, 242, 0),
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: <Widget>[
                                  Text('0',
                                      style: new TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: CustomCupertinoColors.white)),
                                  SizedBox.fromSize(size: new Size(4, 12)),
                                  Text(
                                    '%',
                                    style: new TextStyle(
                                        color: CustomCupertinoColors.white.withOpacity(.8),
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 0),

          // Cards container
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      // First card
                      child: Container(
                        margin: EdgeInsets.only(right: 6, bottom: 12, top: 40),
                        decoration: new BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(200, 250, 0, .4),
                              blurRadius: 32,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: <Color>[
                              CustomCupertinoColors.systemGreen,
                              Color.fromRGBO(200, 250, 0, 1)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(12),

                        // First card content
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Battery',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: CustomCupertinoColors.white.withOpacity(.8)),
                            ),
                            Divider(
                              color: CustomCupertinoColors.white.withOpacity(.4),
                            ),
                            Center(
                              child: Text(
                                '13.8V',
                                style: TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.w300,
                                    color: CustomCupertinoColors.white),
                              ),
                            ),
                            Divider(
                              color: CustomCupertinoColors.white.withOpacity(.4),
                            ),
                            Center(
                              child: Text(
                                'CHARGING',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                    color: CustomCupertinoColors.white.withOpacity(.6),
                                    letterSpacing: 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      // Second card
                      child: Container(
                        margin: EdgeInsets.only(left: 6, bottom: 12, top: 40),
                        decoration: new BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: CustomCupertinoColors.systemTeal.withOpacity(.4),
                              blurRadius: 32,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: <Color>[
                              CustomCupertinoColors.systemBlue,
                              CustomCupertinoColors.systemTeal
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(12),

                        // Second card content
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Coolant',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: CustomCupertinoColors.white.withOpacity(.8)),
                            ),
                            Divider(
                              color: CustomCupertinoColors.white.withOpacity(.4),
                            ),
                            Center(
                              child: Text(
                                '88°C',
                                style: TextStyle(
                                    fontSize: 60,
                                    fontWeight: FontWeight.w300,
                                    color: CustomCupertinoColors.white),
                              ),
                            ),
                            Divider(
                              color: CustomCupertinoColors.white.withOpacity(.4),
                            ),
                            Center(
                              child: Text(
                                'GOOD',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                    color: CustomCupertinoColors.white.withOpacity(.6),
                                    letterSpacing: 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Third card
                Container(
                  margin: EdgeInsets.only(bottom: 80),
                  decoration: new BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: CustomCupertinoColors.systemRed.withOpacity(.4),
                        blurRadius: 32,
                      ),
                    ],
                    gradient: LinearGradient(
                        colors: <Color>[CustomCupertinoColors.systemRed, CustomCupertinoColors.systemOrange]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(12),

                  // Third card content
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Title
                      Text(
                        'Fuel consumption',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: CustomCupertinoColors.white.withOpacity(.8)),
                      ),
                      Divider(
                        color: CustomCupertinoColors.white.withOpacity(.4),
                      ),

                      // Content
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: <Widget>[
                            // Values column
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    '12.4',
                                    style: TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.w300,
                                        color: CustomCupertinoColors.white),
                                  ),
                                  Text(
                                    'l/h',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: CustomCupertinoColors.white),
                                  ),
                                  Divider(
                                    color: CustomCupertinoColors.white,
                                  ),
                                  Row(
                                    textBaseline: TextBaseline.alphabetic,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '21.3',
                                        style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w300,
                                            color: CustomCupertinoColors.white),
                                      ),
                                      Text(
                                        ' km/l',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: CustomCupertinoColors.white),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Chart
                            ShaderMask(
                              shaderCallback: (rect) {
                                return LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [Colors.black, Colors.transparent],
                                ).createShader(Rect.fromLTRB(50, 0, rect.width / 3, rect.height));
                              },
                              blendMode: BlendMode.dstIn,
                              child: Container(
                                height: 150,
                                width: MediaQuery.of(context).size.width - 190,
                                child: BezierChart(
                                  bezierChartScale: BezierChartScale.CUSTOM,
                                  xAxisCustomValues: const [0, 5, 10, 15, 20, 25, 30, 35],
                                  series: const [
                                    BezierLine(
                                      data: const [
                                        DataPoint<double>(value: 10, xAxis: 0),
                                        DataPoint<double>(value: 130, xAxis: 5),
                                        DataPoint<double>(value: 50, xAxis: 10),
                                        DataPoint<double>(value: 150, xAxis: 15),
                                        DataPoint<double>(value: 75, xAxis: 20),
                                        DataPoint<double>(value: 0, xAxis: 25),
                                        DataPoint<double>(value: 5, xAxis: 30),
                                        DataPoint<double>(value: 45, xAxis: 35),
                                      ],
                                    ),
                                  ],
                                  config: BezierChartConfig(
                                      showVerticalIndicator: false,
                                      backgroundColor: Colors.transparent,
                                      showDataPoints: false,
                                      xAxisTextStyle: TextStyle(fontSize: 0),
                                      footerHeight: 15,
                                      displayLinesXAxis: false,
                                      contentWidth: MediaQuery.of(context).size.width - 150),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Button spacer
                      Divider(
                        color: CustomCupertinoColors.white.withOpacity(0),
                      ),

                      // Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: CupertinoButton(
                          color: CustomCupertinoColors.black.withOpacity(.1),
                          child: Text('Set fuel type'),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
