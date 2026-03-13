import 'package:bsuir/domain/entity/employee.dart';
import 'package:bsuir/domain/entity/groups.dart';
import 'package:bsuir/domain/entity/schedule.dart';
import 'package:json_annotation/json_annotation.dart';


part 'main_group.g.dart';

@JsonSerializable()
class MainGroup {
  final Employee? employeeDto;
  final Groups? studentGroupDto;
  final Map<String, List<Schedule>>? schedules;
  final List<Schedule>? exams;
  final String? startDate;
  final String? endDate;
  final String? startExamsDate;
  final String? endExamsDate;
  final bool? isZaochOrDist; 

  MainGroup({
    required this.employeeDto,
    required this.studentGroupDto,
    required this.schedules,
    required this.exams,
    required this.startDate,
    required this.endDate,
    required this.startExamsDate,
    required this.endExamsDate, required this.isZaochOrDist,
  });

   factory MainGroup.fromJson(Map<String, dynamic> json)=> _$MainGroupFromJson(json);

  Map<String, dynamic> toJson() => _$MainGroupToJson(this); 

}
