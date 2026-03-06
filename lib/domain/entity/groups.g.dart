// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Groups _$GroupsFromJson(Map<String, dynamic> json) => Groups(
  name: json['name'] as String,
  facultyId: (json['facultyId'] as num).toInt(),
  facultyName: json['facultyName'] as String,
  specialityDepartmentEducationFormId:
      (json['specialityDepartmentEducationFormId'] as num).toInt(),
  specialityName: json['specialityName'] as String,
  course: (json['course'] as num?)?.toInt(),
  id: (json['id'] as num).toInt(),
  calendarId: json['calendarId'] as String,
);

Map<String, dynamic> _$GroupsToJson(Groups instance) => <String, dynamic>{
  'name': instance.name,
  'facultyId': instance.facultyId,
  'facultyName': instance.facultyName,
  'specialityDepartmentEducationFormId':
      instance.specialityDepartmentEducationFormId,
  'specialityName': instance.specialityName,
  'course': instance.course,
  'id': instance.id,
  'calendarId': instance.calendarId,
};
