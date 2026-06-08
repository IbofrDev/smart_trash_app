import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
    });
  }

  void _handleLogout(BuildContext context) {
    final navigator = Navigator.of(context);
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await authProvider.logout();
              navigator.pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/profile/edit'),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final mahasiswa = authProvider.mahasiswa;

          if (mahasiswa == null) {
            return const Center(child: Text('Data tidak tersedia'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Profile Header ───────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              AppTheme.primaryColor.withValues(alpha: 0.1),
                          backgroundImage: mahasiswa.avatar != null
                              ? NetworkImage(mahasiswa.avatar!)
                              : null,
                          child: mahasiswa.avatar == null
                              ? Text(
                                  mahasiswa.name.isNotEmpty
                                      ? mahasiswa.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          mahasiswa.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mahasiswa.email,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        // Level Badge
                        if (mahasiswa.level != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.emoji_events,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  mahasiswa.level!.namaLevel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Stats Card (Poin + Koin) ─────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 8),
                    child: Row(
                      children: [
                        _statItem(
                          icon: Icons.star,
                          label: 'Total Poin',
                          value: '${mahasiswa.totalPoin}',
                          color: AppTheme.primaryColor,
                        ),
                        Container(
                            width: 1, height: 48, color: Colors.grey[300]),
                        _statItem(
                          icon: Icons.monetization_on,
                          label: 'Koin',
                          value: '${mahasiswa.totalKoinBotol}',
                          color: Colors.amber[700]!,
                        ),
                        Container(
                            width: 1, height: 48, color: Colors.grey[300]),
                        _statItem(
                          icon: Icons.info_outline,
                          label: 'Butuh Voucher',
                          value: mahasiswa.totalKoinBotol >= 20
                              ? 'Siap tukar!'
                              : '${20 - mahasiswa.totalKoinBotol} lagi',
                          color: mahasiswa.totalKoinBotol >= 20
                              ? Colors.green
                              : Colors.grey[600]!,
                          isSmallText: mahasiswa.totalKoinBotol >= 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Profile Info ─────────────────────────────────
                Card(
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.badge,
                        label: 'NIM',
                        value: mahasiswa.nim ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.school,
                        label: 'Program Studi',
                        value: mahasiswa.prodi ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildInfoTile(
                        icon: Icons.credit_card,
                        label: 'RFID UID',
                        value: mahasiswa.rfidUid ?? 'Belum terdaftar',
                        valueColor: mahasiswa.rfidUid == null
                            ? Colors.orange
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Menu Items ───────────────────────────────────
                Card(
                  child: Column(
                    children: [
                      _buildMenuTile(
                        context: context,
                        icon: Icons.history,
                        label: 'Riwayat Transaksi',
                        color: AppTheme.secondaryColor,
                        route: '/transaksi',
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        context: context,
                        icon: Icons.confirmation_number,
                        label: 'Voucher Makan',
                        color: Colors.blue,
                        route: '/voucher',
                        badge: mahasiswa.totalKoinBotol >= 20
                            ? 'Tukar sekarang!'
                            : null,
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        context: context,
                        icon: Icons.emoji_events,
                        label: 'Achievement',
                        color: AppTheme.warningColor,
                        route: '/achievement',
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        context: context,
                        icon: Icons.leaderboard,
                        label: 'Leaderboard',
                        color: AppTheme.primaryColor,
                        route: '/leaderboard',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Logout Button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: const Icon(Icons.logout,
                        color: AppTheme.dangerColor),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: AppTheme.dangerColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.dangerColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── App Version ──────────────────────────────────
                Text(
                  'Smart Trash v2.0.0',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSmallText = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isSmallText ? 12 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required String route,
    String? badge,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (badge != null) const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}