class Order {
  final int id;
  final String timeSlot;
  final int inventory;
  final double latitude;
  final double longitude;

  Order({
    required this.id,
    required this.timeSlot,
    required this.inventory,
    required this.latitude,
    required this.longitude,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      timeSlot: json['time_slot'],
      inventory: json['inventory'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time_slot': timeSlot,
      'inventory': inventory,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return 'Order(id: $id, timeSlot: $timeSlot, inventory: $inventory, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 