

import 'package:json_annotation/json_annotation.dart';

part 'employee.g.dart';

@JsonSerializable()
class Employee {
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? degree;
  final String? degreeAbbrev;
  final String? rank;
  final String? photoLink;
  final String? calendarId;
  final int id;
  final String urlId;
  final String? email;
  final String? jobPositions;

  Employee({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.degree,
    required this.degreeAbbrev,
    required this.rank,
    required this.photoLink,
    required this.calendarId,
    required this.id,
    required this.urlId,
    required this.email,
    required this.jobPositions,
  });

    factory Employee.fromJson(Map<String, dynamic> json)=> _$EmployeeFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeToJson(this); 
}
