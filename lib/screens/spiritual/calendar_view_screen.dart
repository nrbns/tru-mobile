import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:truresetx/core/utils/lucide_compat.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/aura_card.dart';
import '../../core/providers/spiritual_provider.dart';
import '../../core/providers/calendar_events_provider.dart';
import '../../core/models/calendar_event_model.dart';
import '../../core/services/calendar_events_service.dart';
import 'package:intl/intl.dart';

class CalendarViewScreen extends ConsumerStatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  ConsumerState<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends ConsumerState<CalendarViewScreen> {
  DateTime _selectedDate = DateTime.now();
  List<CalendarEventModel> _monthEvents = [];

  @override
  void initState() {
    super.initState();
    _loadMonthEvents();
  }

  void _loadMonthEvents() {
    Future.microtask(() async {
      final service = CalendarEventsService();
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate =
          DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);
      final events = await service.getEventsForDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      if (mounted) {
        setState(() {
          _monthEvents = events;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthEventsAsync = ref.watch(monthEventsProvider({
      'year': _selectedDate.year,
      'month': _selectedDate.month,
    }));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(LucideIcons.arrowLeft, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spiritual Calendar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Festivals, Moon Phases & Astrology',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Calendar
            AuraCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.chevronLeft),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month - 1,
                            );
                          });
                          _loadMonthEvents();
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.chevronRight),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month + 1,
                            );
                          });
                          _loadMonthEvents();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Calendar Grid
                  monthEventsAsync.when(
                    data: (events) {
                      _monthEvents = events;
                      return _buildCalendarGrid();
                    },
                    loading: () => _buildCalendarGrid(),
                    error: (_, __) => _buildCalendarGrid(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Selected Date Events & Practices
            Expanded(
              child: _buildSelectedDateDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateDetails() {
    final dateEventsAsync = ref.watch(dateEventsProvider(_selectedDate));
    final practiceLogsAsync = ref.watch(practiceLogsStreamProvider);
    final moonPhaseData = CalendarEventsService.getMoonPhase(_selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header with Moon Phase
          AuraCard(
            variant: AuraCardVariant.spiritual,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.spiritualColor
                            .withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        moonPhaseData.emoji ?? '🌙',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  moonPhaseData.phaseName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  'Illumination: ${(moonPhaseData.illumination * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Calendar Events (Festivals, Moon Phases, Astrology)
          dateEventsAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Events',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...events.map((event) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _CalendarEventItem(event: event),
                      )),
                  const SizedBox(height: 16),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Practices Logged
          practiceLogsAsync.when(
            data: (logs) {
              final selectedDateLogs = logs.where((log) {
                final atField = log['at'];
                if (atField == null) return false;
                if (atField is! Timestamp) return false;
                final logDate = atField.toDate();
                return logDate.year == _selectedDate.year &&
                    logDate.month == _selectedDate.month &&
                    logDate.day == _selectedDate.day;
              }).toList();

              if (selectedDateLogs.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Practices',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...selectedDateLogs.map((log) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PracticeItem(
                          icon: _getPracticeIcon(
                              log['practice_id'] as String? ?? ''),
                          title: log['practice_id'] ?? 'Unknown Practice',
                          completed: true,
                          duration: log['duration_min'] as int?,
                        ),
                      )),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  IconData _getPracticeIcon(String practiceId) {
    if (practiceId.toLowerCase().contains('prayer')) return LucideIcons.heart;
    if (practiceId.toLowerCase().contains('scripture') ||
        practiceId.toLowerCase().contains('reading')) {
      return LucideIcons.bookOpen;
    }
    if (practiceId.toLowerCase().contains('meditation')) {
      return LucideIcons.sparkles;
    }
    return LucideIcons.moon;
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    final List<Widget> dayWidgets = [];

    // Weekday headers
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (var weekday in weekdays) {
      dayWidgets.add(
        Center(
          child: Text(
            weekday,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Empty cells for days before month starts
    for (var i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Days of the month
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedDate.year, _selectedDate.month, day);
      final isToday = date.day == DateTime.now().day &&
          date.month == DateTime.now().month &&
          date.year == DateTime.now().year;
      final isSelected = date.day == _selectedDate.day &&
          date.month == _selectedDate.month &&
          date.year == _selectedDate.year;

      // Get events for this date
      final dateEvents = _monthEvents.where((event) {
        final eventDate = DateTime(
          event.date.year,
          event.date.month,
          event.date.day,
        );
        return eventDate.year == date.year &&
            eventDate.month == date.month &&
            eventDate.day == date.day;
      }).toList();

      // Get moon phase for visualization
      final moonPhase = CalendarEventsService.getMoonPhase(date);

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.spiritualColor
                  : isToday
                      ? AppColors.spiritualColor.withAlpha((0.3 * 255).round())
                      : null,
              shape: BoxShape.circle,
              border: dateEvents.isNotEmpty
                  ? Border.all(
                      color: AppColors.spiritualColor
                          .withAlpha((0.5 * 255).round()),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isSelected || isToday
                          ? Colors.white
                          : Colors.grey[300],
                      fontWeight: isSelected || isToday
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                // Moon phase indicator (top right)
                if (moonPhase.phase == MoonPhase.fullMoon ||
                    moonPhase.phase == MoonPhase.newMoon ||
                    moonPhase.phase == MoonPhase.firstQuarter ||
                    moonPhase.phase == MoonPhase.lastQuarter)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Text(
                      moonPhase.emoji ?? '🌙',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                // Festival indicator (top left)
                if (dateEvents.any((e) => e.type == EventType.festival))
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: dayWidgets.length,
      itemBuilder: (context, index) => dayWidgets[index],
    );
  }
}

class _CalendarEventItem extends StatelessWidget {
  final CalendarEventModel event;

  const _CalendarEventItem({required this.event});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (event.type) {
      case EventType.festival:
        icon = LucideIcons.sparkles;
        color = Colors.amber;
        break;
      case EventType.fullMoon:
        icon = LucideIcons.moon;
        color = Colors.blue;
        break;
      case EventType.newMoon:
        icon = LucideIcons.moon;
        color = Colors.grey;
        break;
      case EventType.eclipse:
        icon = LucideIcons.sun;
        color = Colors.orange;
        break;
      case EventType.solstice:
      case EventType.equinox:
        icon = LucideIcons.sun;
        color = Colors.orange;
        break;
      case EventType.meteorShower:
        icon = LucideIcons.sparkles;
        color = Colors.purple;
        break;
      case EventType.astrologicalTransit:
        icon = LucideIcons.star;
        color = Colors.purple;
        break;
      default:
        icon = LucideIcons.calendar;
        color = AppColors.spiritualColor;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (event.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.description!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
                if (event.tradition != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    event.tradition!,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (event.icon != null)
            Text(
              event.icon!,
              style: const TextStyle(fontSize: 20),
            ),
        ],
      ),
    );
  }
}

class _PracticeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool completed;
  final int? duration;

  const _PracticeItem({
    required this.icon,
    required this.title,
    required this.completed,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          completed ? LucideIcons.checkCircle : LucideIcons.circle,
          color: completed ? AppColors.spiritualColor : AppColors.textMuted,
          size: 20,
        ),
        const SizedBox(width: 12),
        Icon(icon, color: AppColors.spiritualColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: completed ? Colors.white : Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              if (duration != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '$duration min',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
