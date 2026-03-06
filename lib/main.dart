import 'package:bsuir/services/favorite_teacher_service.dart';
import 'package:bsuir/ui/widgets/app/my_app.dart';
import 'package:flutter/material.dart';
import 'package:bsuir/services/favorite_service.dart';

void main() async{


// Инициализируем WidgetsBinding
 WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализируем Hive
  await FavoriteService.initHive();
  await FavoriteTeacherService.initHive();



  runApp(const MyApp());
}

