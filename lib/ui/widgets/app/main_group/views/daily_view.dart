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

    // Для каждого дня недели собираем все занятия
    for (final dayName in allDays) {
      final groupedSchedules = _getGroupedSchedulesForDay(
        scheduleData,
        dayName,
      );

      if (groupedSchedules.isNotEmpty) {
        sections.add(_createDaySection(dayName, groupedSchedules));
      }
    }

    return sections;
  }

  List<DisplaySchedule> _getGroupedSchedulesForDay(
    MainGroup scheduleData,
    String dayName,
  ) {
    if (scheduleData.schedules == null) return [];

    // Получаем все занятия для этого дня
    final daySchedules = scheduleData.schedules![dayName] ?? [];

    // Группируем занятия по ключу (предмет + время + аудитория + тип + преподаватель)
    final Map<String, GroupedScheduleData> groupedMap = {};

    for (final schedule in daySchedules) {
      // Создаем ключ для группировки
      final key = _createGroupKey(schedule);

      if (!groupedMap.containsKey(key)) {
        groupedMap[key] = GroupedScheduleData(
          schedule: schedule,
          weekNumbers: [],
          isAnnouncement: false,
        );
      }

      // Добавляем номера недель
      if (schedule.weekNumber != null) {
        groupedMap[key]!.weekNumbers.addAll(schedule.weekNumber!);
      }
    }

    // Преобразуем в DisplaySchedule с объединенными номерами недель
    return groupedMap.values.map((groupedData) {
      final weekNumbers = groupedData.weekNumbers.toSet().toList()..sort();
      final weekNumbersStr = weekNumbers.join(', ');

      return DisplaySchedule(
        original: groupedData.schedule,
        subjectName: ScheduleUtils.getSubjectName(groupedData.schedule),
        lessonTypeInfo: LessonTypeUtils.getLessonTypeInfo(groupedData.schedule),
        teacherImage: ScheduleUtils.getTeacherImage(
          groupedData.schedule.employees,
        ),
        weekNumberDisplay: groupedData.isAnnouncement ? null : weekNumbersStr,
      );
    }).toList()..sort((a, b) {
      final timeA = a.original.startLessonTime ?? '';
      final timeB = b.original.startLessonTime ?? '';
      return timeA.compareTo(timeB);
    });
  }

  String _createGroupKey(Schedule schedule) {
    final subject = schedule.subject ?? schedule.subjectFullName ?? '';
    final time = schedule.startLessonTime ?? '';
    final auditories = schedule.auditories?.join(',') ?? '';
    final lessonType = schedule.lessonTypeAbbrev ?? '';
    // Добавляем преподавателя в ключ, чтобы разные преподаватели не группировались вместе
    final teacher = schedule.employees?.firstOrNull?.lastName ?? '';

    return '$subject|$time|$auditories|$lessonType|$teacher';
  }

  Widget _createDaySection(String dayName, List<DisplaySchedule> schedules) {
    // final dateDisplay = '';

    return DaySection(
      data: DaySectionData(
        dayName: dayName,
        // dateDisplay: dateDisplay,
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

// Вспомогательный класс для группировки
class GroupedScheduleData {
  final Schedule schedule;
  final List<int> weekNumbers;
  final bool isAnnouncement;

  GroupedScheduleData({
    required this.schedule,
    required this.weekNumbers,
    required this.isAnnouncement,
  });
}
