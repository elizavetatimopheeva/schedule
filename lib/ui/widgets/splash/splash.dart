import 'package:bsuir/resourses/app_colors.dart';
import 'package:bsuir/ui/widgets/navigation/main_navigation.dart';
import 'package:bsuir/ui/widgets/navigation/route_decider.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideWhereToGo();
  }

  Future<void> _decideWhereToGo() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final favoriteGroupId = await RouteDecider.getFirstFavoriteGroup();

    if (!mounted) return;

    final navigator = Navigator.of(context);
    if (favoriteGroupId != null && favoriteGroupId.isNotEmpty) {
      final groupNumber = int.tryParse(favoriteGroupId) ?? 0;
      navigator.pushReplacementNamed(
        MainNavigationRouteNames.mainGroup,
        arguments: groupNumber,
      );
    } else {
      navigator.pushReplacementNamed(MainNavigationRouteNames.mainScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school,
                size: 60,
                color: AppColors.greyBackground,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Расписание занятий',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColors.blue,
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
