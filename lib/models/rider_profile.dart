class RiderProfile {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String vehicleNumber;
  final String vehicleType;

  RiderProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.vehicleNumber,
    required this.vehicleType,
  });

  factory RiderProfile.fromJson(Map<String, dynamic> json) {
    return RiderProfile(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      vehicleNumber: json['vehicle_number'],
      vehicleType: json['vehicle_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
    };
  }

  @override
  String toString() {
    return 'RiderProfile(id: $id, name: $name, phone: $phone)';
  }
} 