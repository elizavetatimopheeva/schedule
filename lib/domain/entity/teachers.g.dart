// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teachers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Teachers _$TeachersFromJson(Map<String, dynamic> json) => Teachers(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  middleName: json['middleName'] as String?,
  degree: json['degree'] as String?,
  rank: json['rank'] as String?,
  photoLink: json['photoLink'] as String?,
  calendarId: json['calendarId'] as String?,
  academicDepartment: (json['academicDepartment'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  id: (json['id'] as num).toInt(),
  urlId: json['urlId'] as String,
  fio: json['fio'] as String?,
);

Map<String, dynamic> _$TeachersToJson(Teachers instance) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'middleName': instance.middleName,
  'degree': instance.degree,
  'rank': instance.rank,
  'photoLink': instance.photoLink,
  'calendarId': instance.calendarId,
  'academicDepartment': instance.academicDepartment,
  'id': instance.id,
  'urlId': instance.urlId,
  'fio': instance.fio,
};
