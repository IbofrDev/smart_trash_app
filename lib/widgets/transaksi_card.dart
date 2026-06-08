import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/transaksi.dart';
import '../models/dashboard_data.dart';

class TransaksiCard extends StatelessWidget {
  final Transaksi? transaksi;
  final RecentTransaction? recentTransaction;
  final VoidCallback? onTap;

  const TransaksiCard({
    super.key,
    this.transaksi,
    this.recentTransaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ── Data dari salah satu sumber ──────────────────────────────
    final String tanggal =
        transaksi?.tanggalTransaksi ?? recentTransaction?.tanggal ?? '';
    final String lokasi =
        transaksi?.namaLokasi ?? recentTransaction?.lokasi ?? '-';
    final int poin = transaksi?.poinDidapat ?? recentTransaction?.poin ?? 0;

    // Berat: Transaksi simpan gram, RecentTransaction juga gram
    final double beratGram = transaksi?.berat ?? recentTransaction?.berat ?? 0;

    // Field baru
    final int koin = transaksi?.koinDidapat ?? recentTransaction?.koin ?? 0;
    final int jumlahBotol = transaksi?.jumlahBotol ?? 0;
    final int jumlahKaleng = transaksi?.jumlahKaleng ?? 0;
    final int jumlahFinal =
        transaksi?.jumlahFinal ?? recentTransaction?.jumlahFinal ?? 0;
    final String statusValidasi = transaksi?.statusValidasi ??
        recentTransaction?.statusValidasi ??
        'valid';

    // ── Format tanggal ───────────────────────────────────────────
    String formattedDate = tanggal;
    try {
      final date = DateTime.parse(tanggal);
      formattedDate = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (_) {}

    // ── Format berat ─────────────────────────────────────────────
    final String beratFormatted = beratGram >= 1000
        ? '${(beratGram / 1000).toStringAsFixed(2)} kg'
        : '${beratGram.toStringAsFixed(0)} g';

    // ── Status validasi ──────────────────────────────────────────
    final bool isAnomali = statusValidasi == 'anomali';
    final Color statusColor = isAnomali ? Colors.orange : Colors.green;

    // ── Label jenis sampah ───────────────────────────────────────
    final String labelSampah;
    if (transaksi != null) {
      labelSampah = transaksi!.namaJenisSampah;
    } else {
      final jenis = recentTransaction?.jenisSampah ?? '';
      labelSampah = jenis.isNotEmpty 
          ? jenis 
          : (jumlahFinal > 0 ? '$jumlahFinal item daur ulang' : 'Sampah Daur Ulang');
    }
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ── Icon kiri ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isAnomali ? Icons.warning_rounded : Icons.recycling,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // ── Tengah: label + lokasi + jumlah ───────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            labelSampah,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (isAnomali)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Anomali',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$lokasi • $formattedDate',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Breakdown botol + kaleng (hanya jika ada data)
                    if (transaksi != null &&
                        (jumlahBotol > 0 || jumlahKaleng > 0))
                      Text(
                        _buildBreakdown(jumlahBotol, jumlahKaleng, jumlahFinal),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                  ],
                ),
              ),

              // ── Kanan: berat + poin + koin ────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    beratFormatted,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Poin badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+$poin poin',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  // Koin badge (hanya jika ada)
                  if (koin > 0) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+$koin koin',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _buildBreakdown(int botol, int kaleng, int final_) {
    final parts = <String>[];
    if (botol > 0) parts.add('$botol botol');
    if (kaleng > 0) parts.add('$kaleng kaleng');
    final itemStr = parts.join(' + ');
    if (final_ != botol + kaleng && final_ > 0) {
      return '$itemStr → $final_ tervalidasi';
    }
    return itemStr;
  }
}
