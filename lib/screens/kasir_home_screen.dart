import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/kasir_provider.dart';

class KasirHomeScreen extends StatefulWidget {
  const KasirHomeScreen({super.key});

  @override
  State<KasirHomeScreen> createState() => _KasirHomeScreenState();
}

class _KasirHomeScreenState extends State<KasirHomeScreen> {
  final TextEditingController _kodeController = TextEditingController();

  @override
  void dispose() {
    _kodeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _handleCheck(BuildContext context) async {
    final provider = context.read<KasirProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final success = await provider.checkVoucher(_kodeController.text);

    if (!mounted) return;

    if (!success && provider.errorMessage != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleValidate(BuildContext context) async {
    final provider = context.read<KasirProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final success = await provider.validateVoucher(_kodeController.text);

    if (!mounted) return;

    if (success) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(provider.successMessage ?? 'Voucher berhasil divalidasi'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (provider.errorMessage != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final kasirProvider = context.watch<KasirProvider>();
    final kasir = authProvider.kasir;

    final voucher = kasirProvider.voucher;
    final canValidate = voucher != null &&
        voucher.isAktif &&
        !kasirProvider.isSubmitting &&
        !kasirProvider.isChecking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir Smart Trash'),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_kodeController.text.trim().isNotEmpty) {
            await context.read<KasirProvider>().checkVoucher(_kodeController.text);
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildKasirCard(kasir?.name ?? '-', kasir?.email ?? '-'),
            const SizedBox(height: 16),
            _buildInputCard(context, kasirProvider, canValidate),
            const SizedBox(height: 16),
            if (voucher != null) _buildVoucherResultCard(voucher),
            if (voucher == null && kasirProvider.errorMessage == null)
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildKasirCard(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white24,
            child: Icon(Icons.point_of_sale, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Login sebagai Kasir',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(
    BuildContext context,
    KasirProvider provider,
    bool canValidate,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _kodeController,
              enabled: !provider.isBusy,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Kode Voucher',
                hintText: 'Contoh: VCH-ABC123',
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) {
                if (provider.voucher != null ||
                    provider.errorMessage != null ||
                    provider.successMessage != null) {
                  provider.resetResult();
                }
              },
              onSubmitted: (_) => _handleCheck(context),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.isBusy ? null : () => _handleCheck(context),
                    icon: provider.isChecking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: const Text('Cek Voucher'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canValidate ? () => _handleValidate(context) : null,
                    icon: provider.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.verified),
                    label: const Text('Validasi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Cek dulu kode voucher mahasiswa, lalu klik validasi untuk menandai voucher sebagai terpakai.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherResultCard(dynamic voucher) {
    final statusColor = _getStatusColor(voucher.status);
    final statusText = _getStatusText(voucher.status);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_number, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    voucher.kodeVoucher,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
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
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _infoRow(Icons.person, 'Nama Mahasiswa', voucher.mahasiswaName),
            _infoRow(Icons.badge, 'NIM', voucher.mahasiswaNim ?? '-'),
            _infoRow(
              Icons.monetization_on,
              'Koin Digunakan',
              '${voucher.koinDigunakan} koin',
            ),
            _infoRow(
              Icons.event_available,
              'Dibuat',
              _formatDate(voucher.createdAt, dateFormat),
            ),
            _infoRow(
              Icons.schedule,
              'Expired',
              _formatDate(voucher.expiredAt, dateFormat),
            ),
            if (voucher.usedAt != null)
              _infoRow(
                Icons.check_circle,
                'Digunakan',
                _formatDate(voucher.usedAt, dateFormat),
              ),
            if (voucher.isExpired) ...[
              const SizedBox(height: 12),
              _statusBanner(
                color: Colors.red,
                text: 'Voucher ini sudah expired dan tidak bisa divalidasi.',
              ),
            ],
            if (voucher.isTerpakai) ...[
              const SizedBox(height: 12),
              _statusBanner(
                color: Colors.grey,
                text: 'Voucher ini sudah pernah digunakan sebelumnya.',
              ),
            ],
            if (voucher.isAktif) ...[
              const SizedBox(height: 12),
              _statusBanner(
                color: Colors.green,
                text: 'Voucher aktif dan siap divalidasi oleh kasir.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusBanner({required Color color, required String text}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 13),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(
              Icons.qr_code_2_outlined,
              size: 64,
              color: Colors.grey[350],
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada voucher yang dicek',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Masukkan kode voucher mahasiswa lalu tekan tombol "Cek Voucher".',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'aktif':
        return Colors.green;
      case 'terpakai':
        return Colors.grey;
      case 'expired':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'aktif':
        return 'Aktif';
      case 'terpakai':
        return 'Terpakai';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  String _formatDate(String? value, DateFormat format) {
    if (value == null || value.isEmpty) return '-';

    try {
      return format.format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }
}