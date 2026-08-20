import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:smart_expense_co2/services/api_service.dart';
import 'package:smart_expense_co2/utils/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _monthlyData;
  bool _isLoading = true;
  late TabController _tabController;
  int _touchedPieIndex = -1;

  Map<String, dynamic>? _forecast;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final response = await apiService.getMonthlyAnalytics().timeout(const Duration(seconds: 4), onTimeout: () => {});
      final forecastData = await apiService.getForecast().timeout(const Duration(seconds: 4), onTimeout: () => null);
      if (mounted) {
        setState(() {
          _monthlyData = response;
          _forecast = forecastData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))
          : CustomScrollView(
              slivers: [
                _buildHeaderAppBar(isDark),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEcoGradeCard(isDark),
                        _buildPredictiveForecastCard(isDark),
                        const SizedBox(height: 20),
                        _buildMainStats(isDark),
                        const SizedBox(height: 24),
                        _buildTabBar(isDark),
                        const SizedBox(height: 20),
                        _buildTabContent(isDark),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderAppBar(bool isDark) {
    final month = _monthlyData?['month'] ?? 'Current Month';
    final year = _monthlyData?['year'] ?? '';

    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF0F4C81), Color(0xFF0284C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FadeInDown(
                    child: const Text(
                      'VISUAL INSIGHTS & ANALYTICS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$month $year',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_graph_rounded, color: AppTheme.accentCyan, size: 26),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
          ),
          onPressed: _loadData,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildEcoGradeCard(bool isDark) {
    final avgDaily = (_monthlyData?['avg_daily_co2'] as num?)?.toDouble() ?? 0.0;
    
    String grade = 'A+';
    String status = 'Low Carbon Footprint';
    Color gradeColor = AppTheme.primaryGreen;

    if (avgDaily > 15) {
      grade = 'C';
      status = 'High Emissions Action Needed';
      gradeColor = AppTheme.error;
    } else if (avgDaily > 8) {
      grade = 'B';
      status = 'Moderate Carbon Impact';
      gradeColor = const Color(0xFFFF9800);
    }

    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppTheme.cardDark, AppTheme.surfaceDark]
                : [Colors.white, const Color(0xFFF1F5F9)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: gradeColor.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: gradeColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: gradeColor, width: 2),
              ),
              child: Center(
                child: Text(
                  grade,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: gradeColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'ECO EFFICIENCY',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.verified_rounded, size: 14, color: gradeColor),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Daily Avg: ${avgDaily.toStringAsFixed(1)} kg CO₂',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictiveForecastCard(bool isDark) {
    final projCo2 = (_forecast?['projected_co2'] as num?)?.toDouble() ?? 38.5;
    final currCo2 = (_forecast?['current_co2'] as num?)?.toDouble() ?? 12.5;
    final targetCo2 = (_forecast?['co2_target'] as num?)?.toDouble() ?? 50.0;
    final status = _forecast?['status'] ?? 'On Track ✅';
    final paceMsg = _forecast?['pace_message'] ?? 'Projected 38.5 kg CO₂ vs 50.0 kg target.';

    final progressRatio = (targetCo2 > 0 ? (projCo2 / targetCo2) : 0.0).clamp(0.0, 1.0);
    final isRisk = projCo2 > targetCo2;

    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: isRisk ? AppTheme.error.withOpacity(0.4) : AppTheme.primaryGreen.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentCyan, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'MONTH-END CO₂ FORECAST',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: isDark ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (isRisk ? AppTheme.error : AppTheme.primaryGreen).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isRisk ? AppTheme.error : AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${projCo2.toStringAsFixed(1)} kg CO₂',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Current velocity: ${currCo2.toStringAsFixed(1)} kg logged',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Target: ${targetCo2.toStringAsFixed(0)} kg',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressRatio,
                minHeight: 10,
                backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                color: isRisk ? AppTheme.error : AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              paceMsg,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats(bool isDark) {
    final totalSpend = (_monthlyData?['total_spend'] as num?)?.toDouble() ?? 0.0;
    final totalCo2 = (_monthlyData?['total_co2'] as num?)?.toDouble() ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: FadeInLeft(
            child: _buildMetricBadge(
              label: 'TOTAL SPENT',
              val: '₹${totalSpend.toStringAsFixed(0)}',
              gradient: AppTheme.blueGradient,
              icon: Icons.account_balance_wallet_rounded,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: FadeInRight(
            child: _buildMetricBadge(
              label: 'TOTAL EMISSIONS',
              val: '${totalCo2.toStringAsFixed(1)} kg',
              gradient: AppTheme.heroGradient,
              icon: Icons.eco_rounded,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBadge({
    required String label,
    required String val,
    required Gradient gradient,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            val,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.emeraldGlow,
        ),
        labelColor: Colors.white,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '📈 Daily Trend'),
          Tab(text: '🍩 Categories'),
          Tab(text: '📊 Spending'),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isDark) {
    return SizedBox(
      height: 380,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTrendChart(isDark),
          _buildCategoryDonutChart(isDark),
          _buildBarBreakdownChart(isDark),
        ],
      ),
    );
  }

  Widget _buildDailyTrendChart(bool isDark) {
    final List daily = _monthlyData?['daily_breakdown'] ?? [];

    if (daily.isEmpty) {
      return _buildEmptyChart('No daily emission data logged yet', isDark);
    }

    final spots = daily.map<FlSpot>((e) {
      final day = (e['day'] as num).toDouble();
      final co2 = (e['co2'] as num).toDouble();
      return FlSpot(day, co2);
    }).toList();

    double maxCo2 = 0.0;
    double minCo2 = double.infinity;
    for (var s in spots) {
      if (s.y > maxCo2) maxCo2 = s.y;
      if (s.y < minCo2) minCo2 = s.y;
    }
    if (minCo2 == double.infinity) minCo2 = 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: isDark ? AppTheme.accentCyan.withOpacity(0.15) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Carbon Curve',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Velocity (kg CO₂)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('🔥 Max: ${maxCo2.toStringAsFixed(1)}k', style: const TextStyle(fontSize: 10, color: AppTheme.error, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('🌱 Min: ${minCo2.toStringAsFixed(1)}k', style: const TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '📅 Day ${spot.x.toInt()}\n⚡ ${spot.y.toStringAsFixed(2)} kg CO₂',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (val, meta) => Text(
                        '${val.toInt()}k',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 5,
                      getTitlesWidget: (val, meta) => Text(
                        'Day ${val.toInt()}',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    gradient: const LinearGradient(
                      colors: [AppTheme.neonGreen, AppTheme.accentCyan],
                    ),
                    barWidth: 4.0,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: AppTheme.neonGreen,
                          strokeWidth: 2.5,
                          strokeColor: isDark ? const Color(0xFF0B0F19) : Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.neonGreen.withOpacity(0.35),
                          AppTheme.accentCyan.withOpacity(0.02),
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

  Widget _buildCategoryDonutChart(bool isDark) {
    final List byCat = _monthlyData?['by_category'] ?? [];

    if (byCat.isEmpty) {
      return _buildEmptyChart('No category data available', isDark);
    }

    final totalCo2 = (_monthlyData?['total_co2'] as num?)?.toDouble() ?? 0.0;

    final sections = byCat.asMap().entries.map<PieChartSectionData>((entry) {
      final idx = entry.key;
      final e = entry.value;
      final isTouched = idx == _touchedPieIndex;
      final cat = e['category'] as String;
      final co2 = (e['co2'] as num).toDouble();
      final color = AppTheme.categoryColors[cat] ?? AppTheme.primaryGreen;

      final radius = isTouched ? 58.0 : 48.0;

      return PieChartSectionData(
        color: color,
        value: co2 > 0 ? co2 : 1.0,
        title: '${co2.toStringAsFixed(1)}kg',
        radius: radius,
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emission Breakdown by Category',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedPieIndex = -1;
                                  return;
                                }
                                _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          sections: sections,
                          centerSpaceRadius: 44,
                          sectionsSpace: 3,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TOTAL',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                          ),
                          Text(
                            '${totalCo2.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'kg CO₂',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: byCat.map((e) {
                    final cat = e['category'] as String;
                    final color = AppTheme.categoryColors[cat] ?? AppTheme.primaryGreen;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarBreakdownChart(bool isDark) {
    final List byCat = _monthlyData?['by_category'] ?? [];

    if (byCat.isEmpty) {
      return _buildEmptyChart('No category breakdown available', isDark);
    }

    final barGroups = byCat.asMap().entries.map<BarChartGroupData>((entry) {
      final idx = entry.key;
      final e = entry.value;
      final spend = (e['spend'] as num).toDouble();
      final cat = e['category'] as String;
      final color = AppTheme.categoryColors[cat] ?? AppTheme.primaryGreen;

      return BarChartGroupData(
        x: idx,
        barRods: [
          BarChartRodData(
            toY: spend,
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            width: 22,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Breakdown per Category (₹)',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final cat = byCat[groupIndex]['category'] as String;
                      return BarTooltipItem(
                        '$cat\n₹${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      );
                    },
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < byCat.length) {
                          final cat = byCat[idx]['category'] as String;
                          return Text(
                            cat.substring(0, cat.length > 5 ? 5 : cat.length),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String msg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_chart_outlined_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
