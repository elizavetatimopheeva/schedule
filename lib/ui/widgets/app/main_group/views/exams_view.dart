import 'package:bsuir/domain/entity/main_group.dart';
import 'package:bsuir/domain/entity/schedule.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_cubit.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_state.dart';

import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/logic/utils/date_utils.dart';
import 'package:bsuir/logic/utils/schedule_utils.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/day_section.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/empty_state_widgets.dart';
import 'package:flutter/material.dart' hide DateUtils;
import 'package:intl/intl.dart';

class ExamsView extends StatelessWidget {
  final MainGroupData state;
  final MainGroupCubit cubit;
  final ScrollController scrollController;
  final Function(DisplaySchedule) onLessonTap;

  const ExamsView({
    super.key,
    required this.state,
    required this.cubit,
    required this.scrollController,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheduleData = state.mainGroup;

    if (scheduleData.exams == null || scheduleData.exams!.isEmpty) {
      return const NoScheduleStateWidget();
    }

    final sections = _buildSections(scheduleData);

    if (sections.isEmpty) {
      return const NoScheduleStateWidget();
    }

    return ListView(controller: scrollController, children: sections);
  }

  List<Widget> _buildSections(MainGroup scheduleData) {
    final Map<String, List<Schedule>> examsByDate = {};

    // Группировка экзаменов по датам
    for (final exam in scheduleData.exams!) {
      final date = exam.dateLesson ?? '';
      if (date.isNotEmpty) {
        if (!examsByDate.containsKey(date)) {
          examsByDate[date] = [];
        }
        examsByDate[date]!.add(exam);
      }
    }

    // Сортировка дат
    final sortedDates = examsByDate.keys.toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('dd.MM.yyyy').parse(a);
          final dateB = DateFormat('dd.MM.yyyy').parse(b);
          return dateA.compareTo(dateB);
        } catch (e) {
          return a.compareTo(b);
        }
      });

    // Создание секций
    return sortedDates.map((date) {
      final examsForDate = examsByDate[date]!;
      final dayName = DateUtils.getDayNameFromDate(date);
      
      final displaySchedules = ScheduleUtils.convertToDisplaySchedules(
        examsForDate, null
      );

      return DaySection(
        data: DaySectionData(
          dayName: dayName,
          dateDisplay: date,
          schedules: displaySchedules,
          weekNumber: 1,
          isStartDay: false,
          isSemesterEnded: false,
        ),
        semesterStarted: cubit.hasSemesterStarted(state),
        isExamView: true,
        onLessonTap: onLessonTap,
      );
    }).toList();
  }
}