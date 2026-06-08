double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class DashboardData {
  final String name;
  final String? avatar;
  final String? nim;
  final String? prodi;
  final int totalPoin;
  final int totalKoin;
  final int voucherAktif;
  final int totalBotol;
  final String levelName;
  final int levelUrutan;
  final String? nextLevelName;
  final double levelProgress;
  final double totalBeratGram;
  final int totalTransaksi;
  final int? ranking;
  final List<RecentTransaction> recentTransactions;

  DashboardData({
    required this.name,
    this.avatar,
    this.nim,
    this.prodi,
    required this.totalPoin,
    this.totalKoin = 0,
    this.voucherAktif = 0,
    this.totalBotol = 0,
    required this.levelName,
    required this.levelUrutan,
    this.nextLevelName,
    required this.levelProgress,
    required this.totalBeratGram,
    required this.totalTransaksi,
    this.ranking,
    required this.recentTransactions,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final mahasiswa = json['mahasiswa'] ?? {};
    final poin = json['poin'] ?? {};
    final stats = json['stats'] ?? {};
    final transactions = json['recent_transactions'] as List? ?? [];

    return DashboardData(
      name: mahasiswa['name'] ?? '',
      avatar: mahasiswa['avatar'],
      nim: mahasiswa['nim'],
      prodi: mahasiswa['prodi'],
      totalPoin: poin['total'] ?? 0,
      totalKoin: stats['total_koin'] ?? 0,
      voucherAktif: stats['voucher_aktif'] ?? 0,
      totalBotol: stats['total_botol'] ?? 0,
      levelName: poin['level'] ?? '',
      levelUrutan: poin['level_urutan'] ?? 1,
      nextLevelName: poin['next_level'],
      levelProgress: _parseDouble(poin['progress_percentage']),
      totalBeratGram: _parseDouble(stats['total_berat_gram']),
      totalTransaksi: stats['total_transaksi'] ?? 0,
      ranking: stats['ranking'],
      recentTransactions:
          transactions.map((e) => RecentTransaction.fromJson(e)).toList(),
    );
  }

  /// Helper: berat dalam kg untuk display
  String get beratFormatted {
    if (totalBeratGram >= 1000) {
      return '${(totalBeratGram / 1000).toStringAsFixed(2)} kg';
    }
    return '${totalBeratGram.toStringAsFixed(0)} g';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class RecentTransaction {
  final int id;
  final String jenisSampah;
  final double berat;
  final int poin;
  final int koin;
  final int jumlahFinal;
  final String lokasi;
  final String tanggal;
  final String statusValidasi;
  

  RecentTransaction({
    required this.id,
    required this.jenisSampah,
    required this.berat,
    required this.poin,
    this.koin = 0,
    this.jumlahFinal = 0,
    required this.lokasi,
    required this.tanggal,
    this.statusValidasi = 'valid',
  });

  factory RecentTransaction.fromJson(Map<String, dynamic> json) {
    return RecentTransaction(
      id: json['id'] ?? 0,
      jenisSampah: json['jenis_sampah'] ?? '',
      berat: DashboardData._parseDouble(json['berat']),
      poin: json['poin'] ?? 0,
      koin: json['koin'] ?? 0,
      jumlahFinal: json['jumlah_final'] ?? 0,
      lokasi: json['lokasi'] ?? '-',
      tanggal: json['tanggal'] ?? '',
      statusValidasi: json['status_validasi'] ?? 'valid',
    );
  }
}
