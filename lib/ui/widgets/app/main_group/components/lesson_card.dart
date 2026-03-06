import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/logic/utils/lesson_type_utils.dart';
import 'package:bsuir/resourses/app_colors.dart';
import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final DisplaySchedule schedule;
  final bool isSemesterEnded;
  final bool isExamView;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.schedule,
    required this.isSemesterEnded,
    required this.isExamView,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12, left: 12, top: 2, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.greyBackground),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTimeColumn(),
            const SizedBox(width: 12),
            _buildContentColumn(context),
            const SizedBox(width: 8),
            _buildTeacherImage(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          schedule.original.startLessonTime ?? '--:--',
          style: const TextStyle(fontSize: 13, color: AppColors.black),
        ),
        const SizedBox(height: 1),
        Text(
          schedule.original.endLessonTime ?? '--:--',
          style: const TextStyle(fontSize: 11, color: AppColors.black),
        ),
      ],
    );
  }

  Widget _buildContentColumn(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(),
          if (schedule.weekNumberDisplay != null && !schedule.lessonTypeInfo.isAnnouncement)
            _buildWeekNumber(),
          _buildLessonType(),
          const SizedBox(height: 3),
          _buildAuditories(),
          if (schedule.original.note != null && schedule.original.note!.isNotEmpty)
            _buildNote(),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Text(
          schedule.lessonTypeInfo.isAnnouncement ? 'Объявление!' : schedule.subjectName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        if (schedule.original.numSubgroup != 0)
          Row(
            children: [
              const SizedBox(width: 8),
              Icon(
                Icons.person,
                color: AppColors.greyText,
                size: 18,
              ),
              const SizedBox(width: 3),
              Text('${schedule.original.numSubgroup}'),
            ],
          ),
      ],
    );
  }

  Widget _buildWeekNumber() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        'Неделя: ${schedule.weekNumberDisplay}',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.blue,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildLessonType() {
    return Text(
      schedule.lessonTypeInfo.displayName,
      style: TextStyle(
        fontSize: 11,
        color: LessonTypeUtils.getLessonTypeColor(
          schedule.lessonTypeInfo,
          isSemesterEnded,
          isExamView,
        ),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAuditories() {
    if (schedule.original.auditories == null || schedule.original.auditories!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(
          Icons.room_outlined,
          size: 12,
          color: AppColors.greyText,
        ),
        const SizedBox(width: 2),
        Text(
          schedule.original.auditories!.join(', '),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildNote() {
    return Text(
      schedule.original.note!,
      style: const TextStyle(fontSize: 10, color: AppColors.greyText),
    );
  }

  Widget _buildTeacherImage() {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipOval(
        child: schedule.teacherImage.isNotEmpty
            ? Image.network(
                schedule.teacherImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person_outline,
                    color: Colors.grey,
                    size: 20,
                  );
                },
              )
            : const Icon(
                Icons.person_outline,
                color: Colors.grey,
                size: 20,
              ),
      ),
    );
  }
}