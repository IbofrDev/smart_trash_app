class BakSampah {
  final int id;
  final String nama;
  final String? lokasiNama;

  BakSampah({
    required this.id,
    required this.nama,
    this.lokasiNama,
  });

  factory BakSampah.fromJson(Map<String, dynamic> json) {
    return BakSampah(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      lokasiNama: json['lokasi'] is String
          ? json['lokasi']
          : (json['lokasi'] is Map ? json['lokasi']['nama_lokasi'] : null),
    );
  }
}
