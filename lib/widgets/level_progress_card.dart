import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../config/app_theme.dart';

class LevelProgressCard extends StatelessWidget {
  final String currentLevel;
  final String? nextLevel;
  final int totalPoin;
  final double progress; // 0-100

  const LevelProgressCard({
    super.key,
    required this.currentLevel,
    this.nextLevel,
    required this.totalPoin,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent = (progress / 100).clamp(0.0, 1.0);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentLevel,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$totalPoin Poin',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              lineHeight: 12,
              percent: progressPercent,
              backgroundColor: Colors.grey[200],
              progressColor: AppTheme.primaryColor,
              barRadius: const Radius.circular(6),
              padding: EdgeInsets.zero,
            ),
            if (nextLevel != null) ...[
              const SizedBox(height: 8),
              Text(
                'Level berikutnya: $nextLevel',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            if (nextLevel == null) ...[
              const SizedBox(height: 8),
              const Text(
                '🎉 Level maksimum tercapai!',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}