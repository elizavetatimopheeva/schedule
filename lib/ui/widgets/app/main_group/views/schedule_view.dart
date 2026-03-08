// import 'package:bsuir/domain/entity/main_group.dart';
// import 'package:bsuir/domain/entity/schedule.dart';
// import 'package:bsuir/logic/bloc/main_group/main_group_cubit.dart';
// import 'package:bsuir/logic/bloc/main_group/main_group_state.dart';

// import 'package:bsuir/logic/models/schedule_models.dart';
// import 'package:bsuir/logic/utils/date_utils.dart';
// import 'package:bsuir/logic/utils/schedule_utils.dart';
// import 'package:bsuir/ui/widgets/app/main_group/components/day_section.dart';
// import 'package:bsuir/ui/widgets/app/main_group/components/empty_state_widgets.dart';
// import 'package:flutter/material.dart' hide DateUtils;
// import 'package:intl/intl.dart';

// class ScheduleView extends StatelessWidget {
//   final MainGroupData state;
//   final MainGroupCubit cubit;
//   final ScrollController scrollController;
//   final Function(DisplaySchedule) onLessonTap;

//   const ScheduleView({
//     super.key,
//     required this.state,
//     required this.cubit,
//     required this.scrollController,
//     required this.onLessonTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final scheduleData = state.mainGroup;
//     final semesterStarted = cubit.hasSemesterStarted(state);
//     final semesterEnded = cubit.isSemesterEnded(state);

//     if (!state.hasMainSchedules || semesterEnded) {
//       return const NoScheduleStateWidget();
//     }

//     final sections = _buildSections(scheduleData, semesterStarted);

//     return ListView(controller: scrollController, children: sections);
//   }

//   List<Widget> _buildSections(MainGroup scheduleData, bool semesterStarted) {
//     const allDays = [
//       'Понедельник',
//       'Вторник',
//       'Среда',
//       'Четверг',
//       'Пятница',
//       'Суббота',
//     ];

//     final startDisplayDate = cubit.getStartDisplayDate(state);
//     final startRussianName = DateUtils.getRussianDayName(startDisplayDate);
//     final startIndex = allDays.indexOf(startRussianName);

//     final sections = <Widget>[];

//     if (semesterStarted) {
//       sections.addAll(
//         _buildCurrentWeekSections(
//           scheduleData,
//           allDays,
//           startRussianName,
//           startDisplayDate,
//           startIndex,
//         ),
//       );

//       for (int weekOffset = 1; weekOffset <= state.weeksToShow; weekOffset++) {
//         sections.addAll(_buildWeekSections(scheduleData, allDays, weekOffset));
//       }
//     } else {
//       for (int weekOffset = 0; weekOffset < state.weeksToShow; weekOffset++) {
//         sections.addAll(
//           _buildWeekSections(
//             scheduleData,
//             allDays,
//             weekOffset,
//             isStartWeek: weekOffset == 0,
//             startDayName: startRussianName,
//           ),
//         );
//       }
//     }

//     return sections;
//   }

//   List<Widget> _buildCurrentWeekSections(
//     MainGroup scheduleData,
//     List<String> allDays,
//     String startDayName,
//     DateTime startDisplayDate,
//     int startIndex,
//   ) {
//     final sections = <Widget>[];

//     // Сегодняшний день
//     final todayDateStr = DateFormat('dd.MM.yyyy').format(startDisplayDate);
//     final todayWeekNumber = cubit.getWeekNumberForCurrentWeek(state);
//     final todaySchedules = _getDaySchedules(
//       scheduleData,
//       startDayName,
//       todayWeekNumber,
//       todayDateStr,
//     );

//     sections.add(
//       _createDaySection(
//         startDayName,
//         todayDateStr,
//         todaySchedules,
//         todayWeekNumber,
//         0,
//         true,
//         scheduleData.endDate != null
//             ? !DateUtils.isDateValid(startDisplayDate, scheduleData.endDate!)
//             : false,
//       ),
//     );

//     // Оставшиеся дни текущей недели
//     if (startIndex < allDays.length - 1) {
//       final remainingDays = allDays.sublist(startIndex + 1);
//       for (final dayName in remainingDays) {
//         if (cubit.isDayValidForCurrentWeek(state, dayName)) {
//           sections.add(_buildDaySection(scheduleData, dayName, 0));
//         }
//       }
//     }

//     return sections;
//   }

