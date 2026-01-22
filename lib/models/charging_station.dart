class ChargingStation {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String? city;
  final String? address;
  // For filtering on the map
  final List<String> connectorTypes;
  final List<double> connectorPowers;
  final bool hasAvailableConnector;
  // Map of connector type -> isAvailable (true if at least one of that type is available)
  final Map<String, bool> connectorAvailability;
  // Station status
  final bool isOffline; // All connectors are offline
  final bool isBusy; // All connectors are busy (but not offline)

  ChargingStation({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.city,
    this.address,
    this.connectorTypes = const [],
    this.connectorPowers = const [],
    this.hasAvailableConnector = true,
    this.connectorAvailability = const {},
    this.isOffline = false,
    this.isBusy = false,
  });

  factory ChargingStation.fromJson(Map<String, dynamic> json) => ChargingStation(
        id: json['id'] as String,
        name: json['name'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        city: json['city'] as String?,
        address: json['address'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
        'city': city,
        'address': address,
      };
}
