import 'package:flutter/material.dart';
import 'app_colors.dart';

class _Period {
  const _Period({
    required this.subject,
    required this.section,
    required this.time,
    required this.room,
    required this.color,
  });
  final String subject;
  final String section;
  final String time;
  final String room;
  final Color color;
}

/// Weekly Timetable Screen — day selector + list of class periods for that
/// day, matching the CampusZ purple theme.
///
/// NOTE: Pure UI with placeholder/sample data. Swap `_scheduleByDay` for a
/// real Firestore-backed timetable once that's wired up.
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  final List<String> _days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  int _selectedDay = 2; // Wed selected by default, matching "today" feel

  late final Map<String, List<_Period>> _scheduleByDay = {
    'Mon': [
      const _Period(subject: 'Data Structures', section: 'BSCS - 4th', time: '9:00 - 10:00 AM', room: 'Room 204', color: Color(0xFF4F7DF3)),
      const _Period(subject: 'Database Systems', section: 'BSCS - 5th', time: '11:00 AM - 12:00 PM', room: 'Room 118', color: Color(0xFF3CBF7F)),
    ],
    'Tue': [
      const _Period(subject: 'Algorithms', section: 'BSCS - 6th', time: '10:00 - 11:00 AM', room: 'Room 302', color: Color(0xFF8B5CF6)),
    ],
    'Wed': [
      const _Period(subject: 'Data Structures', section: 'BSCS - 4th', time: '10:30 - 11:30 AM', room: 'Room 204', color: Color(0xFF4F7DF3)),
      const _Period(subject: 'Operating Systems', section: 'BSCS - 5th', time: '12:00 - 1:00 PM', room: 'Room 110', color: Color(0xFFF59E0B)),
      const _Period(subject: 'Database Systems', section: 'BSCS - 5th', time: '2:00 - 3:00 PM', room: 'Room 118', color: Color(0xFF3CBF7F)),
    ],
    'Thu': [
      const _Period(subject: 'Algorithms', section: 'BSCS - 6th', time: '9:30 - 10:30 AM', room: 'Room 302', color: Color(0xFF8B5CF6)),
    ],
    'Fri': [
      const _Period(subject: 'Operating Systems', section: 'BSCS - 5th', time: '11:00 AM - 12:00 PM', room: 'Room 110', color: Color(0xFFF59E0B)),
    ],
    'Sat': [],
  };

  @override
  Widget build(BuildContext context) {
    final periods = _scheduleByDay[_days[_selectedDay]] ?? [];

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildDaySelector(),
            Expanded(
              child: periods.isEmpty ? _buildEmptyState() : _buildScheduleList(periods),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(context), size: 18),
          ),
          Expanded(
            child: Text(
              'Timetable',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text(context)),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.06), blurRadius: 8)],
            ),
            child: Icon(Icons.calendar_month_outlined, color: AppColors.text(context).withOpacity(0.7), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDay;
          final dateNumbers = [28, 29, 30, 31, 1, 2]; // sample dates
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _selectedDay = index),
            child: Container(
              width: 52,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [gradientStart, gradientEnd])
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [BoxShadow(color: primaryIndigo.withOpacity(0.3), blurRadius: 10)]
                    : [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 6)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _days[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white.withOpacity(0.85) : AppColors.text(context).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateNumbers[index]}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.text(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleList(List<_Period> periods) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: periods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final period = periods[index];
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  period.time.split(' - ').first,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text(context).withOpacity(0.5)),
                ),
              ),
              Column(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: period.color, shape: BoxShape.circle)),
                  Expanded(
                    child: Container(width: 2, color: AppColors.text(context).withOpacity(0.08)),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border(left: BorderSide(color: period.color, width: 4)),
                    boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        period.subject,
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.text(context)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        period.section,
                        style: TextStyle(fontSize: 11.5, color: AppColors.text(context).withOpacity(0.5)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 13, color: AppColors.text(context).withOpacity(0.4)),
                          const SizedBox(width: 4),
                          Text(period.time, style: TextStyle(fontSize: 11, color: AppColors.text(context).withOpacity(0.5))),
                          const SizedBox(width: 12),
                          Icon(Icons.location_on_outlined, size: 13, color: AppColors.text(context).withOpacity(0.4)),
                          const SizedBox(width: 4),
                          Text(period.room, style: TextStyle(fontSize: 11, color: AppColors.text(context).withOpacity(0.5))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_outlined, size: 56, color: AppColors.text(context).withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            'No classes scheduled',
            style: TextStyle(fontSize: 14, color: AppColors.text(context).withOpacity(0.45), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}