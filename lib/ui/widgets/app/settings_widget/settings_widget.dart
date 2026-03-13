import 'package:bsuir/resourses/app_colors.dart';
import 'package:flutter/material.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = EdgeInsets.symmetric(horizontal: 5, vertical: 12);
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20),
            _appVersion(padding),
            SizedBox(height: 20),
            _aboutApp(padding),
          ],
        ),
      ),
    );
  }

  Widget _appVersion(EdgeInsets padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Версия"),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: AppColors.blue),
            borderRadius: BorderRadius.circular(5),
            color: AppColors.white,
          ),
          child: Padding(
            padding: padding,
            child: Row(
              children: [Text("1.0.0", style: TextStyle(fontSize: 15))],
            ),
          ),
        ),
      ],
    );
  }

  Widget _aboutApp(EdgeInsets padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("О приложении"),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: AppColors.blue),
            borderRadius: BorderRadius.circular(5),
            color: AppColors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: padding,
                child: Text("Github", style: TextStyle(fontSize: 15)),
              ),
              Divider(height: 1),
              Padding(
                padding: padding,
                child: Text("LinkedIn", style: TextStyle(fontSize: 15)),
              ),
              Divider(height: 1),
              Padding(
                padding: padding,
                child: Text(
                  "Оценить приложение",
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
