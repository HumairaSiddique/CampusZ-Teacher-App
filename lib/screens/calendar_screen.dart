import 'package:flutter/material.dart';
import 'app_colors.dart';

class _EventInfo {
  const _EventInfo({required this.title, required this.time, required this.color});
  final String title;
  final String time;
  final Color color;
}

/// Calendar Screen — custom month grid (no external calendar package),
/// event dots per day, and an events list for the selected day. Matches
/// the CampusZ purple theme.
///
/// NOTE: Pure UI with placeholder/sample events keyed by day-of-month.
/// Swap `_eventsByDay` for a real Firestore-backed schedule once wired up.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  DateTime _visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int _selectedDay = DateTime.now().day;

  final Map<int, List<_EventInfo>> _eventsByDay = {
    5: [const _EventInfo(title: 'Midterm - Data Structures', time: '10:00 AM', color: Color(0xFF4F7DF3))],
    12: [
      const _EventInfo(title: 'Assignment 2 Due', time: '11:59 PM', color: Color(0xFFF59E0B)),
      const _EventInfo(title: 'Parent-Teacher Meeting', time: '3:00 PM', color: Color(0xFF8B5CF6)),
    ],
    18: [const _EventInfo(title: 'Quiz - Algorithms', time: '9:30 AM', color: Color(0xFF3CBF7F))],
    25: [const _EventInfo(title: 'Final Project Presentation', time: '1:00 PM', color: Color(0xFFEF4444))],
  };

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      _selectedDay = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = _eventsByDay[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildMonthNav(),
            _buildCalendarGrid(),
            const SizedBox(height: 8),
            Expanded(child: _buildEventsList(events)),
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
            child: Text('Calendar',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text(context))),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthNav() {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: Icon(Icons.chevron_left_rounded, color: AppColors.text(context).withOpacity(0.6)),
          ),
          Text(
            '${monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.text(context)),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: Icon(Icons.chevron_right_rounded, color: AppColors.text(context).withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingBlanks = firstDayOfMonth.weekday % 7; // Sun=0 layout

    const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Row(
              children: weekDays
                  .map((d) => Expanded(
                child: Center(
                  child: Text(d,
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text(context).withOpacity(0.4))),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leadingBlanks + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              itemBuilder: (context, index) {
                if (index < leadingBlanks) return const SizedBox.shrink();
                final day = index - leadingBlanks + 1;
                final isSelected = day == _selectedDay;
                final hasEvent = _eventsByDay.containsKey(day);
                return Padding(
                  padding: const EdgeInsets.all(3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => setState(() => _selectedDay = day),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected ? const LinearGradient(colors: [gradientStart, gradientEnd]) : null,
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.text(context),
                            ),
                          ),
                          if (hasEvent)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : primaryIndigo,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(List<_EventInfo> events) {
    if (events.isEmpty) {
      return Center(
        child: Text(
          'No events on this day',
          style: TextStyle(fontSize: 13, color: AppColors.text(context).withOpacity(0.4), fontWeight: FontWeight.w600),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final event = events[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: event.color, width: 4)),
            boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text(context))),
                    const SizedBox(height: 2),
                    Text(event.time, style: TextStyle(fontSize: 11, color: AppColors.text(context).withOpacity(0.5))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}