// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentGroup _$StudentGroupFromJson(Map<String, dynamic> json) => StudentGroup(
  specialityName: json['specialityName'] as String,
  specialityCode: json['specialityCode'] as String?,
  numberOfStudents: (json['numberOfStudents'] as num?)?.toInt(),
  name: json['name'] as String,
  educationDegree: (json['educationDegree'] as num?)?.toInt(),
);

Map<String, dynamic> _$StudentGroupToJson(StudentGroup instance) =>
    <String, dynamic>{
      'specialityName': instance.specialityName,
      'specialityCode': instance.specialityCode,
      'numberOfStudents': instance.numberOfStudents,
      'name': instance.name,
      'educationDegree': instance.educationDegree,
    };
