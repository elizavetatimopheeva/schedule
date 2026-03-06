import 'dart:convert';
import 'dart:io';

import 'package:bsuir/domain/entity/groups.dart';
import 'package:bsuir/domain/entity/main_group.dart';
import 'package:bsuir/domain/entity/teachers.dart';

class ApiClient {
  final client = HttpClient();

  Future<List<Teachers>> getTeachers() async {
    final url = Uri.parse('https://iis.bsuir.by/api/v1/employees/all');
    final request = await client.getUrl(url);
    final response = await request.close();
    final jsonStrings = await response.transform(utf8.decoder).toList();
    final jsonString = jsonStrings.join();
    final json = jsonDecode(jsonString) as List<dynamic>;
    final teachers = json
        .map((e) => Teachers.fromJson(e as Map<String, dynamic>))
        .toList();
    return teachers;
  }

  Future<List<Groups>> getGroups() async {
    final url = Uri.parse('https://iis.bsuir.by/api/v1/student-groups');
    final request = await client.getUrl(url);
    final response = await request.close();
    final jsonStrings = await response.transform(utf8.decoder).toList();
    final jsonString = jsonStrings.join();
    final json = jsonDecode(jsonString) as List<dynamic>;
    final groups = json
        .map((e) => Groups.fromJson(e as Map<String, dynamic>))
        .toList();
    return groups;
  }


  Future<MainGroup> getScheduleResponse(int groupNumber) async {
    final url = Uri.parse(
      'https://iis.bsuir.by/api/v1/schedule?studentGroup=$groupNumber', 
    );

    final request = await client.getUrl(url);
    final response = await request.close();

    final jsonStrings = await response.transform(utf8.decoder).toList();
    final jsonString = jsonStrings.join();

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return MainGroup.fromJson(json);
  }

  Future<MainGroup> getTeacherResponse(String urlId) async {
    final url = Uri.parse(
      'https://iis.bsuir.by/api/v1/employees/schedule/$urlId', 
    );

    final request = await client.getUrl(url);
    final response = await request.close();

    final jsonStrings = await response.transform(utf8.decoder).toList();
    final jsonString = jsonStrings.join();

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return MainGroup.fromJson(json);
  }

Future<int> getCurrentWeek() async {
    final url = Uri.parse(
      'https://iis.bsuir.by/api/v1/schedule/current-week', 
    );

    final request = await client.getUrl(url);
    final response = await request.close();

    final jsonStrings = await response.transform(utf8.decoder).toList();
    final jsonString = jsonStrings.join();

    final currentWeek = jsonDecode(jsonString) as int;
    return currentWeek;
  }


}
