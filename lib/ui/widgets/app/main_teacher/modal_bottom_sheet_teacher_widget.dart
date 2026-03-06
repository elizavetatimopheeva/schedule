import 'dart:math';

import 'package:bsuir/domain/entity/schedule.dart';
import 'package:bsuir/ui/widgets/app/main_group/main_group_model.dart';
import 'package:bsuir/ui/widgets/app/main_teacher/main_teacher_model.dart';
import 'package:flutter/material.dart';

Widget LessonTeacherInfo(MainTeacherModel model, Schedule schedule) {
  final isAnnouncement = model.isAnnouncement(schedule);
  //final isZaochGroup = model.isZaochOrDist;
  //final teacherImage = model.getTeacherImage(schedule.employees);
  final employeeName = model.getEmployeeNameFromList(schedule.employees);
  final subjectName = model.getSubjectName(schedule);
  // final lessonType = model.getLessonType(schedule);
  final groupsText = model.getGroupsForSchedule(schedule);
  String subgroup() {
    if (schedule.numSubgroup == 0) {
      return '--';
    } else {
      return schedule.numSubgroup.toString();
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
            schedule.subject ?? 'Название отсутствует',
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          Text(
            'Группы',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(groupsText),
              
              // Container(
              //   width: 45,
              //   height: 45,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     border: Border.all(color: Colors.grey[300]!, width: 1),
              //   ),
              //   child: ClipOval(
              //     child: teacherImage.isNotEmpty
              //         ? Image.network(
              //             teacherImage,
              //             fit: BoxFit.cover,
              //             errorBuilder: (context, error, stackTrace) {
              //               return Icon(
              //                 Icons.person_outline,
              //                 color: Colors.grey[400],
              //                 size: 20,
              //               );
              //             },
              //           )
              //         : Icon(
              //             Icons.person_outline,
              //             color: Colors.grey[400],
              //             size: 20,
              //           ),
              //   ),
              // ),

              // SizedBox(width: 12),

              // Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       employeeName.isEmpty
              //           ? SizedBox.shrink()
              //           : Text(
              //               employeeName,
              //               style: TextStyle(
              //                 fontSize: 16,
              //                 fontWeight: FontWeight.w600,
              //                 color: Colors.black87,
              //               ),
              //             ),
                    
              //     ],
              //   ),
              // ),
            ],
          ),

          SizedBox(height: 30),

          Text(
            'Детали',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                          schedule.subjectFullName ?? 'Название отсутствует',
                          style: TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider(height: 1),
                _buildDetailRow(
                  'Время',
                  '${schedule.startLessonTime}-${schedule.endLessonTime}',
                ),
                _buildDetailRow(
                  'Аудитория',
                  schedule.auditories != null && schedule.auditories!.isNotEmpty
                      ? schedule.auditories!.join(', ')
                      : '--',
                ),
                _buildDetailRow('Тип занятия', '${schedule.lessonTypeAbbrev}'),
                _buildDetailRow('Подгруппа', subgroup()),
                _buildDetailRow(
                  'Неделя',
                  schedule.weekNumber != null && schedule.weekNumber!.isNotEmpty
                      ? schedule.weekNumber!.join(', ')
                      : '--',
                ),
              ],
            ),
          ),

          SizedBox(height: 16),
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
          child: Text(title, style: TextStyle(color: Colors.grey[700])),
        ),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
