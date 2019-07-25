import 'package:flutter/cupertino.dart';

class CustomCupertinoColors {
  static const Color systemGray6 = Color.fromARGB(255, 242, 242, 247);
  static const Color systemGray5 = Color.fromARGB(255, 229, 229, 234);
  static const Color systemGray4 = Color.fromARGB(255, 209, 209, 214);
  static const Color systemGray3 = Color.fromARGB(255, 199, 199, 204);
  static const Color systemGray2 = Color.fromARGB(255, 174, 174, 178);
  static const Color systemGray = Color.fromARGB(255, 142, 142, 147);

  static const Color white = Color.fromARGB(255, 255, 255, 255);
  static const Color black = Color.fromARGB(255, 0, 0, 0);
  static const Color transparent = Color.fromARGB(0, 0, 0, 0);
}

class CustomCupertinoTextStyles {
  static const TextStyle listGroupTitle = TextStyle(
    color: CustomCupertinoColors.systemGray,
    letterSpacing: 0.3,
    fontSize: 15,
  );
}

class ListGroupSpacer extends StatelessWidget {
  final String title;
  const ListGroupSpacer(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          title.toUpperCase(),
          style: CustomCupertinoTextStyles.listGroupTitle,
        ),
      ),
      height: 60,
      alignment: Alignment.bottomLeft,
    );
  }
}

class ListSwitch extends StatefulWidget {

  ListSwitch(this.title);
  final String title;

  @override
  _ListSwitchState createState() => _ListSwitchState();
}

class _ListSwitchState extends State<ListSwitch> {
  bool _switchState = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _switchState = !_switchState;
        });
      },
      child: Container(
        color: CustomCupertinoColors.white,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(widget.title),
                  CupertinoSwitch(
                    value: _switchState,
                    onChanged: (bool value) {
                      setState(() {
                        _switchState = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
              child: Container(
                height: 1,
                color: Color.fromARGB(255, 242, 242, 247),
              ),
            )
          ],
        ),
      ),
    );
  }
}
