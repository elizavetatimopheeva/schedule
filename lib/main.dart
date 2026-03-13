import 'package:bsuir/services/favorite_teacher_service.dart';
import 'package:bsuir/services/subgroup_service.dart';
import 'package:bsuir/ui/widgets/app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:bsuir/services/favorite_group_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FavoriteGroupService.initHive();
  await FavoriteTeacherService.initHive();
  await SubgroupService.initHive();

  runApp(const MyApp());
}
