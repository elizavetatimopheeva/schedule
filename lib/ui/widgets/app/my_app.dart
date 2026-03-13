import 'package:bsuir/resourses/app_colors.dart';
import 'package:bsuir/ui/widgets/navigation/main_navigation.dart';
import 'package:bsuir/ui/widgets/splash/splash.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  static final mainNavigation = MainNavigation();
  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BSUIR Schedule',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        ...mainNavigation.routes,
      },
      onGenerateRoute: mainNavigation.onGenerateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}