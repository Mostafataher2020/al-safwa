class BusinessOwner {
  final int? id; // Add an ID field
  final String name;
  final String phone;
  final String factory;

  BusinessOwner({this.id, required this.name, required this.phone, required this.factory});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'factory': factory,
    };
  }

  factory BusinessOwner.fromMap(Map<String, dynamic> map) {
    return BusinessOwner(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      factory: map['factory'],
    );
  }
}
