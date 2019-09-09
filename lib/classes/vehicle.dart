import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fuel.dart';

class Vehicle {
  Vehicle({this.brand, this.model, this.vin, this.fuel}) {
    fuel = CommonFuels.undefined;
  }

  String imagePath;

  String brand;
  String model;
  String vin;

  Fuel fuel;

  void save() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    // Car
    sp.setString('car_brand', this.brand);
    sp.setString('car_model', this.model);
    sp.setString('car_vin', this.vin);

    // CommonFuel index
    sp.setInt('car_cf_index', CommonFuels.list.indexOf(this.fuel));

    // Image
    sp.setString('car_imagepath', this.imagePath);
  }

  static Future<Vehicle> restore() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    Vehicle returnCar = new Vehicle();

    // Car (leave null if null)
    returnCar.brand = sp.getString('car_brand');
    returnCar.model = sp.getString('car_model');
    returnCar.vin = sp.getString('car_vin');

    // CommonFuel index
    int index = sp.getInt('car_cf_index');
    if (index == null) {
      returnCar.fuel = CommonFuels.undefined;
    } else {
      returnCar.fuel = CommonFuels.list[index];
    }

    // Image
    returnCar.imagePath = sp.getString('car_imagepath');

    return returnCar;
  }
}
