// import 'package:bsuir/ui/widgets/app/main_screen/main_screen_model.dart';
// import 'package:bsuir/ui/widgets/app/main_screen/main_screen_widget.dart';
// import 'package:bsuir/ui/widgets/app/main_teacher/main_teacher_model.dart';
// import 'package:bsuir/ui/widgets/app/main_teacher/main_teacher_widget.dart';
// import 'package:bsuir/ui/widgets/inherited/helper.dart';
// import 'package:bsuir/ui/widgets/inherited/provider.dart';
// import 'package:bsuir/ui/widgets/app/main_group/main_group_model.dart';
// import 'package:bsuir/ui/widgets/app/main_group/main_group_widget.dart';
// import 'package:flutter/material.dart';

// abstract class MainNavigationRouteNames {
//   static const mainGroup = '/lessons';
//   static const mainTeacher = '/teacher';
//   static const mainScreen = '/';
//   static const helper = '/helper';
// }

// class MainNavigation {
//   String initialRoute(bool isFavourite) => isFavourite
//       ? MainNavigationRouteNames.mainGroup
//       : MainNavigationRouteNames.mainScreen;

//   final routes = <String, Widget Function(BuildContext)>{
//     MainNavigationRouteNames.mainScreen: (context) => NotifierProvider(
//       create: () => MainScreenModel(),
//       child: MainScreenWidget(),
//     ),
//     // MainNavigationRouteNames.helper: (context) => NotifierProvider(
//     //   create: () => MainScreenModel(),
//     //   child: GroupScheduleScreen(),)
//   };

//   Route<Object> onGenerateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case MainNavigationRouteNames.mainGroup:
//         final arguments = settings.arguments;
//         final groupNumber = arguments is int ? arguments : 0;
//         return MaterialPageRoute(
//           builder: (context) {
//             return NotifierProvider(
//               create: () => MainGroupModel(groupNumber),
//               child: MainGroupScheduleWidget(),
//             );
//           },
//         );
//         case MainNavigationRouteNames.mainTeacher:
//         final arguments = settings.arguments;
//         final urlId = arguments is String ? arguments : '';
//         return MaterialPageRoute(
//           builder: (context) {
//             return NotifierProvider(
//               create: () => MainTeacherModel(urlId),
//               child: MainTeacherScheduleWidget(),
//             );
//           },
//         );
//       default:
//         const widget = Text('Navigation Error!');
//         return MaterialPageRoute(builder: (context) => widget);
//     }
//   }
// }



import 'package:bsuir/ui/widgets/app/main_screen/main_screen_model.dart';
import 'package:bsuir/ui/widgets/app/main_screen/main_screen_widget.dart';
import 'package:bsuir/ui/widgets/app/main_teacher/main_teacher_model.dart';
import 'package:bsuir/ui/widgets/app/main_teacher/main_teacher_widget.dart';
import 'package:bsuir/ui/widgets/inherited/helper.dart';
import 'package:bsuir/ui/widgets/inherited/provider.dart';
import 'package:bsuir/ui/widgets/app/main_group/main_group_model.dart';
import 'package:bsuir/ui/widgets/app/main_group/main_group_widget.dart';
import 'package:flutter/material.dart';

abstract class MainNavigationRouteNames {
  static const mainGroup = '/lessons';
  static const mainTeacher = '/teacher';
  static const mainScreen = '/';
  static const helper = '/helper';
}

class MainNavigation {
  String initialRoute(bool isFavourite) => isFavourite
      ? MainNavigationRouteNames.mainGroup
      : MainNavigationRouteNames.mainScreen;

  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRouteNames.mainScreen: (context) => NotifierProvider(
      create: () => MainScreenModel(),
      child: MainScreenWidget(),
    ),
  };

  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRouteNames.mainGroup:
        final arguments = settings.arguments;
        final groupNumber = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: (context) {
            return NotifierProvider(
              create: () => MainGroupModel(groupNumber, ),
              child: MainGroupScheduleWidget(),
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
              child: MainTeacherScheduleWidget(),
            );
          },
        );

      default:
        const widget = Text('Navigation Error!');
        return MaterialPageRoute(builder: (context) => widget);
    }
  }
}