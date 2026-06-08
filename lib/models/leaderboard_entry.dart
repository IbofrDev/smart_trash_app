double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class LeaderboardEntry {
  final int mahasiswaId;
  final String nama;
  final int totalPoin;
  final double totalBeratKg;
  final int ranking;
  final String? namaLevel;
  final String? avatar;

  LeaderboardEntry({
    required this.mahasiswaId,
    required this.nama,
    required this.totalPoin,
    required this.totalBeratKg,
    required this.ranking,
    this.namaLevel,
    this.avatar,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    // Handle nested mahasiswa object or flat structure
    final mhs = json['mahasiswa'];

    return LeaderboardEntry(
      mahasiswaId: json['mahasiswa_id'] ?? mhs?['id'] ?? 0,
      nama: mhs?['name'] ?? json['nama'] ?? '',
      totalPoin: mhs?['total_poin'] ?? json['total_poin'] ?? 0,
      totalBeratKg: _parseDouble(json['total_berat_kg']),
      ranking: json['ranking'] ??
          json['ranking_mingguan'] ??
          json['ranking_bulanan'] ??
          json['ranking_harian'] ??
          0,
      namaLevel: mhs?['level']?['nama_level'] ?? json['nama_level'],
      avatar: mhs?['avatar'] ?? json['avatar'],
    );
  }
}
