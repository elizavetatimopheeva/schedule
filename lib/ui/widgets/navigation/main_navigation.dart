import 'package:bsuir/logic/bloc/main_group/main_group_cubit.dart';
import 'package:bsuir/ui/widgets/app/main_screen/main_screen_model.dart';
import 'package:bsuir/ui/widgets/app/main_screen/main_screen_widget.dart';
import 'package:bsuir/ui/widgets/app/main_teacher/main_teacher_model.dart';
import 'package:bsuir/ui/widgets/app/main_teacher/main_teacher_widget.dart';
import 'package:bsuir/ui/widgets/inherited/provider.dart';
import 'package:bsuir/ui/widgets/app/main_group/main_group_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MainNavigationRouteNames {
  static const mainGroup = '/group';
  static const mainTeacher = '/teacher';
  static const mainScreen = '/';
}

class MainNavigation {
  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRouteNames.mainScreen: (context) => NotifierProvider(
      create: () => MainScreenModel(),
      child: const MainScreenWidget(), 
    ),
  };

  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRouteNames.mainGroup:
        final arguments = settings.arguments;
        final groupNumber = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: (context) {
            return BlocProvider(
              create: (context) => MainGroupCubit(groupNumber: groupNumber),
              child: MainGroupScheduleWidget(groupNumber: groupNumber),
            );
          },
        );
        
      case MainNavigationRouteNames.mainTeacher:
        final arguments = settings.arguments;
        final urlId = arguments is String ? arguments : '';
        return MaterialPageRoute(
          builder: (context) {
            return NotifierProvider(
              create: () => MainTeacherModel(urlId),
              child: const MainTeacherScheduleWidget(),
            );
          },
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Что-то пошло не так, перезапустите приложение'),
            ),
          ),
        );
    }
  }
}