class BusinessOwner {
  final String name;
  final String phone;

  BusinessOwner({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
    };
  }

  factory BusinessOwner.fromMap(Map<String, dynamic> map) {
    return BusinessOwner(
      name: map['name'],
      phone: map['phone'],
    );
  }
}