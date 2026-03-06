import 'package:bsuir/domain/entity/main_group.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_cubit.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_state.dart';

import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/logic/utils/date_utils.dart';
import 'package:bsuir/logic/utils/lesson_type_utils.dart';
import 'package:bsuir/logic/utils/schedule_utils.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/day_section.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/empty_state_widgets.dart';
import 'package:flutter/material.dart' hide DateUtils;

class DailyView extends StatelessWidget {
  final MainGroupData state;
  final MainGroupCubit cubit;
  final ScrollController scrollController;
  final Function(DisplaySchedule) onLessonTap;

  const DailyView({
    super.key,
    required this.state,
    required this.cubit,
    required this.scrollController,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheduleData = state.mainGroup;
    final sections = _buildSections(scheduleData);

    if (sections.isEmpty) {
      return const NoScheduleStateWidget();
    }

    return ListView(controller: scrollController, children: sections);
  }

  List<Widget> _buildSections(MainGroup scheduleData) {
    const allDays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
    ];

    final Map<String, Map<int, List<DisplaySchedule>>> schedulesByDayAndWeek = {};

    // Обычные занятия по неделям
    for (int weekNumber = 1; weekNumber <= 4; weekNumber++) {
      for (final dayName in allDays) {
        final schedules = _getRegularSchedulesForWeek(
          scheduleData, dayName, weekNumber
        );

        if (schedules.isNotEmpty) {
          if (!schedulesByDayAndWeek.containsKey(dayName)) {
            schedulesByDayAndWeek[dayName] = {};
          }
          schedulesByDayAndWeek[dayName]![weekNumber] = schedules;
        }
      }
    }

    // Объявления
    // _addAnnouncements(scheduleData, schedulesByDayAndWeek);

    // Сортировка и создание секций
    return _buildSectionsFromMap(schedulesByDayAndWeek, allDays);
  }

  List<DisplaySchedule> _getRegularSchedulesForWeek(
    MainGroup scheduleData,
    String dayName,
    int weekNumber,
  ) {
    // final targetDate = _getDateForWeek(dayName, weekNumber);
    // if (targetDate == null) return [];

    final schedules = ScheduleUtils.getAllSchedulesForDay(
      scheduleData.schedules,
      dayName,
      weekNumber,
      targetDate,
    );

    final filteredSchedules = schedules
        .where(LessonTypeUtils.isRegularSchedule)
        .toList();

    return ScheduleUtils.convertToDisplaySchedules(
      filteredSchedules, weekNumber.toString()
    );
  }

  // String? _getDateForWeek(String dayName, int weekNumber) {
  //   try {
  //     final now = DateTime.now();
  //     final mondayOfCurrentWeek = DateUtils.getMonday(now);
  //     final startDate = DateUtils.parseDate(state.mainGroup.startDate ?? '');

  //     final weeksFromStart =
  //         (mondayOfCurrentWeek.difference(startDate).inDays ~/ 7) + 1;
  //     final targetWeek = ((weeksFromStart - 1) ~/ 4) * 4 + weekNumber;

  //     const allDays = [
  //       'Понедельник',
  //       'Вторник',
  //       'Среда',
  //       'Четверг',
  //       'Пятница',
  //       'Суббота',
  //     ];
      
  //     final targetDateObj = startDate.add(
  //       Duration(days: (targetWeek - 1) * 7 + allDays.indexOf(dayName)),
  //     );
      
  //     return DateUtils.formatDate(targetDateObj);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // void _addAnnouncements(
  //   MainGroup scheduleData,
  //   Map<String, Map<int, List<DisplaySchedule>>> schedulesByDayAndWeek,
  // ) {
  //   if (scheduleData.schedules == null) return;

  //   for (final daySchedules in scheduleData.schedules!.values) {
  //     for (final schedule in daySchedules) {
  //       if (schedule.announcement == true) {
  //         final announcementDate = schedule.startLessonDate;
  //         if (announcementDate != null && announcementDate.isNotEmpty) {
  //           try {
  //             final date = DateUtils.parseDate(announcementDate);
  //             final dayName = DateUtils.getRussianDayName(date);

  //             if (!schedulesByDayAndWeek.containsKey(dayName)) {
  //               schedulesByDayAndWeek[dayName] = {};
  //             }
  //             if (!schedulesByDayAndWeek[dayName]!.containsKey(0)) {
  //               schedulesByDayAndWeek[dayName]![0] = [];
  //             }
              
  //             final displaySchedule = DisplaySchedule(
  //               original: schedule,
  //               subjectName: ScheduleUtils.getSubjectName(schedule),
  //               lessonTypeInfo: LessonTypeUtils.getLessonTypeInfo(schedule),
  //               teacherImage: ScheduleUtils.getTeacherImage(schedule.employees),
  //             );
              
  //             schedulesByDayAndWeek[dayName]![0]!.add(displaySchedule);
  //           } catch (e) {}
  //         }
  //       }
  //     }
  //   }
  // }

  List<Widget> _buildSectionsFromMap(
    Map<String, Map<int, List<DisplaySchedule>>> schedulesByDayAndWeek,
    List<String> allDays,
  ) {
    final sections = <Widget>[];
    final sortedDays = allDays
        .where((day) => schedulesByDayAndWeek.containsKey(day))
        .toList();

    for (final dayName in sortedDays) {
      final weeksForDay = schedulesByDayAndWeek[dayName]!;
      final weekNumbers = weeksForDay.keys.toList()..sort();

      for (final weekNumber in weekNumbers) {
        final schedules = weeksForDay[weekNumber]!;
        schedules.sort((a, b) {
          final timeA = a.original.startLessonTime ?? '';
          final timeB = b.original.startLessonTime ?? '';
          return timeA.compareTo(timeB);
        });

        // final dateDisplay = weekNumber == 0 
        //     ? 'Объявления' 
        //     : _getDateForWeek(dayName, weekNumber) ?? 'Неделя $weekNumber';

        sections.add(DaySection(
          data: DaySectionData(
            dayName: dayName,
            // dateDisplay: dateDisplay,
            schedules: schedules,
            weekNumber: weekNumber,
            isStartDay: false,
            isSemesterEnded: false,
            showWeekNumberInCard: true,
            forceWeekNumber: weekNumber,
          ),
          semesterStarted: cubit.hasSemesterStarted(state),
          isExamView: false,
          onLessonTap: onLessonTap,
        ));
      }
    }

    return sections;
  }
}