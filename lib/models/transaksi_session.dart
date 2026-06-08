class TransaksiSession {
  final int id;
  final String sessionToken;
  final String status;
  final int jumlahBotol;
  final int jumlahKaleng;
  final String? expiredAt;
  final String? createdAt;

  TransaksiSession({
    required this.id,
    required this.sessionToken,
    required this.status,
    this.jumlahBotol = 0,
    this.jumlahKaleng = 0,
    this.expiredAt,
    this.createdAt,
  });

  factory TransaksiSession.fromJson(Map<String, dynamic> json) {
    return TransaksiSession(
      id: json['id'] ?? 0,
      sessionToken: json['session_token'] ?? '',
      status: json['status'] ?? 'pending',
      jumlahBotol: json['jumlah_botol'] ?? 0,
      jumlahKaleng: json['jumlah_kaleng'] ?? 0,
      expiredAt: json['expired_at'],
      createdAt: json['created_at'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isTapped => status == 'tapped';
  bool get isWeighing => status == 'weighing';
  bool get isCounting => status == 'counting';
  bool get isCompleted => status == 'completed';
  bool get isExpired => status == 'expired';
  bool get isProcessing => ['tapped', 'weighing', 'counting'].contains(status);
}