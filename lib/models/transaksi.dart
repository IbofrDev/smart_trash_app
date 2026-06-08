import 'bak_sampah.dart';
import 'jenis_sampah.dart';

class Transaksi {
  final int id;
  final int? mahasiswaId;
  final double berat;
  final int poinDidapat;
  final int koinDidapat;
  final int jumlahBotol;
  final int jumlahKaleng;
  final int jumlahTerhitung;
  final int jumlahFinal;
  final String statusValidasi;
  final String tanggalTransaksi;
  final String? mahasiswaNama;
  final String? mahasiswaNim;

  // For list endpoint (string values)
  final String? jenisSampahNama;
  final String? bakSampahNama;
  final String? lokasiNama;

  // For detail endpoint (object values)
  final JenisSampah? jenisSampah;
  final BakSampah? bakSampah;

  Transaksi({
    required this.id,
    this.mahasiswaId,
    required this.berat,
    required this.poinDidapat,
    this.koinDidapat = 0,
    this.jumlahBotol = 0,
    this.jumlahKaleng = 0,
    this.jumlahTerhitung = 0,
    this.jumlahFinal = 0,
    this.statusValidasi = 'valid',
    required this.tanggalTransaksi,
    this.mahasiswaNama,
    this.mahasiswaNim,
    this.jenisSampahNama,
    this.bakSampahNama,
    this.lokasiNama,
    this.jenisSampah,
    this.bakSampah,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    final bool isDetailFormat = json['jenis_sampah'] is Map;

    return Transaksi(
      id: json['id'] ?? 0,
      mahasiswaId: json['mahasiswa_id'],
      berat: _parseDouble(json['berat_gram'] ?? json['berat']),
      poinDidapat: json['poin_didapat'] ?? json['poin'] ?? 0,
      koinDidapat: json['koin_didapat'] ?? json['koin'] ?? 0,
      jumlahBotol: json['jumlah_botol'] ?? json['jumlah_input_botol'] ?? 0,
      jumlahKaleng: json['jumlah_kaleng'] ?? json['jumlah_input_kaleng'] ?? 0,
      jumlahTerhitung: json['jumlah_terhitung'] ?? 0,
      jumlahFinal: json['jumlah_final'] ?? 0,
      statusValidasi: json['status_validasi'] ?? 'valid',
      tanggalTransaksi: json['tanggal_transaksi'] ?? json['tanggal'] ?? '',
      mahasiswaNama: json['mahasiswa']?['name'],
      mahasiswaNim: json['mahasiswa']?['nim'],
      jenisSampahNama: isDetailFormat ? null : json['jenis_sampah'],
      bakSampahNama: isDetailFormat ? null : json['bak_sampah'],
      lokasiNama: isDetailFormat ? null : json['lokasi'],
      jenisSampah: json['jenis_sampah'] is Map
          ? JenisSampah.fromJson(json['jenis_sampah'])
          : null,
      bakSampah: json['bak_sampah'] is Map
          ? BakSampah.fromJson(json['bak_sampah'])
          : null,
    );
  }

  // ✅ Getter aman: fallback berlapis
  String get namaJenisSampah => jenisSampahNama ?? jenisSampah?.nama ?? '-';
  String get namaBakSampah => bakSampahNama ?? bakSampah?.nama ?? '-';
  String get namaLokasi => lokasiNama ?? bakSampah?.lokasiNama ?? '-';

  int? get poinPerKg => jenisSampah?.poinPerKg;
  bool get isAnomali => statusValidasi == 'anomali';

  String get beratFormatted {
    if (berat >= 1000) {
      return '${(berat / 1000).toStringAsFixed(2)} kg';
    }
    return '${berat.toStringAsFixed(0)} g';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
