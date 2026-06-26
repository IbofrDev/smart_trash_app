import 'level.dart';

class Mahasiswa {
  final int id;
  final String? googleId;
  final String email;
  final String name;
  final String? nim;
  final String? prodi;
  final String? rfidUid;
  final int totalPoin;
  final int totalKoinBotol;
  final int? levelId;
  final Level? level;
  final String? avatar;
  final int koinPerVoucher;

  Mahasiswa({
    required this.id,
    this.googleId,
    required this.email,
    required this.name,
    this.nim,
    this.prodi,
    this.rfidUid,
    required this.totalPoin,
    this.totalKoinBotol = 0,
    this.levelId,
    this.level,
    this.avatar,
    this.koinPerVoucher = 20,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      id: json['id'] ?? 0,
      googleId: json['google_id'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      nim: json['nim'],
      prodi: json['prodi'],
      rfidUid: json['rfid_uid'],
      totalPoin: json['total_poin'] ?? 0,
      totalKoinBotol: json['total_koin_botol'] ?? 0,
      koinPerVoucher: json['koin_per_voucher'] ?? 20,
      levelId: json['level_id'],
      level: json['level'] != null && json['level'] is Map<String, dynamic>
          ? Level.fromJson(json['level'] as Map<String, dynamic>)
          : null,
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nim': nim,
      'prodi': prodi,
    };
  }
}
