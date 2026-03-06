

import 'package:json_annotation/json_annotation.dart';

part 'student_group.g.dart';

@JsonSerializable()
class StudentGroup {
  final String specialityName;
  final String? specialityCode;
  final int? numberOfStudents;
  final String name;
  final int? educationDegree;

  StudentGroup({
    required this.specialityName,
    required this.specialityCode,
    required this.numberOfStudents,
    required this.name,
    required this.educationDegree,
  });


     factory StudentGroup.fromJson(Map<String, dynamic> json)=> _$StudentGroupFromJson(json);

  Map<String, dynamic> toJson() => _$StudentGroupToJson(this); 
}
