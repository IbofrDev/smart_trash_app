class Voucher {
  final int id;
  final String kodeVoucher;
  final String status;
  final int koinDigunakan;
  final String? createdAt;
  final String? expiredAt;
  final String? usedAt;

  Voucher({
    required this.id,
    required this.kodeVoucher,
    required this.status,
    this.koinDigunakan = 0,
    this.createdAt,
    this.expiredAt,
    this.usedAt,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'] ?? 0,
      kodeVoucher: json['kode_voucher'] ?? '',
      status: json['status'] ?? 'aktif',
      koinDigunakan: json['koin_digunakan'] ?? 0,
      createdAt: json['created_at'],
      expiredAt: json['expired_at'],
      usedAt: json['used_at'],
    );
  }

  bool get isAktif => status == 'aktif';
  bool get isTerpakai => status == 'terpakai';
  bool get isExpired => status == 'expired';
}