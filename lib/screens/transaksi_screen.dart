import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/transaksi_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaksi_card.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
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
    final provider = context.read<TransaksiProvider>();
    if (provider.isLoading || !provider.hasMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      provider.loadTransaksi();
    }
  }

  Future<void> _loadData() async {
    await context.read<TransaksiProvider>().loadTransaksi(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Period Filter
          Consumer<TransaksiProvider>(
            builder: (context, provider, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: '7 Hari',
                      value: '7days',
                      selected: provider.period == '7days',
                      onSelected: () => provider.setPeriod('7days'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: '30 Hari',
                      value: '30days',
                      selected: provider.period == '30days',
                      onSelected: () => provider.setPeriod('30days'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Semua',
                      value: 'all',
                      selected: provider.period == 'all',
                      onSelected: () => provider.setPeriod('all'),
                    ),
                  ],
                ),
              );
            },
          ),
          // Transaksi List
          Expanded(
            child: Consumer<TransaksiProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.transaksis.isEmpty) {
                  return const LoadingIndicator(message: 'Memuat transaksi...');
                }

                if (provider.errorMessage != null &&
                    provider.transaksis.isEmpty) {
                  return ErrorDisplayWidget(
                    message: provider.errorMessage!,
                    onRetry: _loadData,
                  );
                }

                if (provider.transaksiFiltered.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum Ada Transaksi',
                    subtitle: 'Transaksi Anda akan muncul di sini',
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.transaksiFiltered.length +
                        (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.transaksiFiltered.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final transaksi = provider.transaksiFiltered[index];
                      return TransaksiCard(
                        transaksi: transaksi,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/transaksi/detail',
                            arguments: transaksi.id,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: selected ? AppTheme.primaryColor : Colors.grey[700],
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}
