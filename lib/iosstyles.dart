import 'package:flutter/cupertino.dart';

/// Some custom-defined colors based on [Apple's guidelines](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/color/).
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

/// Some custom text styles for general usage.
class CustomCupertinoTextStyles {
  /// A text style for grouped lists' titles.
  ///
  /// Specifies the [Color], [letterSpacing] and [fontSize] properties.
  static const TextStyle listGroupTitle = TextStyle(
    color: CustomCupertinoColors.systemGray,
    letterSpacing: 0.3,
    fontSize: 15,
  );
}

/// A spacer to be used to divide elements of a [ListView].
///
/// This [StatelessWidget] has a [title] property that allows you to specify
/// its content (shown in its lower-left corner). Margins, colors
/// and text style are already defined. Keep in mind that being
/// transparent, you'll see the color of the [CupertinoPageScaffold]
/// or other [Widget] behind the [ListView]. By default, the title is empty
/// and the [height] parameter is set to 60.
class ListGroupSpacer extends StatelessWidget {
  final String title;
  final double height;
  const ListGroupSpacer({this.title = "", this.height = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        // Aligned with other elements
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          // Always upper case and with previous defined style
          title.toUpperCase(),
          style: CustomCupertinoTextStyles.listGroupTitle,
        ),
      ),
      height: this.height,
      alignment: Alignment.bottomLeft,
    );
  }
}

/// A switch item for being put in a list.
///
/// This [StatefulWidget] is a list item containing a [CupertinoSwitch],
/// a [Text] and a separator at the bottom. The [title] parameter lets
/// you set a custom default text and the optional [isLast] parameter
/// allows you to hide the separator on the last item of a list or group.
/// Also tapping the body of this widget will toggle the switch.
/// Set the [value] parameter to change the represented value and get
/// notified of changes with the [onChanged] callback.
class ListSwitch extends StatefulWidget {
  ListSwitch(
      {this.title = "",
      @required this.onChanged,
      this.initialValue = false,
      this.isLast = false});
  final String title;
  final bool isLast;
  final bool initialValue;
  // Callback function
  final ValueChanged<bool> onChanged;

  @override
  _ListSwitchState createState() => _ListSwitchState();
}

class _ListSwitchState extends State<ListSwitch> {
  bool _switchState;
  bool _first = true;

  @override
  Widget build(BuildContext context) {
    // Setting initial value only the first time the widget is built
    setState(() {
      if (_first) {
        _switchState = widget.initialValue;
        _first = false;
      }
    });

    // For detecting taps in all the area
    return GestureDetector(
      onTap: () {
        setState(() {
          _switchState = !_switchState;
          widget.onChanged(_switchState);
        });
      },

      // Main container
      child: Container(
        color: CustomCupertinoColors.white,

        // For stacking vertically the list item and the separator
        child: Column(
          children: <Widget>[
            // Padding for text and button
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 6,
                horizontal: 12,
              ),

              // Horizontally stack text and button
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(widget.title),
                  CupertinoSwitch(
                    value: _switchState,
                    onChanged: (bool v) {
                      setState(() {
                        _switchState = v;
                        widget.onChanged(_switchState);
                      });
                    },
                  ),
                ],
              ),
            ),

            // Only if not last
            Visibility(
              child: Padding(
                // Touches right side but not left
                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                child: Container(
                  height: 1,
                  color: CustomCupertinoColors.systemGray6,
                ),
              ),
              visible: !widget.isLast,
            )
          ],
        ),
      ),
    );
  }
}
