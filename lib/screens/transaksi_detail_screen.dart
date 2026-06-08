import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../providers/transaksi_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';

class TransaksiDetailScreen extends StatefulWidget {
  const TransaksiDetailScreen({super.key});

  @override
  State<TransaksiDetailScreen> createState() => _TransaksiDetailScreenState();
}

class _TransaksiDetailScreenState extends State<TransaksiDetailScreen> {
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded) {
      _isLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }

  Future<void> _loadData() async {
    final id = ModalRoute.of(context)?.settings.arguments as int?;
    if (id != null) {
      await context.read<TransaksiProvider>().loadTransaksiDetail(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransaksiProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Memuat detail...');
          }

          if (provider.errorMessage != null) {
            return ErrorDisplayWidget(
              message: provider.errorMessage!,
              onRetry: _loadData,
            );
          }

          final transaksi = provider.selectedTransaksi;
          if (transaksi == null) {
            return const ErrorDisplayWidget(
              message: 'Transaksi tidak ditemukan',
            );
          }

          // ── Format tanggal & waktu ─────────────────────────────
          String formattedDate = transaksi.tanggalTransaksi;
          String formattedTime = '';
          try {
            final date = DateTime.parse(transaksi.tanggalTransaksi);
            formattedDate =
                DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
            formattedTime = DateFormat('HH:mm', 'id_ID').format(date);
          } catch (_) {}

          // ── Status validasi ────────────────────────────────────
          final bool isAnomali = transaksi.isAnomali;
          final Color statusColor = isAnomali ? Colors.orange : Colors.green;
          final IconData statusIcon =
              isAnomali ? Icons.warning_rounded : Icons.check_circle;
          final String statusLabel =
              isAnomali ? 'Perlu Ditinjau (Anomali)' : 'Transaksi Valid';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Card ──────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 48),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formattedDate,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        if (formattedTime.isNotEmpty)
                          Text(
                            'Pukul $formattedTime WIB',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Reward Card (Poin + Koin) ────────────────────
                Row(
                  children: [
                    // Poin
                    Expanded(
                      child: Card(
                        color: AppTheme.primaryColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          child: Column(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.white, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                '+${transaksi.poinDidapat}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Poin',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Koin
                    Expanded(
                      child: Card(
                        color: Colors.amber[700],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          child: Column(
                            children: [
                              const Icon(Icons.monetization_on,
                                  color: Colors.white, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                '+${transaksi.koinDidapat}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Koin',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Jumlah Sampah Card ───────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jumlah Sampah',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        // Baris jumlah
                        Row(
                          children: [
                            _jumlahItem(
                              label: 'Botol',
                              value: transaksi.jumlahBotol,
                              icon: Icons.water_drop_outlined,
                              color: Colors.blue,
                            ),
                            _jumlahItem(
                              label: 'Kaleng',
                              value: transaksi.jumlahKaleng,
                              icon: Icons.coffee_outlined,
                              color: Colors.grey[700]!,
                            ),
                            _jumlahItem(
                              label: 'Terhitung',
                              value: transaksi.jumlahTerhitung,
                              icon: Icons.calculate_outlined,
                              color: Colors.purple,
                            ),
                            _jumlahItem(
                              label: 'Final',
                              value: transaksi.jumlahFinal,
                              icon: Icons.check_circle_outline,
                              color: statusColor,
                            ),
                          ],
                        ),
                        // Anomali note
                        if (isAnomali) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline,
                                    color: Colors.orange, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Jumlah sampah tidak sesuai dengan berat terukur. '
                                    'Jumlah final dihitung berdasarkan berat.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Detail Info Card ─────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Transaksi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'ID Transaksi',
                          '#${transaksi.id}',
                          Icons.tag,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Jenis Sampah',
                          transaksi.namaJenisSampah,
                          Icons.category,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Berat Terukur',
                          transaksi.beratFormatted,
                          Icons.scale,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Poin per Kg',
                          transaksi.poinPerKg != null
                              ? '${transaksi.poinPerKg} poin/kg'
                              : '-',
                          Icons.star_outline,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Lokasi',
                          transaksi.namaLokasi,
                          Icons.location_on,
                        ),
                        const Divider(height: 24),
                        _buildDetailRow(
                          'Bak Sampah',
                          transaksi.namaBakSampah,
                          Icons.delete_outline,
                        ),
                        const Divider(height: 24),
                        // Status validasi row dengan badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.verified_outlined,
                                  color: statusColor, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status Validasi',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isAnomali ? 'Anomali' : 'Valid',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _jumlahItem({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
