class Kasir {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  Kasir({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory Kasir.fromJson(Map<String, dynamic> json) {
    return Kasir(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'kasir',
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}