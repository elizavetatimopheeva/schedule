
// import 'package:bsuir/ui/widgets/navigation/main_navigation.dart';
// import 'package:flutter/material.dart';

// class MyApp extends StatelessWidget {
//   static final mainNavigation = MainNavigation();
//   const MyApp({super.key});

 
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       routes: mainNavigation.routes,
//       // {
//       //   '/lessons':(context)=> MainGroupWidget(),
//       //   '/':(context)=> MainScreenWidget(),
//       // },
//       initialRoute: mainNavigation.initialRoute(false),
//       onGenerateRoute: mainNavigation.onGenerateRoute,
      
//       // '/lessons',
//     );
//   }
// }

import 'package:bsuir/ui/widgets/navigation/main_navigation.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  static final mainNavigation = MainNavigation();
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: mainNavigation.routes,
      initialRoute: mainNavigation.initialRoute(false),
      onGenerateRoute: mainNavigation.onGenerateRoute,
    );
  }
}