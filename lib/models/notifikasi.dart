class Notifikasi {
  final int id;
  final String judul;
  final String pesan;
  final String tipe;
  final bool isRead;
  final String? createdAt;

  Notifikasi({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.isRead,
    this.createdAt,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      pesan: json['pesan'] ?? '',
      tipe: json['tipe'] ?? '',
     isRead: json['is_read'] == 1 || json['is_read'] == true || json['is_read'] == '1',
      createdAt: json['created_at'],
    );
  }

  String get tipeLabel {
    switch (tipe) {
      case 'level_up':
        return '🎉 Level Up';
      case 'achievement':
        return '🏆 Achievement';
      case 'transaksi':
        return '♻️ Transaksi';
      case 'info':
        return 'ℹ️ Info';
      default:
        return tipe;
    }
  }
}