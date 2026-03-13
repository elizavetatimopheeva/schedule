import 'package:json_annotation/json_annotation.dart';

part 'teachers.g.dart';


@JsonSerializable()
class Teachers {
    final String firstName;
    final String lastName;
    final String? middleName;
    final String? degree;
    final String? rank;
    final String? photoLink;
    final String? calendarId;
    final List<String>? academicDepartment;
    final int id;
    final String urlId;
    final String? fio;

    Teachers({
        required this.firstName,
        required this.lastName,
        required this.middleName,
        required this.degree,
        required this.rank,
        required this.photoLink,
        required this.calendarId,
        required this.academicDepartment,
        required this.id,
        required this.urlId,
        required this.fio,
    });


 factory Teachers.fromJson(Map<String, dynamic> json)=> _$TeachersFromJson(json);

  Map<String, dynamic> toJson() => _$TeachersToJson(this); 
    
}
