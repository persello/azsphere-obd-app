import 'package:azsphere_obd_app/classes/fuel.dart';
import 'package:azsphere_obd_app/classes/vehicle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'package:package_info/package_info.dart';

import 'package:azsphere_obd_app/ioscustomcontrols.dart';
import 'package:azsphere_obd_app/globals.dart';

/// App info page
class SettingsCarProperties extends StatefulWidget {
  SettingsCarProperties(
      {Key key, this.title, this.previousTitle, this.existingVehicleProperties})
      : super(key: key);

  final String title;
  final String previousTitle;
  final Vehicle existingVehicleProperties;

  @override
  _SettingsCarPropertiesState createState() => _SettingsCarPropertiesState();
}

class _SettingsCarPropertiesState extends State<SettingsCarProperties> {
  TextEditingController _brandTextField;
  TextEditingController _modelTextField;
  TextEditingController _vinTextField;

  void showFuelPicker({BuildContext context}) {
    // Gather the list of common fuels
    List<Widget> items = new List<Widget>();
    for (Fuel f in CommonFuels.list) {
      items.add(new Text(f.name));
    }

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 200,
        child: CupertinoPicker(
          children: items,
          itemExtent: 30,
          useMagnifier: true,
          magnification: 1.2,
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
                  isLast: true,
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
                            car.fuel.name,
                            style: CustomCupertinoTextStyles.blackStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Display only if fuel selected
                if (car.fuel.name != 'Not selected')
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
