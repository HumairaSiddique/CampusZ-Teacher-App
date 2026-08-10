import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Analytics & Reports Screen — overview stats, weekly performance chart,
/// per-class breakdown, and a recent-reports list. Matches the same
/// CampusZ purple/indigo design language as the rest of the app.
///
/// NOTE: Pure UI with placeholder/sample data. No external chart package is
/// used (custom-drawn bars only) so this drops in without new pubspec
/// dependencies — swap the sample numbers for real Firestore-aggregated
/// data once that's wired up.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg(context),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildHeader(context),
            _buildStatCards(),
            _buildWeeklyChart(context),
            _buildClassBreakdown(context),
            _buildReportsList(context),
          ],
        ),
      ),
    );
  }

  // ---------- Header ----------
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (Navigator.of(context).canPop())
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(context), size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (Navigator.of(context).canPop()) const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Analytics & Reports',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.text(context),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: AppColors.text(context).withOpacity(0.06), blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: primaryIndigo),
                const SizedBox(width: 6),
                Text(
                  'This Week',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryIndigo,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: primaryIndigo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Overview stat cards ----------
  Widget _buildStatCards() {
    final stats = [
      {'label': 'Overall Performance', 'value': '78%', 'icon': Icons.trending_up_rounded, 'colors': const [Color(0xFF3CBF7F), Color(0xFF1E9C63)]},
      {'label': 'Avg. Attendance', 'value': '82%', 'icon': Icons.checklist_rounded, 'colors': const [Color(0xFF4F7DF3), Color(0xFF3D5AE0)]},
      {'label': 'Total Students', 'value': '182', 'icon': Icons.groups_outlined, 'colors': const [Color(0xFF8B5CF6), Color(0xFF6C4CE0)]},
      {'label': 'Assignments Graded', 'value': '64', 'icon': Icons.fact_check_outlined, 'colors': const [Color(0xFFF59E0B), Color(0xFFD97706)]},
    ];

    return SizedBox(
      height: 118,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final stat = stats[index];
          final colors = stat['colors'] as List<Color>;
          return Container(
            width: 140,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: colors.last.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(stat['icon'] as IconData, color: Colors.white, size: 20),
                const Spacer(),
                Text(
                  stat['value'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat['label'] as String,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- Weekly performance chart (custom-drawn bars) ----------
  Widget _buildWeeklyChart(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = [0.55, 0.7, 0.6, 0.85, 0.65, 0.9, 0.78]; // 0..1

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Performance',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text(context),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: primaryIndigo,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Avg. score',
                      style: TextStyle(fontSize: 11, color: AppColors.text(context).withOpacity(0.5)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(days.length, (i) {
                  final isPeak = values[i] == values.reduce((a, b) => a > b ? a : b);
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 90 * values[i],
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isPeak
                                  ? [gradientStart, gradientEnd]
                                  : [primaryIndigo.withOpacity(0.25), primaryIndigo.withOpacity(0.15)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[i],
                          style: TextStyle(fontSize: 10, color: AppColors.text(context).withOpacity(0.5)),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Per-class breakdown ----------
  Widget _buildClassBreakdown(BuildContext context) {
    final classes = [
      {'name': 'Data Structures', 'score': 0.85, 'color': const Color(0xFF3CBF7F)},
      {'name': 'Database Systems', 'score': 0.72, 'color': const Color(0xFF4F7DF3)},
      {'name': 'Algorithms', 'score': 0.68, 'color': const Color(0xFF8B5CF6)},
      {'name': 'Operating Systems', 'score': 0.79, 'color': const Color(0xFFF59E0B)},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Class-wise Performance',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10),
              ],
            ),
            child: Column(
              children: List.generate(classes.length, (index) {
                final item = classes[index];
                final isLast = index == classes.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name'] as String,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(context),
                            ),
                          ),
                          Text(
                            '${((item['score'] as double) * 100).round()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: item['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: item['score'] as double,
                          minHeight: 8,
                          backgroundColor: AppColors.text(context).withOpacity(0.06),
                          valueColor: AlwaysStoppedAnimation(item['color'] as Color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Recent reports list ----------
  Widget _buildReportsList(BuildContext context) {
    final reports = [
      {'title': 'Monthly Attendance Report', 'date': 'Generated Jul 28', 'icon': Icons.checklist_rounded},
      {'title': 'Grade Distribution Report', 'date': 'Generated Jul 25', 'icon': Icons.bar_chart_rounded},
      {'title': 'Student Progress Summary', 'date': 'Generated Jul 20', 'icon': Icons.trending_up_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Reports',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10),
              ],
            ),
            child: Column(
              children: List.generate(reports.length, (index) {
                final item = reports[index];
                final isLast = index == reports.length - 1;
                return InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Open "${item['title']}" here')),
                    );
                  },
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(18) : Radius.zero,
                    bottom: isLast ? const Radius.circular(18) : Radius.zero,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : Border(bottom: BorderSide(color: AppColors.text(context).withOpacity(0.05))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: primaryIndigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item['icon'] as IconData, color: primaryIndigo, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text(context),
                                ),
                              ),
                              Text(
                                item['date'] as String,
                                style: TextStyle(fontSize: 11, color: AppColors.text(context).withOpacity(0.5)),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.file_download_outlined, size: 18, color: AppColors.text(context).withOpacity(0.4)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}