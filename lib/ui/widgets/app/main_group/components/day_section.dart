import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/resourses/app_colors.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/lesson_card.dart';
import 'package:flutter/material.dart';

class DaySection extends StatelessWidget {
  final DaySectionData data;
  final bool semesterStarted;
  final bool isExamView;
  final Function(DisplaySchedule) onLessonTap;

  const DaySection({
    super.key,
    required this.data,
    required this.semesterStarted,
    required this.isExamView,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    if (data.schedules.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildHeader(), _buildLessonsList()],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(color: AppColors.greyBackground),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.dayName,
                      style: TextStyle(
                        color: data.isSemesterEnded
                            ? Colors.grey[600]
                            : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    if (data.isStartDay && semesterStarted) _buildTodayBadge(),
                  ],
                ),
                const SizedBox(height: 4),

                data.dateDisplay != null
                    ? Text(
                        data.dateDisplay!,
                        style: TextStyle(
                          color: data.isSemesterEnded
                              ? Colors.grey[600]
                              : const Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayBadge() {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Сегодня',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLessonsList() {
    return Column(
      children: data.schedules
          .map(
            (schedule) => LessonCard(
              schedule: schedule,
              isSemesterEnded: data.isSemesterEnded,
              isExamView: isExamView,
              onTap: () => onLessonTap(schedule),
            ),
          )
          .toList(),
    );
  }
}
