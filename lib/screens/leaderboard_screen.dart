import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/leaderboard_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/leaderboard_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> _periods = [
    {'value': 'harian', 'label': 'Harian'},
    {'value': 'mingguan', 'label': 'Mingguan'},
    {'value': 'bulanan', 'label': 'Bulanan'},
    {'value': 'alltime', 'label': 'All Time'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _periods.length, vsync: this);
    _tabController.index = 1; // Default: mingguan
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final period = _periods[_tabController.index]['value']!;
    context.read<LeaderboardProvider>().setPeriod(period);
  }

  Future<void> _loadData() async {
    await context.read<LeaderboardProvider>().loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.mahasiswa?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: _periods.map((p) => Tab(text: p['label'])).toList(),
        ),
      ),
      body: Consumer<LeaderboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Memuat leaderboard...');
          }

          if (provider.errorMessage != null) {
            return ErrorDisplayWidget(
              message: provider.errorMessage!,
              onRetry: _loadData,
            );
          }

          if (provider.entries.isEmpty) {
            return EmptyState(
              icon: Icons.leaderboard_outlined,
              title: 'Belum Ada Data',
              subtitle: 'Leaderboard akan muncul setelah ada transaksi',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            color: AppTheme.primaryColor,
            child: Column(
              children: [
                // My Rank Card
                if (provider.myRanking != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Peringkat Kamu',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '#${provider.myRanking}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 40,
                        ),
                      ],
                    ),
                  ),

                // Leaderboard List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.entries.length,
                    itemBuilder: (context, index) {
                      final entry = provider.entries[index];
                      final isCurrentUser = entry.mahasiswaId == currentUserId;

                      return LeaderboardCard(
                        entry: entry,
                        isCurrentUser: isCurrentUser,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
