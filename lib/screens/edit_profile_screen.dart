import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/mahasiswa.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _prodiController = TextEditingController();
  final _rfidController = TextEditingController();

  bool _isLoading = false;
  bool _isRfidLoading = false;

 @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadCurrentData();
  });
}

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _rfidController.dispose();
    super.dispose();
  }

  void _loadCurrentData() {
    final mahasiswa = context.read<AuthProvider>().mahasiswa;
    if (mahasiswa != null) {
      _nameController.text = mahasiswa.name;
      _nimController.text = mahasiswa.nim ?? '';
      _prodiController.text = mahasiswa.prodi ?? '';
      _rfidController.text = mahasiswa.rfidUid ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.updateProfile({
        'name': _nameController.text.trim(),
        'nim': _nimController.text.trim(),
        'prodi': _prodiController.text.trim(),
      });

      if (!mounted) return;

      if (response.success) {
        // Update local state
        final authProvider = context.read<AuthProvider>();
        final currentMahasiswa = authProvider.mahasiswa;
        
        if (currentMahasiswa != null) {
          final updated = Mahasiswa(
            id: currentMahasiswa.id,
            googleId: currentMahasiswa.googleId,
            email: currentMahasiswa.email,
            name: _nameController.text.trim(),
            nim: _nimController.text.trim(),
            prodi: _prodiController.text.trim(),
            rfidUid: currentMahasiswa.rfidUid,
            totalPoin: currentMahasiswa.totalPoin,
            levelId: currentMahasiswa.levelId,
            level: currentMahasiswa.level,
            avatar: currentMahasiswa.avatar,
          );
          authProvider.updateMahasiswa(updated);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRfid() async {
    final rfid = _rfidController.text.trim();
    if (rfid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan RFID UID terlebih dahulu'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _isRfidLoading = true);

    try {
      final response = await ApiService.updateRfid(rfid);

      if (!mounted) return;

      if (response.success) {
        // Update local state
        final authProvider = context.read<AuthProvider>();
        final currentMahasiswa = authProvider.mahasiswa;
        
        if (currentMahasiswa != null) {
          final updated = Mahasiswa(
            id: currentMahasiswa.id,
            googleId: currentMahasiswa.googleId,
            email: currentMahasiswa.email,
            name: currentMahasiswa.name,
            nim: currentMahasiswa.nim,
            prodi: currentMahasiswa.prodi,
            rfidUid: rfid,
            totalPoin: currentMahasiswa.totalPoin,
            levelId: currentMahasiswa.levelId,
            level: currentMahasiswa.level,
            avatar: currentMahasiswa.avatar,
          );
          authProvider.updateMahasiswa(updated);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('RFID berhasil didaftarkan'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isRfidLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Dasar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nimController,
                        decoration: const InputDecoration(
                          labelText: 'NIM',
                          prefixIcon: Icon(Icons.badge),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _prodiController,
                        decoration: const InputDecoration(
                          labelText: 'Program Studi',
                          prefixIcon: Icon(Icons.school),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Save Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Profil',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // RFID Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.credit_card,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RFID Card',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Untuk tap di bak sampah pintar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _rfidController,
                        decoration: const InputDecoration(
                          labelText: 'RFID UID',
                          prefixIcon: Icon(Icons.nfc),
                          hintText: 'Contoh: A1B2C3D4',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isRfidLoading ? null : _updateRfid,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppTheme.secondaryColor),
                          ),
                          child: _isRfidLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Daftarkan RFID',
                                  style: TextStyle(color: AppTheme.secondaryColor),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}