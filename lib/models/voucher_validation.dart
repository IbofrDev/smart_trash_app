class VoucherValidation {
  final String kodeVoucher;
  final String status;
  final int koinDigunakan;
  final String? createdAt;
  final String? expiredAt;
  final String? usedAt;
  final String mahasiswaName;
  final String? mahasiswaNim;
  final String? mahasiswaAvatar;

  VoucherValidation({
    required this.kodeVoucher,
    required this.status,
    required this.koinDigunakan,
    this.createdAt,
    this.expiredAt,
    this.usedAt,
    required this.mahasiswaName,
    this.mahasiswaNim,
    this.mahasiswaAvatar,
  });

  factory VoucherValidation.fromJson(Map<String, dynamic> json) {
    final mahasiswa = json['mahasiswa'] as Map<String, dynamic>? ?? {};

    return VoucherValidation(
      kodeVoucher: json['kode_voucher'] ?? '',
      status: json['status'] ?? '',
      koinDigunakan: json['koin_digunakan'] ?? 0,
      createdAt: json['created_at'],
      expiredAt: json['expired_at'],
      usedAt: json['used_at'],
      mahasiswaName: mahasiswa['name'] ?? '-',
      mahasiswaNim: mahasiswa['nim'],
      mahasiswaAvatar: mahasiswa['avatar'],
    );
  }

  bool get isAktif => status == 'aktif';
  bool get isTerpakai => status == 'terpakai';
  bool get isExpired => status == 'expired';
}