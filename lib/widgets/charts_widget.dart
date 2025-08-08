import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ChartsWidget {
  // بناء مخطط خطي للبيانات الزمنية
  static Widget buildLineChart({
    required Map<String, dynamic> data,
    required String title,
    required Color primaryColor,
    double? height,
  }) {
    return Container(
      height: height ?? 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.surfaceLight,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (data['dailyData'] != null) {
                          final dailyData = data['dailyData'] as List;
                          if (value.toInt() >= 0 &&
                              value.toInt() < dailyData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                dailyData[value.toInt()]['day'] ?? '',
                                style:
                                    AppTypography.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: AppColors.surfaceLight,
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (data['dailyData'] as List?)?.length.toDouble() ?? 7,
                minY: 0,
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateLineSpots(data),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.3),
                          primaryColor.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء مخطط دائري
  static Widget buildPieChart({
    required Map<String, dynamic> data,
    required String title,
    double? height,
  }) {
    return Container(
      height: height ?? 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          // Handle touch events
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: _generatePieChartSections(data),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildPieChartLegend(data),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء مخطط أعمدة
  static Widget buildBarChart({
    required Map<String, dynamic> data,
    required String title,
    required Color primaryColor,
    double? height,
  }) {
    return Container(
      height: height ?? 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue(data).toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.primaryDark,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getBarChartLabel(data, value.toInt()),
                            style: AppTypography.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: _generateBarGroups(data, primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  static List<FlSpot> _generateLineSpots(Map<String, dynamic> data) {
    final spots = <FlSpot>[];
    if (data['dailyData'] != null) {
      final dailyData = data['dailyData'] as List;
      for (int i = 0; i < dailyData.length; i++) {
        spots
            .add(FlSpot(i.toDouble(), (dailyData[i]['count'] ?? 0).toDouble()));
      }
    }
    return spots;
  }

  static List<PieChartSectionData> _generatePieChartSections(
      Map<String, dynamic> data) {
    final sections = <PieChartSectionData>[];
    final colors = [
      const Color(0xFF4CAF50), // Green for approved
      const Color(0xFFFF9800), // Orange for pending
      const Color(0xFFF44336), // Red for rejected
      AppColors.primaryMedium,
      AppColors.primaryLight,
    ];

    int colorIndex = 0;
    final approved = data['approved'] ?? 0;
    final pending = data['pending'] ?? 0;
    final rejected = data['rejected'] ?? 0;
    final total = approved + pending + rejected;

    if (total > 0) {
      if (approved > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex++ % colors.length],
            value: approved.toDouble(),
            title: '${((approved / total) * 100).toInt()}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }

      if (pending > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex++ % colors.length],
            value: pending.toDouble(),
            title: '${((pending / total) * 100).toInt()}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }

      if (rejected > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex++ % colors.length],
            value: rejected.toDouble(),
            title: '${((rejected / total) * 100).toInt()}%',
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    }

    return sections;
  }

  static Widget _buildPieChartLegend(Map<String, dynamic> data) {
    final items = <Widget>[];
    final colors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFFF44336), // Red
    ];

    int colorIndex = 0;
    final approved = data['approved'] ?? 0;
    final pending = data['pending'] ?? 0;
    final rejected = data['rejected'] ?? 0;

    if (approved > 0) {
      items.add(_buildLegendItem('معتمد', approved, colors[colorIndex++]));
    }
    if (pending > 0) {
      items.add(_buildLegendItem('معلق', pending, colors[colorIndex++]));
    }
    if (rejected > 0) {
      items.add(_buildLegendItem('مرفوض', rejected, colors[colorIndex++]));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  static Widget _buildLegendItem(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value.toString(),
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<BarChartGroupData> _generateBarGroups(
      Map<String, dynamic> data, Color color) {
    final groups = <BarChartGroupData>[];

    if (data['departmentBreakdown'] != null) {
      final departments = data['departmentBreakdown'] as Map<String, dynamic>;
      int index = 0;

      departments.forEach((dept, count) {
        groups.add(
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          ),
        );
        index++;
      });
    }

    return groups;
  }

  static String _getBarChartLabel(Map<String, dynamic> data, int index) {
    if (data['departmentBreakdown'] != null) {
      final departments = data['departmentBreakdown'] as Map<String, dynamic>;
      final keys = departments.keys.toList();
      if (index < keys.length) {
        return keys[index].length > 8
            ? '${keys[index].substring(0, 8)}...'
            : keys[index];
      }
    }
    return '';
  }

  static int _getMaxValue(Map<String, dynamic> data) {
    if (data['departmentBreakdown'] != null) {
      final departments = data['departmentBreakdown'] as Map<String, dynamic>;
      final values = departments.values.cast<int>();
      return values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 10;
    }
    return 10;
  }
}
