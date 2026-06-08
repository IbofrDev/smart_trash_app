import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/notifikasi_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/notifikasi_card.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotifikasiProvider>().loadNotifikasi();
    }
  }

  Future<void> _loadData() async {
    await context.read<NotifikasiProvider>().loadNotifikasi(refresh: true);
  }

  void _markAllAsRead() async {
    final provider = context.read<NotifikasiProvider>();
    await provider.markAllAsRead();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua notifikasi ditandai sudah dibaca'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<NotifikasiProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount > 0) {
                return TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text(
                    'Tandai Semua',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotifikasiProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notifikasis.isEmpty) {
            return const LoadingIndicator(message: 'Memuat notifikasi...');
          }

          if (provider.errorMessage != null && provider.notifikasis.isEmpty) {
            return ErrorDisplayWidget(
              message: provider.errorMessage!,
              onRetry: _loadData,
            );
          }

          if (provider.notifikasis.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Belum Ada Notifikasi',
              subtitle: 'Notifikasi akan muncul di sini',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.primaryColor,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount:
                  provider.notifikasis.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.notifikasis.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final notifikasi = provider.notifikasis[index];
                return NotifikasiCard(
                  notifikasi: notifikasi,
                  onTap: () {
                    if (!notifikasi.isRead) {
                      provider.markAsRead(notifikasi.id);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
