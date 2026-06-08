class JenisSampah {
  final int id;
  final String nama;
  final String? deskripsi;
  final int poinPerKg;
  final String satuan;

  JenisSampah({
    required this.id,
    required this.nama,
    this.deskripsi,
    required this.poinPerKg,
    required this.satuan,
  });

  factory JenisSampah.fromJson(Map<String, dynamic> json) {
    return JenisSampah(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'],
      poinPerKg: json['poin_per_kg'] ?? 0,
      satuan: json['satuan'] ?? 'kg',
    );
  }
}