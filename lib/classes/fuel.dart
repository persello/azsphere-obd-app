/// Represents a type of fuel that can be used in a vehicle.
class Fuel {
  const Fuel({this.name, this.massAirFuelRatio, this.density});

  /// The name of the fuel.
  final String name;

  /// The default air to fuel ratio in terms of mass (stoichiometric ratio).
  final double massAirFuelRatio;

  /// Density of the fuel in kg per liter.
  final double density;
}

/// List of common fuel types
class CommonFuels {

  // Undefined fuel
  static const Fuel undefined = Fuel(name: 'Not selected', massAirFuelRatio: (0), density: 0);

  static const List<Fuel> list = [
    Fuel(name: 'Diesel', massAirFuelRatio: (1 / 14.6), density: 0.832),
    Fuel(name: 'Gasoline', massAirFuelRatio: (1 / 14.7), density: 0.719),
    Fuel(name: 'Natural gas', massAirFuelRatio: (1 / 17.2), density: 0),
    Fuel(name: 'Propane', massAirFuelRatio: (1 / 15.5), density: 0),
    Fuel(name: 'Ethanol', massAirFuelRatio: (1 / 9), density: 0.789),
    Fuel(name: 'Methanol', massAirFuelRatio: (1 / 6.4), density: 0.792),
  ];
}
