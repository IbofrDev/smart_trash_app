import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/achievement.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'trophy':
        return Icons.emoji_events;
      case 'fire':
        return Icons.local_fire_department;
      case 'leaf':
        return Icons.eco;
      case 'medal':
        return Icons.military_tech;
      case 'diamond':
        return Icons.diamond;
      case 'rocket':
        return Icons.rocket_launch;
      case 'crown':
        return Icons.workspace_premium;
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool unlocked = achievement.isUnlocked;
    final Color mainColor = unlocked ? AppTheme.primaryColor : Colors.grey;

    return Card(
      elevation: unlocked ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 190;

            return Container(
              padding: EdgeInsets.all(compact ? 12 : 16),
              decoration: unlocked
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    )
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(compact ? 10 : 12),
                    decoration: BoxDecoration(
                      color: mainColor.withValues(alpha: unlocked ? 0.1 : 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconData(achievement.icon),
                      color: mainColor,
                      size: compact ? 28 : 32,
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 12),
                  Text(
                    achievement.nama,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 13 : 14,
                      color: unlocked ? Colors.black87 : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.syaratLabel,
                    style: TextStyle(
                      fontSize: compact ? 10 : 11,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: compact ? 6 : 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            unlocked ? AppTheme.primaryColor : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        unlocked
                            ? '✓ Unlocked'
                            : '+${achievement.poinBonus} poin',
                        style: TextStyle(
                          fontSize: compact ? 9 : 10,
                          fontWeight: FontWeight.w600,
                          color: unlocked ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
