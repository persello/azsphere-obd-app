import 'fuel.dart';

class Vehicle {

  Vehicle({this.brand, this.model, this.vin, this.fuel}) {
    fuel = CommonFuels.undefined;
  }

  // TODO: Image

  String brand;
  String model;
  String vin;

  Fuel fuel;
  
}