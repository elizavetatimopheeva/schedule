// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  middleName: json['middleName'] as String?,
  degree: json['degree'] as String?,
  degreeAbbrev: json['degreeAbbrev'] as String?,
  rank: json['rank'] as String?,
  photoLink: json['photoLink'] as String?,
  calendarId: json['calendarId'] as String?,
  id: (json['id'] as num).toInt(),
  urlId: json['urlId'] as String,
  email: json['email'] as String?,
  jobPositions: json['jobPositions'] as String?,
);

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'middleName': instance.middleName,
  'degree': instance.degree,
  'degreeAbbrev': instance.degreeAbbrev,
  'rank': instance.rank,
  'photoLink': instance.photoLink,
  'calendarId': instance.calendarId,
  'id': instance.id,
  'urlId': instance.urlId,
  'email': instance.email,
  'jobPositions': instance.jobPositions,
};
