import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../providers/dashboard_provider.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int _jumlahBotol = 0;
  int _jumlahKaleng = 0;
  bool _sessionCreated = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buang Sampah'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final provider = context.read<SessionProvider>();
            if (provider.hasActiveSession) {
              _showExitDialog(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Consumer<SessionProvider>(
        builder: (context, provider, _) {
          if (!_sessionCreated) {
            return _buildInputForm(context, provider);
          }
          return _buildSessionStatus(context, provider);
        },
      ),
    );
  }

  Widget _buildInputForm(BuildContext context, SessionProvider provider) {
    final total = _jumlahBotol + _jumlahKaleng;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(Icons.recycling, size: 80, color: Colors.green),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Masukkan Jumlah Sampah',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Hitung jumlah botol dan kaleng sebelum dimasukkan ke mesin',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const SizedBox(height: 32),
          _buildCounterCard(
            icon: Icons.local_drink,
            color: Colors.blue,
            label: 'Botol Plastik',
            sublabel: 'Berat per botol: 15-35 gram',
            value: _jumlahBotol,
            onIncrement: () => setState(() => _jumlahBotol++),
            onDecrement: () {
              if (_jumlahBotol > 0) setState(() => _jumlahBotol--);
            },
          ),
          const SizedBox(height: 16),
          _buildCounterCard(
            icon: Icons.takeout_dining,
            color: Colors.orange,
            label: 'Kaleng Aluminium',
            sublabel: 'Berat per kaleng: 10-25 gram',
            value: _jumlahKaleng,
            onIncrement: () => setState(() => _jumlahKaleng++),
            onDecrement: () {
              if (_jumlahKaleng > 0) setState(() => _jumlahKaleng--);
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Item',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text('$total pcs',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: total > 0 && !provider.isLoading
                  ? () => _createSession(context, provider)
                  : null,
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.play_arrow),
              label: Text(provider.isLoading
                  ? 'Membuat Session...'
                  : 'Mulai Buang Sampah'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(provider.errorMessage!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCounterCard({
    required IconData icon,
    required Color color,
    required String label,
    required String sublabel,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ✅ FIX 1
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(sublabel,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Row(
              children: [
                _counterButton(Icons.remove, onDecrement, value > 0),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _counterButton(Icons.add, onIncrement, true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _counterButton(IconData icon, VoidCallback onPressed, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          // ✅ FIX 2
          color:
              enabled ? Colors.green.withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            color: enabled ? Colors.green : Colors.grey[300], size: 20),
      ),
    );
  }

  Future<void> _createSession(
      BuildContext context, SessionProvider provider) async {
    final success = await provider.createSession(
      jumlahBotol: _jumlahBotol,
      jumlahKaleng: _jumlahKaleng,
    );

    if (success) {
      setState(() => _sessionCreated = true);
    }
  }

  Widget _buildSessionStatus(BuildContext context, SessionProvider provider) {
    final session = provider.session;
    if (session == null) {
      return const Center(child: Text('Session tidak ditemukan'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStatusIcon(session.status),
          const SizedBox(height: 24),
          Text(
            _statusTitle(session.status),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _statusMessage(session.status),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 32),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _infoRow('Status', session.status.toUpperCase()),
                  const Divider(),
                  _infoRow('Botol Plastik', '${session.jumlahBotol} pcs'),
                  const Divider(),
                  _infoRow('Kaleng Aluminium', '${session.jumlahKaleng} pcs'),
                  const Divider(),
                  _infoRow('Total',
                      '${session.jumlahBotol + session.jumlahKaleng} pcs'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (session.isProcessing || session.isPending) ...[
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Menunggu proses di mesin...',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
          if (session.isCompleted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.clearSession();
                  context.read<DashboardProvider>().loadDashboard();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: const Text('Selesai'),
              ),
            ),
          ],
          if (session.isExpired) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.clearSession();
                  setState(() {
                    _sessionCreated = false;
                    _jumlahBotol = 0;
                    _jumlahKaleng = 0;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Buat Session Baru'),
              ),
            ),
          ],
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(provider.errorMessage!,
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    double size = 80;

    switch (status) {
      case 'pending':
        icon = Icons.nfc;
        color = Colors.blue;
        break;
      case 'tapped':
        icon = Icons.contactless;
        color = Colors.teal;
        break;
      case 'counting':
        icon = Icons.pin;
        color = Colors.purple;
        break;
      case 'weighing':
        icon = Icons.scale;
        color = Colors.orange;
        break;
      case 'completed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'expired':
        icon = Icons.timer_off;
        color = Colors.red;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // ✅ FIX 3
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size, color: color),
    );
  }

  String _statusTitle(String status) {
    switch (status) {
      case 'pending':
        return 'Tap Kartu RFID';
      case 'tapped':
        return 'Kartu Terdeteksi';
      case 'counting':
        return 'Menghitung...';
      case 'weighing':
        return 'Menimbang...';
      case 'completed':
        return 'Transaksi Selesai! 🎉';
      case 'expired':
        return 'Session Expired';
      default:
        return status;
    }
  }

  String _statusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'Tempelkan kartu RFID kamu ke reader pada mesin tempat sampah pintar';
      case 'tapped':
        return 'Kartu berhasil dibaca. Masukkan sampah ke dalam corong satu per satu.';
      case 'counting':
        return 'Mesin sedang menghitung jumlah sampah yang masuk...';
      case 'weighing':
        return 'Sampah terhitung. Mesin sedang menimbang berat total...';
      case 'completed':
        return 'Sampah berhasil diproses! Poin dan koin sudah ditambahkan.';
      case 'expired':
        return 'Session telah kadaluarsa. Silakan buat session baru.';
      default:
        return '';
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Aktif'),
        content: const Text(
            'Session masih berjalan. Jika kamu keluar, session tetap aktif di background.\n\nYakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tetap di Sini'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
