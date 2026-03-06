import 'package:json_annotation/json_annotation.dart';

part 'groups.g.dart';

@JsonSerializable()
class Groups {
  final String name;
  final int facultyId;
  final String facultyName;
  final int specialityDepartmentEducationFormId;
  final String specialityName;
  final int? course;
  final int id;
  final String calendarId;

  Groups({
    required this.name,
    required this.facultyId,
    required this.facultyName,
    required this.specialityDepartmentEducationFormId,
    required this.specialityName,
    this.course,
    required this.id,
    required this.calendarId,
  });

  factory Groups.fromJson(Map<String, dynamic> json)=> _$GroupsFromJson(json);

  Map<String, dynamic> toJson() => _$GroupsToJson(this); 

}


// import 'dart:convert';

// List<Groups> groupsFromJson(String str) => List<Groups>.from(json.decode(str).map((x) => Groups.fromJson(x)));

// String groupsToJson(List<Groups> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class Groups {
//     String name;
//     int facultyId;
//     String facultyName;
//     int specialityDepartmentEducationFormId;
//     String specialityName;
//     int? course;
//     int id;
//     String calendarId;

//     Groups({
//         required this.name,
//         required this.facultyId,
//         required this.facultyName,
//         required this.specialityDepartmentEducationFormId,
//         required this.specialityName,
//          this.course,
//         required this.id,
//         required this.calendarId,
//     });

//     factory Groups.fromJson(Map<String, dynamic> json) => Groups(
//         name: json["name"],
//         facultyId: json["facultyId"],
//         facultyName: json["facultyName"],
//         specialityDepartmentEducationFormId: json["specialityDepartmentEducationFormId"],
//         specialityName: json["specialityName"],
//         course: json["course"],
//         id: json["id"],
//         calendarId: json["calendarId"],
//     );

//     Map<String, dynamic> toJson() => {
//         "name": name,
//         "facultyId": facultyId,
//         "facultyName": facultyName,
//         "specialityDepartmentEducationFormId": specialityDepartmentEducationFormId,
//         "specialityName": specialityName,
//         "course": course,
//         "id": id,
//         "calendarId": calendarId,
//     };
// }

