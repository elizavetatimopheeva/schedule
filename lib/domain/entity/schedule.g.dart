// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
  weekNumber: (json['weekNumber'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  studentGroups: (json['studentGroups'] as List<dynamic>?)
      ?.map((e) => StudentGroup.fromJson(e as Map<String, dynamic>))
      .toList(),
  numSubgroup: (json['numSubgroup'] as num?)?.toInt(),
  auditories: (json['auditories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  startLessonTime: json['startLessonTime'] as String?,
  endLessonTime: json['endLessonTime'] as String?,
  subject: json['subject'] as String?,
  subjectFullName: json['subjectFullName'] as String?,
  note: json['note'] as String?,
  lessonTypeAbbrev: json['lessonTypeAbbrev'] as String?,
  dateLesson: json['dateLesson'] as String?,
  startLessonDate: json['startLessonDate'] as String?,
  endLessonDate: json['endLessonDate'] as String?,
  announcement: json['announcement'] as bool?,
  split: json['split'] as bool?,
  employees: (json['employees'] as List<dynamic>?)
      ?.map((e) => Employee.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
  'weekNumber': instance.weekNumber,
  'studentGroups': instance.studentGroups,
  'numSubgroup': instance.numSubgroup,
  'auditories': instance.auditories,
  'startLessonTime': instance.startLessonTime,
  'endLessonTime': instance.endLessonTime,
  'subject': instance.subject,
  'subjectFullName': instance.subjectFullName,
  'note': instance.note,
  'lessonTypeAbbrev': instance.lessonTypeAbbrev,
  'dateLesson': instance.dateLesson,
  'startLessonDate': instance.startLessonDate,
  'endLessonDate': instance.endLessonDate,
  'announcement': instance.announcement,
  'split': instance.split,
  'employees': instance.employees,
};
