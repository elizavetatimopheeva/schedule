// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MainGroup _$MainGroupFromJson(Map<String, dynamic> json) => MainGroup(
  employeeDto: json['employeeDto'] == null
      ? null
      : Employee.fromJson(json['employeeDto'] as Map<String, dynamic>),
  studentGroupDto: json['studentGroupDto'] == null
      ? null
      : Groups.fromJson(json['studentGroupDto'] as Map<String, dynamic>),
  schedules: (json['schedules'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
  exams: (json['exams'] as List<dynamic>?)
      ?.map((e) => Schedule.fromJson(e as Map<String, dynamic>))
      .toList(),
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  startExamsDate: json['startExamsDate'] as String?,
  endExamsDate: json['endExamsDate'] as String?,
  isZaochOrDist: json['isZaochOrDist'] as bool?,
);

Map<String, dynamic> _$MainGroupToJson(MainGroup instance) => <String, dynamic>{
  'employeeDto': instance.employeeDto,
  'studentGroupDto': instance.studentGroupDto,
  'schedules': instance.schedules,
  'exams': instance.exams,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'startExamsDate': instance.startExamsDate,
  'endExamsDate': instance.endExamsDate,
  'isZaochOrDist': instance.isZaochOrDist,
};
