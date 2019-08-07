import 'dart:math';

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

  static const Color systemBlue = Color.fromARGB(255, 0, 122, 255);
  static const Color systemGreen = Color.fromARGB(255, 52, 199, 89);
  static const Color systemIndigo = Color.fromARGB(255, 88, 86, 214);
  static const Color systemOrange = Color.fromARGB(255, 255, 149, 0);
  static const Color systemPink = Color.fromARGB(255, 255, 45, 85);
  static const Color systemPurple = Color.fromARGB(255, 175, 82, 222);
  static const Color systemRed = Color.fromARGB(255, 255, 59, 48);
  static const Color systemTeal = Color.fromARGB(255, 90, 200, 250);
  static const Color systemYellow = Color.fromARGB(255, 255, 204, 0);
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

  /// A text style for all the buttons that perform destructive actions.
  static const TextStyle warningButton = TextStyle(
      color: CupertinoColors.destructiveRed, fontWeight: FontWeight.w600);

  /// A black text style.
  static const TextStyle blackStyle =
      TextStyle(color: CustomCupertinoColors.black);

  /// A black text style.
  static const TextStyle lightBigTitle =
      TextStyle(fontSize: 56, fontWeight: FontWeight.w600);

  /// A white text style.
  static const TextStyle whiteStyle =
      TextStyle(color: CustomCupertinoColors.white);
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
  const ListGroupSpacer({this.title = "", this.height = 60});
  final String title;
  final double height;

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

/// A generic List Item Container.
///
/// This container is a generic white container for a ListView.
/// It has been tested with [Text] and [CupertinoSegmentedControl],
/// surrounded by a [Padding].
class GenericListItem extends StatelessWidget {
  GenericListItem({this.child, this.isLast = false});
  final bool isLast;
  final Widget child;

  Widget build(BuildContext context) {
    return Container(
      color: CustomCupertinoColors.white,

      // For stacking vertically the list item and the separator
      child: Column(
        children: <Widget>[
          // Padding for child
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 12,
            ),

            // Center the child
            child: Row(
              children: <Widget>[
                Expanded(
                  child: this.child,
                )
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
            visible: !this.isLast,
          )
        ],
      ),
    );
  }
}

/// A clickable list item.
///
/// This generic list item is interactive and acts as a [CupertinoButton].
/// It is the base of the [ListSubMenu].
class ListButton extends StatefulWidget {
  ListButton({@required this.children, this.onPressed, this.isLast = false});
  final List<Widget> children;
  final bool isLast;
  final VoidCallback onPressed;

  @override
  _ListButtonState createState() => _ListButtonState();
}

class _ListButtonState extends State<ListButton> {
  @override
  Widget build(BuildContext context) {
    // For detecting taps in all the area
    return GestureDetector(
      onTap: () {
        if (widget.onPressed != null) {
          widget.onPressed();
        }
      },

      // Main container
      child: Container(
        color: CustomCupertinoColors.white,

        // For stacking vertically the item and the separator
        child: Column(
          children: <Widget>[
            // The button contains every children
            CupertinoButton(
              padding: EdgeInsets.fromLTRB(12, 0, 4, 0),
              onPressed: widget.onPressed,
              // In a row for alignment
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: widget.children,
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

/// A complete submenu item (such as these found in the system settings).
///
/// It has an icon with a background color, a title, an optional counter
/// ([badgeCount]) and a chevron. If [badgeCount] is null, the badge
/// will be hidden.
class ListSubMenu extends StatefulWidget {
  ListSubMenu(
      {@required this.text,
      this.icon,
      this.iconBackground = CustomCupertinoColors.systemGreen,
      this.badgeCount,
      this.isLast = false,
      this.onPressed});

  final String text;
  final Color iconBackground;
  final IconData icon;
  final int badgeCount;
  final bool isLast;
  final VoidCallback onPressed;

  @override
  _ListSubMenuState createState() => _ListSubMenuState();
}

class _ListSubMenuState extends State<ListSubMenu> {
  @override
  Widget build(BuildContext context) {
    return ListButton(
      onPressed: widget.onPressed,
      isLast: widget.isLast,
      children: <Widget>[
        // Left side
        Row(
          children: <Widget>[
            // Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                  color: widget.iconBackground ?? CupertinoColors.activeGreen,
                  child: Padding(
                      child: Icon(
                        widget.icon,
                        color: CustomCupertinoColors.white,
                        size: 16,
                      ),
                      padding: EdgeInsets.fromLTRB(4, 3, 4, 5))),
            ),

            //Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(widget.text,
                  style: CustomCupertinoTextStyles.blackStyle),
            )
          ],
        ),

        // Right side
        Row(
          children: <Widget>[
            // Badge counter
            Visibility(
              visible: widget.badgeCount != null,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: CupertinoColors.destructiveRed,
                    child: Padding(
                      child: Text(widget.badgeCount.toString(),
                          style: CustomCupertinoTextStyles.whiteStyle),
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    ),
                  ),
                ),
              ),
            ),

            // Chevron
            Icon(
              CupertinoIcons.right_chevron,
              color: CustomCupertinoColors.systemGray4,
            )
          ],
        )
      ],
    );
  }
}

