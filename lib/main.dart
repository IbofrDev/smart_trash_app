import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/kasir_home_screen.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/transaksi_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/notifikasi_provider.dart';
import 'providers/voucher_provider.dart';
import 'providers/session_provider.dart';
import 'providers/kasir_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transaksi_screen.dart';
import 'screens/transaksi_detail_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/notifikasi_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/voucher_screen.dart';
import 'screens/session_screen.dart';
import 'screens/kasir_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => TransaksiProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => NotifikasiProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => KasirProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Trash',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/transaksi': (context) => const TransaksiScreen(),
          '/transaksi/detail': (context) => const TransaksiDetailScreen(),
          '/leaderboard': (context) => const LeaderboardScreen(),
          '/achievement': (context) => const AchievementScreen(),
          '/notifikasi': (context) => const NotifikasiScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/profile/edit': (context) => const EditProfileScreen(),
          '/voucher': (context) => const VoucherScreen(),
          '/session': (context) => const SessionScreen(),
          '/kasir': (context) => const KasirHomeScreen(),
        },
      ),
    );
  }
}
