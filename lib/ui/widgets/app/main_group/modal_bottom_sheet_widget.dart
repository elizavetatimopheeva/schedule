import 'package:bsuir/logic/bloc/main_group/main_group_cubit.dart';
import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/logic/utils/schedule_utils.dart';
import 'package:bsuir/resourses/app_colors.dart';
import 'package:flutter/material.dart';

Widget lessonInfo(
  MainGroupCubit cubit,
  DisplaySchedule schedule,
) {
  final employee = ScheduleUtils.getEmployeeName(schedule.original.employees);
  String subgroup() {
    if (schedule.original.numSubgroup == 0) {
      return '--';
    } else {
      return schedule.original.numSubgroup.toString();
    }
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Преподаватель',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
              ),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    employee.isEmpty
                        ? SizedBox.shrink()
                        : Text(
                            employee,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                    SizedBox(height: 2),
                    (schedule.original.auditories == null ||
                            schedule.original.auditories!.isEmpty)
                        ? SizedBox.shrink()
                        : Row(
                            children: [
                              Icon(
                                Icons.room_outlined,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                schedule.original.auditories!.join(', '),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          schedule.original.subjectFullName ??
                              'Название отсутствует',
                          style: TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDetailRow(
                  'Время',
                  '${schedule.original.startLessonTime}-${schedule.original.endLessonTime}',
                ),
                _buildDetailRow(
                  'Аудитория',
                  schedule.original.auditories != null &&
                          schedule.original.auditories!.isNotEmpty
                      ? schedule.original.auditories!.join(', ')
                      : '--',
                ),
                _buildDetailRow(
                  'Тип занятия',
                  '${schedule.original.lessonTypeAbbrev}',
                ),
                _buildDetailRow('Подгруппа', subgroup()),
                _buildDetailRow(
                  'Неделя',
                  schedule.original.weekNumber != null &&
                          schedule.original.weekNumber!.isNotEmpty
                      ? schedule.original.weekNumber!.join(', ')
                      : '--',
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    ),
  );
}

Widget _buildDetailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: TextStyle(color: AppColors.greyText)),
        ),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
