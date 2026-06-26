import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/voucher_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoucherProvider>().loadVouchers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voucher Makan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Terpakai'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: Consumer<VoucherProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.vouchers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.vouchers.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadVouchers(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildKoinCard(context),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVoucherList(provider.vouchersAktif, 'aktif'),
                    _buildVoucherList(provider.vouchersTerpakai, 'terpakai'),
                    _buildVoucherList(provider.vouchersExpired, 'expired'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKoinCard(BuildContext context) {
    final voucherProvider = context.watch<VoucherProvider>();
    final koin = voucherProvider.totalKoin;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saldo Koin',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '🪙 $koin koin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${voucherProvider.koinPerVoucher} koin = 1 voucher makan',
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: koin >= voucherProvider.koinPerVoucher
                ? () => _showRedeemDialog(context)
                : null,
            icon: const Icon(Icons.redeem),
            label: const Text('Tukar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0D47A1),
              disabledBackgroundColor: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherList(List vouchers, String type) {
    if (vouchers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type == 'aktif'
                  ? Icons.confirmation_number_outlined
                  : type == 'terpakai'
                      ? Icons.check_circle_outline
                      : Icons.timer_off_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              type == 'aktif'
                  ? 'Belum ada voucher aktif'
                  : type == 'terpakai'
                      ? 'Belum ada voucher terpakai'
                      : 'Tidak ada voucher expired',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
            if (type == 'aktif') ...[
              const SizedBox(height: 8),
              Text(
                'Tukarkan koin untuk mendapatkan voucher',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<VoucherProvider>().loadVouchers(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: vouchers.length,
        itemBuilder: (context, index) {
          final voucher = vouchers[index];
          return _buildVoucherCard(voucher, type);
        },
      ),
    );
  }

  Widget _buildVoucherCard(dynamic voucher, String type) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    Color statusColor;
    IconData statusIcon;
    switch (type) {
      case 'aktif':
        statusColor = Colors.green;
        statusIcon = Icons.confirmation_number;
        break;
      case 'terpakai':
        statusColor = Colors.grey;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.red;
        statusIcon = Icons.timer_off;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    voucher.kodeVoucher,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type == 'aktif'
                        ? 'Aktif'
                        : type == 'terpakai'
                            ? 'Terpakai'
                            : 'Expired',
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _infoChip(
                    Icons.monetization_on, '${voucher.koinDigunakan} koin'),
                const SizedBox(width: 16),
                if (voucher.expiredAt != null)
                  _infoChip(
                      Icons.event, _formatDate(voucher.expiredAt!, dateFormat)),
              ],
            ),
            if (type == 'aktif') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showVoucherCodeDialog(context, voucher),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Tampilkan Kode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  String _formatDate(String dateStr, DateFormat format) {
    try {
      return format.format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  void _showRedeemDialog(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final voucherProvider = context.read<VoucherProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tukar Koin'),
        content: Text(
            'Tukarkan ${voucherProvider.koinPerVoucher} koin untuk 1 voucher makan?\n\nKoin akan langsung dipotong setelah voucher dibuat. Setelah itu, tunjukkan kode voucher ke kasir untuk divalidasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await voucherProvider.redeemVoucher();

              if (success) {
                dashboardProvider.loadDashboard();
                authProvider.refreshProfile();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(voucherProvider.successMessage ??
                        'Voucher berhasil ditukar!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                        voucherProvider.errorMessage ?? 'Gagal tukar voucher'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }

  void _showVoucherCodeDialog(BuildContext context, dynamic voucher) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kode Voucher'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.confirmation_number, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              voucher.kodeVoucher,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tunjukkan kode ini ke kasir untuk divalidasi.\nVoucher tidak bisa digunakan sendiri oleh mahasiswa.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: voucher.kodeVoucher),
              );

              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Kode voucher berhasil disalin'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Salin Kode'),
          ),
        ],
      ),
    );
  }
}
