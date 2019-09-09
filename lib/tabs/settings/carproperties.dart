import 'package:azsphere_obd_app/classes/fuel.dart';
import 'package:azsphere_obd_app/globals.dart';
import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// App info page
class SettingsCarProperties extends StatefulWidget {
  SettingsCarProperties({Key key, this.title, this.previousTitle})
      : super(key: key);

  final String title;
  final String previousTitle;

  @override
  _SettingsCarPropertiesState createState() => _SettingsCarPropertiesState();
}

class _SettingsCarPropertiesState extends State<SettingsCarProperties> {
  TextEditingController _brandTextField;
  TextEditingController _modelTextField;
  TextEditingController _vinTextField;
  FixedExtentScrollController _pickerScrollController;

  void showImagePicker() async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text("Add or change vehicle picture"),
        message: Text("Please choose how to proceed."),
        cancelButton: CupertinoActionSheetAction(
          child: Text("Cancel"),
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          // Gallery
          CupertinoActionSheetAction(
            child: Text("Choose a picture from your gallery"),
            onPressed: () async {
              // Close sheet
              Navigator.of(context, rootNavigator: true).pop(context);

              // Open gallery
              var image = await ImagePicker.pickImage(
                  source: ImageSource.gallery, maxWidth: 1000);

              setState(() {
                car.imagePath = image.path;
              });
            },
          ),

          // Camera
          CupertinoActionSheetAction(
            child: Text("Take a new picture"),
            onPressed: () async {
              // Close sheet
              Navigator.of(context, rootNavigator: true).pop(context);

              // Open camera
              var image = await ImagePicker.pickImage(
                  source: ImageSource.camera, maxWidth: 1000);

              setState(() {
                car.imagePath = image.path;
              });
            },
          ),

          // Remove
          CupertinoActionSheetAction(
            child: Text("Remove"),
            isDestructiveAction: true,
            onPressed: () {
              // Close sheet
              Navigator.of(context, rootNavigator: true).pop(context);

              // Remove
              setState(() {
                car.imagePath = null;
              });
            },
          )
        ],
      ),
    );
  }

  /// Shows the fuel picker and changes the car's [Fuel] property accordingly.
  void showFuelPicker({BuildContext context}) {
    // Gather the list of common fuels
    List<Widget> items = new List<Widget>();
    for (Fuel f in CommonFuels.list) {
      items.add(new Text(f.name));
    }

    // Set to current
    _pickerScrollController = new FixedExtentScrollController(
        initialItem: CommonFuels.list.indexOf(car.fuel));

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 200,
        child: CupertinoPicker(
          children: items,
          itemExtent: 30,
          useMagnifier: true,
          magnification: 1.2,
          scrollController: _pickerScrollController,
          onSelectedItemChanged: (int i) {
            setState(() {
              car.fuel = CommonFuels.list[i];
            });
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _brandTextField = new TextEditingController();
    _modelTextField = new TextEditingController();
    _vinTextField = new TextEditingController();

    if (car.brand != null) _brandTextField.text = car.brand;

    if (car.model != null) _modelTextField.text = car.model;

    if (car.vin != null) _vinTextField.text = car.vin;
  }

  // Save changes to non volatile memory on exit
  @override
  void dispose() {
    car.save();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomCupertinoColors.systemGray6,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
              largeTitle: Text(widget.title),
              previousPageTitle: widget.previousTitle),
          SliverFillRemaining(
            child: Column(
              children: <Widget>[
                ListGroupSpacer(
                  title: "Your car",
                ),

                // Brand
                GenericListItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          "Brand",
                          style: CustomCupertinoTextStyles.secondaryStyle,
                        ),
                      ),
                      CupertinoTextField(
                        decoration: null,
                        placeholder: "Vehicle brand",
                        textCapitalization: TextCapitalization.words,
                        controller: _brandTextField,
                        onChanged: (brand) {
                          car.brand = brand;
                        },
                      ),
                    ],
                  ),
                ),

                // Model
                GenericListItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          "Model",
                          style: CustomCupertinoTextStyles.secondaryStyle,
                        ),
                      ),
                      CupertinoTextField(
                        decoration: null,
                        placeholder: "Vehicle model",
                        textCapitalization: TextCapitalization.words,
                        controller: _modelTextField,
                        onChanged: (model) {
                          car.model = model;
                        },
                      ),
                    ],
                  ),
                ),

                // VIN
                GenericListItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          "VIN",
                          style: CustomCupertinoTextStyles.secondaryStyle,
                        ),
                      ),
                      CupertinoTextField(
                        decoration: null,
                        placeholder: "Vehicle identification number",
                        textCapitalization: TextCapitalization.characters,
                        autocorrect: false,
                        controller: _vinTextField,
                        onChanged: (vin) {
                          car.vin = vin;
                        },
                      ),
                    ],
                  ),
                ),

                // Image
                ListButton(
                  isLast: true,
                  onPressed: () {
                    showImagePicker();
                  },
                  children: <Widget>[
                    Text("Change vehicle picture"),
                    Icon(
                      CupertinoIcons.right_chevron,
                      color: CustomCupertinoColors.systemGray4,
                    )
                  ],
                  padding: EdgeInsets.only(left: 16),
                ),

                ListGroupSpacer(title: "Fuel details"),

                // Fuel
                ListButton(
                  onPressed: () {
                    showFuelPicker(context: context);
                  },
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 12, left: 4),
                          child: Text(
                            "Fuel type",
                            style: CustomCupertinoTextStyles.secondaryStyle,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(6, 6, 0, 10),
                          child: Text(
                            car.fuel?.name,
                            style: CustomCupertinoTextStyles.blackStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Display only if fuel selected
                if (car.fuel?.name != 'Not selected')
                  GenericListItem(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                              "Mass air to fuel ratio is 1:${(1 / car.fuel.massAirFuelRatio).toStringAsFixed(1)}."),

                          // Display density when available
                          if (car.fuel.density != 0)
                            Text(
                                "Density is ${(car.fuel.density).toStringAsFixed(3)} kg/l"),
                        ],
                      ),
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
