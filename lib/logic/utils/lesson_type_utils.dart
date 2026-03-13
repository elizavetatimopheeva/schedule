import 'package:bsuir/domain/entity/schedule.dart';
import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:flutter/material.dart';

class LessonTypeUtils {
  static LessonTypeInfo getLessonTypeInfo(Schedule schedule) {
    final abbrev = schedule.lessonTypeAbbrev?.toLowerCase() ?? '';
    final isAnnouncement = schedule.announcement == true;
    
    if (isAnnouncement) {
      return LessonTypeInfo(
        isExam: false,
        isConsult: false,
        isLecture: false,
        isPractice: false,
        isLab: false,
        isAnnouncement: true,
        type: LessonType.other,
        displayName: 'Объявление',
      );
    }

    final isExam = abbrev.contains('экз');
    final isConsult = abbrev.contains('конс');
    final isLecture = abbrev.contains('лк');
    final isPractice = abbrev.contains('пз');
    final isLab = abbrev.contains('лр');

    LessonType type;
    String displayName;

    if (isExam) {
      type = LessonType.exam;
      displayName = 'Экзамен';
    } else if (isConsult) {
      type = LessonType.consultation;
      displayName = 'Консультация';
    } else if (isLecture) {
      type = LessonType.lecture;
      displayName = 'ЛК';
    } else if (isPractice) {
      type = LessonType.practice;
      displayName = 'ПЗ';
    } else if (isLab) {
      type = LessonType.lab;
      displayName = 'ЛP';
    } else {
      type = LessonType.other;
      displayName = schedule.lessonTypeAbbrev ?? 'Занятие';
    }

    return LessonTypeInfo(
      isExam: isExam,
      isConsult: isConsult,
      isLecture: isLecture,
      isPractice: isPractice,
      isLab: isLab,
      isAnnouncement: isAnnouncement,
      type: type,
      displayName: displayName,
    );
  }

  static Color getLessonTypeColor(LessonTypeInfo info, bool isSemesterEnded, bool isExamView) {
    if (info.isConsult) return Colors.brown;
    if (isSemesterEnded) return Colors.grey;
    if (info.isExam) return Colors.purple;
    if (info.isLecture) return Colors.green;
    if (info.isPractice) return Colors.red;
    if (info.isLab) return Colors.orange;
    return Colors.black;
  }

  static bool isRegularSchedule(Schedule schedule) {
    if (schedule.announcement == true) return true;

    final lessonType = schedule.lessonTypeAbbrev?.toLowerCase() ?? '';
    final isExam = lessonType.contains('экз');
    final isConsult = lessonType.contains('конс');
    return !isExam && !isConsult;
  }
}