//   List<Widget> _buildWeekSections(
//     MainGroup scheduleData,
//     List<String> allDays,
//     int weekOffset, {
//     bool isStartWeek = false,
//     String startDayName = '',
//   }) {
//     final sections = <Widget>[];
//     bool weekHasValidDays = false;

//     for (final dayName in allDays) {
//       if (cubit.isDayValidForFutureWeek(state, dayName, weekOffset)) {
//         final weekNumber = cubit.getWeekNumberForFutureWeek(state, weekOffset);
//         final date = cubit.getDateForFutureWeekDay(state, dayName, weekOffset);
//         final dateOnly = date.replaceAll(' (семестр окончен)', '');

//         final daySchedules = ScheduleUtils.getAllSchedulesForDay(
//           scheduleData.schedules,
//           dayName,
//           weekNumber,
//           dateOnly,
//         );

//         final isSemesterEnded = date.contains('семестр окончен');
//         final isStartDay = isStartWeek && dayName == startDayName;

//         if (daySchedules.isNotEmpty) {
//           final displaySchedules = ScheduleUtils.convertToDisplaySchedules(
//             daySchedules,
//             null,
//           );

//           sections.add(
//             DaySection(
//               data: DaySectionData(
//                 dayName: dayName,
//                 dateDisplay: date,
//                 schedules: displaySchedules,
//                 weekNumber: weekNumber,
//                 isStartDay: isStartDay,
//                 isSemesterEnded: isSemesterEnded,
//               ),
//               semesterStarted: cubit.hasSemesterStarted(state),
//               isExamView: false,
//               onLessonTap: onLessonTap,
//             ),
//           );

//           weekHasValidDays = true;
//         }
//       }
//     }

//     if (!weekHasValidDays) {
//       cubit.checkMoreWeeksAvailability();
//     }

//     return sections;
//   }

//   Widget _buildDaySection(
//     MainGroup scheduleData,
//     String dayName,
//     int weekOffset,
//   ) {
//     final weekNumber = cubit.getWeekNumberForFutureWeek(state, weekOffset);
//     final date = cubit.getDateForFutureWeekDay(state, dayName, weekOffset);
//     final dateOnly = date.replaceAll(' (семестр окончен)', '');

//     final daySchedules = ScheduleUtils.getAllSchedulesForDay(
//       scheduleData.schedules,
//       dayName,
//       weekNumber,
//       dateOnly,
//     );

//     final isSemesterEnded = date.contains('семестр окончен');

//     return _createDaySection(
//       dayName,
//       date,
//       daySchedules,
//       weekNumber,
//       weekOffset,
//       false,
//       isSemesterEnded,
//     );
//   }

//   List<Schedule> _getDaySchedules(
//     MainGroup scheduleData,
//     String dayName,
//     int weekNumber,
//     String date,
//   ) {
//     return ScheduleUtils.getAllSchedulesForDay(
//       scheduleData.schedules,
//       dayName,
//       weekNumber,
//       date,
//     );
//   }

//   Widget _createDaySection(
//     String dayName,
//     String dateDisplay,
//     List<Schedule> schedules,
//     int weekNumber,
//     int weekOffset,
//     bool isStartDay,
//     bool isSemesterEnded,
//   ) {
//     if (schedules.isEmpty) return const SizedBox.shrink();

//     final displaySchedules = ScheduleUtils.convertToDisplaySchedules(
//       schedules,
//       null,
//     );

//     return DaySection(
//       data: DaySectionData(
//         dayName: dayName,
//         dateDisplay: dateDisplay,
//         schedules: displaySchedules,
//         weekNumber: weekNumber,
//         isStartDay: isStartDay,
//         isSemesterEnded: isSemesterEnded,
//       ),
//       semesterStarted: cubit.hasSemesterStarted(state),
//       isExamView: false,
//       onLessonTap: onLessonTap,
//     );
//   }
// }




