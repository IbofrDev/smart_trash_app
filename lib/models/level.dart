class Level {
  final int id;
  final String namaLevel;
  final int minPoin;
  final int maxPoin;
  final int urutan;

  Level({
    required this.id,
    required this.namaLevel,
    required this.minPoin,
    required this.maxPoin,
    required this.urutan,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] ?? 0,
      namaLevel: json['nama_level'] ?? '',
      minPoin: json['min_poin'] ?? 0,
      maxPoin: json['max_poin'] ?? 0,
      urutan: json['urutan'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_level': namaLevel,
      'min_poin': minPoin,
      'max_poin': maxPoin,
      'urutan': urutan,
    };
  }
}