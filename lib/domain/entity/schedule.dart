

import 'package:bsuir/domain/entity/employee.dart';
import 'package:bsuir/domain/entity/student_group.dart';
import 'package:json_annotation/json_annotation.dart';

part 'schedule.g.dart';

@JsonSerializable()
class Schedule {
  final List<int>? weekNumber;
  final List<StudentGroup>? studentGroups;
  final int? numSubgroup;
  final List<String>? auditories;
  final String? startLessonTime;
  final String? endLessonTime;
  final String? subject;
  final String? subjectFullName;
  final String? note;
  final String? lessonTypeAbbrev;
  final String? dateLesson;
  final String? startLessonDate;
  final String? endLessonDate;
  final bool? announcement;
  final bool? split;
  final List<Employee>? employees;

  Schedule({
    required this.weekNumber,
    required this.studentGroups,
    required this.numSubgroup,
    required this.auditories,
    required this.startLessonTime,
    required this.endLessonTime,
    required this.subject,
    required this.subjectFullName,
    required this.note,
    required this.lessonTypeAbbrev,
    required this.dateLesson,
    required this.startLessonDate,
    required this.endLessonDate,
    required this.announcement,
    required this.split,
    required this.employees,
  });


   factory Schedule.fromJson(Map<String, dynamic> json)=> _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this); 

  
}