import 'package:bsuir/domain/entity/main_group.dart';
import 'package:bsuir/domain/entity/schedule.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_cubit.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_state.dart';
import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/logic/utils/date_utils.dart';
import 'package:bsuir/logic/utils/schedule_utils.dart';
import 'package:bsuir/services/subgroup_service.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/day_section.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/empty_state_widgets.dart';
import 'package:flutter/material.dart' hide DateUtils;
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
    final startRussianName = DateUtils.getRussianDayName(startDisplayDate);
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

    // Сегодняшний день
    final todayDateStr = DateFormat('dd.MM.yyyy').format(startDisplayDate);
    final todayWeekNumber = cubit.getWeekNumberForCurrentWeek(state);
    final todaySchedules = _getDaySchedules(
      scheduleData, startDayName, todayWeekNumber, todayDateStr
    );

    // Формируем дату с номером недели для заголовка
    final todayDateDisplay = '$todayDateStr (сегодня), Неделя: $todayWeekNumber';

    sections.add(_createDaySection(
      startDayName,
      todayDateDisplay,
      todaySchedules,
      todayWeekNumber,
      0,
      true,
      scheduleData.endDate != null
          ? !DateUtils.isDateValid(startDisplayDate, scheduleData.endDate!)
          : false,
    ));

    // Оставшиеся дни текущей недели
    if (startIndex < allDays.length - 1) {
      final remainingDays = allDays.sublist(startIndex + 1);
      for (final dayName in remainingDays) {
        if (cubit.isDayValidForCurrentWeek(state, dayName)) {
          sections.add(_buildDaySection(scheduleData, dayName, 0));
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
        final weekNumber = cubit.getWeekNumberForFutureWeek(state, weekOffset);
        final date = cubit.getDateForFutureWeekDay(state, dayName, weekOffset);
        final dateOnly = date.replaceAll(' (семестр окончен)', '');
        
        final daySchedules = ScheduleUtils.getAllSchedulesForDay(
          scheduleData.schedules,
          dayName,
          weekNumber,
          dateOnly,
        );

        final isSemesterEnded = date.contains('семестр окончен');
        final isStartDay = isStartWeek && dayName == startDayName;

        if (daySchedules.isNotEmpty) {
          final displaySchedules = ScheduleUtils.convertToDisplaySchedules(
            daySchedules, null
          );

          // Формируем дату с номером недели для заголовка
          final dateDisplay = isSemesterEnded 
              ? '$date, Неделя: $weekNumber'
              : '$date, Неделя: $weekNumber';

          sections.add(DaySection(
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
          ));

          weekHasValidDays = true;
        }
      }
    }

    if (!weekHasValidDays) {
      cubit.checkMoreWeeksAvailability();
    }

    return sections;
  }

  Widget _buildDaySection(MainGroup scheduleData, String dayName, int weekOffset) {
    final weekNumber = cubit.getWeekNumberForFutureWeek(state, weekOffset);
    final date = cubit.getDateForFutureWeekDay(state, dayName, weekOffset);
    final dateOnly = date.replaceAll(' (семестр окончен)', '');
    
    final daySchedules = ScheduleUtils.getAllSchedulesForDay(
      scheduleData.schedules,
      dayName,
      weekNumber,
      dateOnly,
    );

    final isSemesterEnded = date.contains('семестр окончен');
    
    // Формируем дату с номером недели для заголовка
    final dateDisplay = isSemesterEnded 
        ? '$date, Неделя: $weekNumber'
        : '$date, Неделя: $weekNumber';

    return _createDaySection(
      dayName,
      dateDisplay,
      daySchedules,
      weekNumber,
      weekOffset,
      false,
      isSemesterEnded,
    );
  }

  List<Schedule> _getDaySchedules(
    MainGroup scheduleData,
    String dayName,
    int weekNumber,
    String date,
  ) {
    return ScheduleUtils.getAllSchedulesForDay(
      scheduleData.schedules,
      dayName,
      weekNumber,
      date,
    );
  }

  Widget _createDaySection(
    String dayName,
    String dateDisplay,
    List<Schedule> schedules,
    int weekNumber,
    int weekOffset,
    bool isStartDay,
    bool isSemesterEnded,
  ) {
    if (schedules.isEmpty) return const SizedBox.shrink();

    final displaySchedules = ScheduleUtils.convertToDisplaySchedules(
      schedules, null
    );

    return DaySection(
      data: DaySectionData(
        dayName: dayName,
        dateDisplay: dateDisplay, // Здесь уже строка с номером недели
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

static List<Schedule> filterSchedulesBySubgroup(
  List<Schedule> schedules, 
  SubgroupFilter filter
) {
  if (filter == SubgroupFilter.all) {
    return schedules;
  }
  
  final subgroupNumber = filter.subgroupNumber;
  return schedules.where((schedule) {
    if (schedule.numSubgroup == null || schedule.numSubgroup == 0) {
      return true;
    }
    return schedule.numSubgroup == subgroupNumber;
  }).toList();
}

}