import 'package:bsuir/domain/entity/main_group.dart';
import 'package:bsuir/domain/entity/schedule.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_cubit.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_state.dart';
import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/logic/utils/date_utils.dart';
import 'package:bsuir/logic/utils/schedule_utils.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/day_section.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/empty_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleView extends StatelessWidget {
  final MainGroupData state;
  final MainGroupCubit cubit;
  final ScrollController scrollController;
  final Function(DisplaySchedule) onLessonTap;

  const ScheduleView({
    super.key,
    required this.state,
    required this.cubit,
    required this.scrollController,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheduleData = state.mainGroup;
    final semesterStarted = cubit.hasSemesterStarted(state);
    final semesterEnded = cubit.isSemesterEnded(state);

    if (!state.hasMainSchedules || semesterEnded) {
      return const NoScheduleStateWidget();
    }

    final sections = _buildSections(scheduleData, semesterStarted);

    return ListView(controller: scrollController, children: sections);
  }

  List<Widget> _buildSections(MainGroup scheduleData, bool semesterStarted) {
    const allDays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
    ];

    final startDisplayDate = cubit.getStartDisplayDate(state);
    final startRussianName = MyDateUtils.getRussianDayName(startDisplayDate);
    final startIndex = allDays.indexOf(startRussianName);

    final sections = <Widget>[];

    if (semesterStarted) {
      sections.addAll(_buildCurrentWeekSections(
        scheduleData, allDays, startRussianName, startDisplayDate, startIndex
      ));
      
      for (int weekOffset = 1; weekOffset <= state.weeksToShow; weekOffset++) {
        sections.addAll(_buildWeekSections(scheduleData, allDays, weekOffset));
      }
    } else {
      for (int weekOffset = 0; weekOffset < state.weeksToShow; weekOffset++) {
        sections.addAll(_buildWeekSections(
          scheduleData, allDays, weekOffset, 
          isStartWeek: weekOffset == 0,
          startDayName: startRussianName
        ));
      }
    }

    return sections;
  }

  List<Widget> _buildCurrentWeekSections(
    MainGroup scheduleData,
    List<String> allDays,
    String startDayName,
    DateTime startDisplayDate,
    int startIndex,
  ) {
    final sections = <Widget>[];

    final todayDateStr = DateFormat('dd.MM.yyyy').format(startDisplayDate);
    final todayWeekNumber = cubit.getWeekNumberForCurrentWeek(state);
    final todaySchedules = _getFilteredDaySchedules(
      scheduleData, startDayName, todayWeekNumber, todayDateStr
    );

    if (todaySchedules.isNotEmpty) {
      final todayDateDisplay = '$todayDateStr, Неделя: $todayWeekNumber';
      final displaySchedules = ScheduleUtils.convertToDisplaySchedules(
        todaySchedules, null
      );

      sections.add(DaySection(
        data: DaySectionData(
          dayName: startDayName,
          dateDisplay: todayDateDisplay,
          schedules: displaySchedules,
          weekNumber: todayWeekNumber,
          isStartDay: true,
          isSemesterEnded: scheduleData.endDate != null
              ? !MyDateUtils.isDateValid(startDisplayDate, scheduleData.endDate!)
              : false,
        ),
        semesterStarted: cubit.hasSemesterStarted(state),
        isExamView: false,
        onLessonTap: onLessonTap,
      ));
    }

    if (startIndex < allDays.length - 1) {
      final remainingDays = allDays.sublist(startIndex + 1);
      for (final dayName in remainingDays) {
        if (cubit.isDayValidForCurrentWeek(state, dayName)) {
          final section = _buildSingleDaySection(scheduleData, dayName, 0);
          if (section != null) sections.add(section);
        }
      }
    }

    return sections;
  }

  List<Widget> _buildWeekSections(
    MainGroup scheduleData,
    List<String> allDays,
    int weekOffset, {
    bool isStartWeek = false,
    String startDayName = '',
  }) {
    final sections = <Widget>[];
    bool weekHasValidDays = false;

    for (final dayName in allDays) {
      if (cubit.isDayValidForFutureWeek(state, dayName, weekOffset)) {
        final section = _buildSingleDaySection(
          scheduleData, 
          dayName, 
          weekOffset,
          isStartDay: isStartWeek && dayName == startDayName,
        );
        
        if (section != null) {
          sections.add(section);
          weekHasValidDays = true;
        }
      }
    }

    if (!weekHasValidDays) {
      cubit.checkMoreWeeksAvailability();
    }

    return sections;
  }

  Widget? _buildSingleDaySection(
    MainGroup scheduleData,
    String dayName,
    int weekOffset, {
    bool isStartDay = false,
  }) {
    final weekNumber = cubit.getWeekNumberForFutureWeek(state, weekOffset);
    final date = cubit.getDateForFutureWeekDay(state, dayName, weekOffset);
    final dateOnly = date.replaceAll(' (семестр окончен)', '');
    
    final daySchedules = _getFilteredDaySchedules(
      scheduleData, dayName, weekNumber, dateOnly
    );

    if (daySchedules.isEmpty) return null;

    final isSemesterEnded = date.contains('семестр окончен');
    final dateDisplay = isSemesterEnded 
        ? '$date, Неделя: $weekNumber'
        : '$date, Неделя: $weekNumber';

    final displaySchedules = ScheduleUtils.convertToDisplaySchedules(
      daySchedules, null
    );

    return DaySection(
      data: DaySectionData(
        dayName: dayName,
        dateDisplay: dateDisplay,
        schedules: displaySchedules,
        weekNumber: weekNumber,
        isStartDay: isStartDay,
        isSemesterEnded: isSemesterEnded,
      ),
      semesterStarted: cubit.hasSemesterStarted(state),
      isExamView: false,
      onLessonTap: onLessonTap,
    );
  }

  List<Schedule> _getFilteredDaySchedules(
    MainGroup scheduleData,
    String dayName,
    int weekNumber,
    String date,
  ) {
    final schedules = ScheduleUtils.getAllSchedulesForDay(
      scheduleData.schedules,
      dayName,
      weekNumber,
      date,
    );

    return cubit.filterSchedulesBySubgroup(schedules, state.subgroupFilter);
  }
}