/// An item for a list which can represent a Wi-Fi network.
///
/// Allows for various parameters and actions, such as SSID,
/// signal power, add and remove buttons, connected indicator
/// and whether it is protected or not.
class ListWiFiItem extends StatefulWidget {
  ListWiFiItem(
      this.ssid, this.signal, this.connected, this.protected, this.known);

  final String ssid;
  final int signal;
  final bool connected;
  final bool protected;
  final bool known;

  //Function(String, bool);

  @override
  _ListWiFiItemState createState() => _ListWiFiItemState();
}

class _ListWiFiItemState extends State<ListWiFiItem> {
  @override
  Widget build(BuildContext context) {
    return GenericListItem(
      child: Container(
        height: 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(4, 0, 20, 0),
                  width: 68,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 6,
                          width: 6,
                          color: widget.signal >= 1
                              ? (widget.connected
                                  ? CustomCupertinoColors.systemBlue
                                  : CustomCupertinoColors.black)
                              : CustomCupertinoColors.systemGray5,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 6,
                          width: 6,
                          color: widget.signal >= 2
                              ? (widget.connected
                                  ? CustomCupertinoColors.systemBlue
                                  : CustomCupertinoColors.black)
                              : CustomCupertinoColors.systemGray5,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 6,
                          width: 6,
                          color: widget.signal >= 3
                              ? (widget.connected
                                  ? CustomCupertinoColors.systemBlue
                                  : CustomCupertinoColors.black)
                              : CustomCupertinoColors.systemGray5,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 6,
                          width: 6,
                          color: widget.signal >= 4
                              ? (widget.connected
                                  ? CustomCupertinoColors.systemBlue
                                  : CustomCupertinoColors.black)
                              : CustomCupertinoColors.systemGray5,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 6,
                          width: 6,
                          color: widget.signal >= 5
                              ? (widget.connected
                                  ? CustomCupertinoColors.systemBlue
                                  : CustomCupertinoColors.black)
                              : CustomCupertinoColors.systemGray5,
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.protected,
                  child: Container(
                    child: Icon(
                      CupertinoIcons.padlock_closed,
                      size: 20,
                    ),
                    padding: EdgeInsets.fromLTRB(0, 0, 8, 6),
                  ),
                ),
                Text(widget.ssid),
              ],
            ),
            Row(
              children: <Widget>[
                Visibility(
                  visible: (widget.known && !widget.connected),
                  child: Container(
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Icon(
                        CupertinoIcons.remove_item_solid,
                        color: CupertinoColors.destructiveRed,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
                Visibility(
                  visible: !widget.known,
                  child: Container(
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Icon(
                        CupertinoIcons.add,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
