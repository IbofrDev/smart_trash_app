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

  Notifikasi copyWith({
    int? id,
    String? judul,
    String? pesan,
    String? tipe,
    bool? isRead,
    String? createdAt,
  }) {
    return Notifikasi(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      pesan: pesan ?? this.pesan,
      tipe: tipe ?? this.tipe,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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