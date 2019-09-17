import 'package:hive/hive.dart';

import '../globals.dart';
import 'fuel.dart';

part 'vehicle.g.dart';

@HiveType()
class Vehicle {
  Vehicle({this.brand, this.model, this.vin, this.fuel}) {
    fuel = CommonFuels.undefined;

    logger.v('Vehicle constructor called, opening "vehicle-data" Hive box.');
    _hiveReady = _getVehicleBox();
  }

  Future _getVehicleBox() async {
    if (!Hive.isBoxOpen('vehicle-data')) {
      storedVehicleData = await Hive.openBox('vehicle-data');
    } else {
      storedVehicleData = Hive.box('vehicle-data');
    }
  }

  @HiveField(0)
  String imagePath;

  @HiveField(1)
  String brand;
  @HiveField(2)
  String model;
  @HiveField(3)
  String vin;
  @HiveField(4)
  Fuel fuel;

  Box storedVehicleData;
  Future _hiveReady;

  Future get hiveReady => _hiveReady;

  void save() async {
    logger.v('Saving vehicle data');

    // Wait for hive initialization
    await this.hiveReady;

    storedVehicleData.put('vehicle', this);

    logger.d('Image path is "${this.imagePath}.');
  }

  Future<Vehicle> restore() async {
    logger.v('Restoring vehicle data.');

    Vehicle returnCar = new Vehicle();

    // Wait for hive initialization
    await this.hiveReady;

    returnCar = storedVehicleData.get('vehicle', defaultValue: new Vehicle());

    // CommonFuel index
    if (returnCar.fuel.name == null) {
      returnCar.fuel = CommonFuels.undefined;
    }

    logger.d('Restored fuel is ${returnCar.fuel.name}.');

    logger.d('Restored image path is ${returnCar.imagePath}.');

    return returnCar;
  }
}
