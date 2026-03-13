import 'package:bsuir/domain/entity/main_group.dart';
import 'package:bsuir/domain/entity/schedule.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_cubit.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_state.dart';
import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/logic/utils/lesson_type_utils.dart';
import 'package:bsuir/logic/utils/schedule_utils.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/day_section.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/empty_state_widgets.dart';
import 'package:flutter/material.dart';

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

    final sections = <Widget>[];

    for (final dayName in allDays) {
      final groupedSchedules = _getGroupedSchedulesForDay(
        scheduleData,
        dayName,
      );

      if (groupedSchedules.isNotEmpty) {
        final filteredSchedules = cubit.filterDisplaySchedulesBySubgroup(
          groupedSchedules,
          state.subgroupFilter,
        );

        if (filteredSchedules.isNotEmpty) {
          sections.add(_createDaySection(dayName, filteredSchedules));
        }
      }
    }

    return sections;
  }

  List<DisplaySchedule> _getGroupedSchedulesForDay(
    MainGroup scheduleData,
    String dayName,
  ) {
    if (scheduleData.schedules == null) return [];
    final daySchedules = scheduleData.schedules![dayName] ?? [];
    final Map<String, GroupedScheduleData> groupedMap = {};

    for (final schedule in daySchedules) {
      final key = _createGroupKey(schedule);

      if (!groupedMap.containsKey(key)) {
        groupedMap[key] = GroupedScheduleData(
          schedule: schedule,
          weekNumbers: [],
          subgroupNumber: schedule.numSubgroup ?? 0,
        );
      }

      if (schedule.weekNumber != null) {
        groupedMap[key]!.weekNumbers.addAll(schedule.weekNumber!);
      }
    }

    return _convertToDisplaySchedules(groupedMap);
  }

  String _createGroupKey(Schedule schedule) {
    final subject = schedule.subject ?? schedule.subjectFullName ?? '';
    final time = schedule.startLessonTime ?? '';
    final auditories = schedule.auditories?.join(',') ?? '';
    final lessonType = schedule.lessonTypeAbbrev ?? '';
    final teacher = schedule.employees?.firstOrNull?.lastName ?? '';
    final subgroup = schedule.numSubgroup ?? 0;

    return '$subject|$time|$auditories|$lessonType|$teacher|$subgroup';
  }

  List<DisplaySchedule> _convertToDisplaySchedules(
    Map<String, GroupedScheduleData> groupedMap,
  ) {
    final result = <DisplaySchedule>[];

    for (final groupedData in groupedMap.values) {
      final weekNumbers = groupedData.weekNumbers.toSet().toList()..sort();
      final weekNumbersStr = weekNumbers.join(', ');

      final subgroupInfo = _formatSubgroupInfo(groupedData.subgroupNumber);

      final displaySchedule = DisplaySchedule(
        original: groupedData.schedule,
        subjectName: ScheduleUtils.getSubjectName(groupedData.schedule),
        lessonTypeInfo: LessonTypeUtils.getLessonTypeInfo(groupedData.schedule),
        teacherImage: ScheduleUtils.getTeacherImage(
          groupedData.schedule.employees,
        ),
        weekNumberDisplay: weekNumbersStr,
        subgroupDisplay: subgroupInfo,
        subgroupNumber: groupedData.subgroupNumber,
      );

      result.add(displaySchedule);
    }

    result.sort((a, b) {
      final timeA = a.original.startLessonTime ?? '';
      final timeB = b.original.startLessonTime ?? '';
      return timeA.compareTo(timeB);
    });

    return result;
  }

  String _formatSubgroupInfo(int subgroupNumber) {
    if (subgroupNumber == 0) return '';

    switch (subgroupNumber) {
      case 1:
        return '1 подгруппа';
      case 2:
        return '2 подгруппа';
      default:
        return '$subgroupNumber подгруппа';
    }
  }

  Widget _createDaySection(String dayName, List<DisplaySchedule> schedules) {
    return DaySection(
      data: DaySectionData(
        dayName: dayName,
        schedules: schedules,
        weekNumber: 0,
        isStartDay: false,
        isSemesterEnded: false,
        showWeekNumberInCard: true,
      ),
      semesterStarted: cubit.hasSemesterStarted(state),
      isExamView: false,
      onLessonTap: onLessonTap,
    );
  }
}

class GroupedScheduleData {
  final Schedule schedule;
  final List<int> weekNumbers;
  final int subgroupNumber;
  final bool isAnnouncement;

  GroupedScheduleData({
    required this.schedule,
    required this.weekNumbers,
    required this.subgroupNumber,
    this.isAnnouncement = false,
  });
}
