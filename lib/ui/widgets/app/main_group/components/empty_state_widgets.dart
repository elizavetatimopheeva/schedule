import 'package:bsuir/resourses/app_colors.dart';
import 'package:flutter/material.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: AppColors.greyBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [CircularProgressIndicator(color: AppColors.blue)],
          ),
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {

  const ErrorStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: AppColors.greyBackground,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: AppColors.blue,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ошибка загрузки расписания',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoDataStateWidget extends StatelessWidget {
  const NoDataStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: AppColors.blue),
            const SizedBox(height: 16),
            const Text(
              'Нет данных',
              style: TextStyle(fontSize: 18, color: AppColors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              'Расписание для этой группы не найдено',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

class NoScheduleStateWidget extends StatelessWidget {
  const NoScheduleStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sentiment_satisfied_alt_outlined,
              size: 64,
              color: AppColors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Расписание отсутствует',
              style: TextStyle(fontSize: 18, color: AppColors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
