import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardCard({
    super.key,
    required this.entry,
    this.isCurrentUser = false,
  });

  Widget _buildRankBadge(int rank) {
    Color bgColor;
    Color textColor = Colors.white;
    IconData? icon;

    switch (rank) {
      case 1:
        bgColor = const Color(0xFFFFD700); // Gold
        icon = Icons.emoji_events;
        break;
      case 2:
        bgColor = const Color(0xFFC0C0C0); // Silver
        icon = Icons.emoji_events;
        break;
      case 3:
        bgColor = const Color(0xFFCD7F32); // Bronze
        icon = Icons.emoji_events;
        break;
      default:
        bgColor = Colors.grey[300]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: icon != null
            ? Icon(icon, color: textColor, size: 20)
            : Text(
                '$rank',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isCurrentUser ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrentUser ? AppTheme.primaryColor.withValues(alpha:0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentUser
            ? const BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildRankBadge(entry.ranking),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primaryColor.withValues(alpha:0.1),
              backgroundImage: entry.avatar != null
                  ? NetworkImage(entry.avatar!)
                  : null,
              child: entry.avatar == null
                  ? Text(
                      entry.nama.isNotEmpty 
                          ? entry.nama[0].toUpperCase() 
                          : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.nama,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isCurrentUser 
                                ? AppTheme.primaryColor 
                                : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Kamu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.namaLevel ?? 'Level -',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.totalPoin}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  'poin',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}