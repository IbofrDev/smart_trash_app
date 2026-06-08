class Achievement {
  final int id;
  final String nama;
  final String? deskripsi;
  final String? icon;
  final String syaratType;
  final int syaratValue;
  final int poinBonus;
  final bool isUnlocked;
  final String? unlockedAt;

  Achievement({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.icon,
    required this.syaratType,
    required this.syaratValue,
    required this.poinBonus,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'],
      icon: json['icon'],
      syaratType: json['syarat_type'] ?? '',
      syaratValue: json['syarat_value'] ?? 0,
      poinBonus: json['poin_bonus'] ?? 0,
      isUnlocked: json['is_unlocked'] ?? false,
      unlockedAt: json['unlocked_at'] ?? json['pivot']?['unlocked_at'],
    );
  }

  String get syaratLabel {
    switch (syaratType) {
      case 'total_kg':
        return 'Kumpulkan $syaratValue kg';
      case 'streak':
        return 'Streak $syaratValue hari';
      case 'transaksi_count':
        return '$syaratValue transaksi';
      case 'first_time':
        return 'Transaksi pertama';
      default:
        return syaratType;
    }
  }
}