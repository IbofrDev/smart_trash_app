import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/notifikasi.dart';

class NotifikasiCard extends StatelessWidget {
  final Notifikasi notifikasi;
  final VoidCallback? onTap;

  const NotifikasiCard({
    super.key,
    required this.notifikasi,
    this.onTap,
  });

  Color _getTipeColor(String tipe) {
    switch (tipe) {
      case 'level_up':
        return AppTheme.warningColor;
      case 'achievement':
        return AppTheme.primaryColor;
      case 'transaksi':
        return AppTheme.secondaryColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipeIcon(String tipe) {
    switch (tipe) {
      case 'level_up':
        return Icons.trending_up;
      case 'achievement':
        return Icons.emoji_events;
      case 'transaksi':
        return Icons.recycling;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTipeColor(notifikasi.tipe);
    final bool isUnread = !notifikasi.isRead;

    String formattedDate = '';
    if (notifikasi.createdAt != null) {
      try {
        final date = DateTime.parse(notifikasi.createdAt!);
        formattedDate = DateFormat('dd MMM, HH:mm').format(date);
      } catch (_) {
        formattedDate = notifikasi.createdAt!;
      }
    }

    return Card(
      elevation: isUnread ? 2 : 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: isUnread ? color.withValues(alpha:0.03) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isUnread
            ? BorderSide(color: color.withValues(alpha:0.3), width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTipeIcon(notifikasi.tipe),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notifikasi.judul,
                            style: TextStyle(
                              fontWeight: isUnread 
                                  ? FontWeight.bold 
                                  : FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notifikasi.pesan,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notifikasi.tipeLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}