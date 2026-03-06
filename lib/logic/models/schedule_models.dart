import 'package:bsuir/domain/entity/schedule.dart';
import 'package:equatable/equatable.dart';

enum LessonType { lecture, practice, lab, exam, consultation, other }

class LessonTypeInfo extends Equatable {
  final bool isExam;
  final bool isConsult;
  final bool isLecture;
  final bool isPractice;
  final bool isLab;
  final bool isAnnouncement;
  final LessonType type;
  final String displayName;

  const LessonTypeInfo({
    required this.isExam,
    required this.isConsult,
    required this.isLecture,
    required this.isPractice,
    required this.isLab,
    required this.isAnnouncement,
    required this.type,
    required this.displayName,
  });

  @override
  List<Object?> get props => [
    isExam, isConsult, isLecture, isPractice, isLab, 
    isAnnouncement, type, displayName
  ];
}

class DisplaySchedule extends Equatable {
  final Schedule original;
  final String subjectName;
  final LessonTypeInfo lessonTypeInfo;
  final String teacherImage;
  final String? weekNumberDisplay;

  const DisplaySchedule({
    required this.original,
    required this.subjectName,
    required this.lessonTypeInfo,
    required this.teacherImage,
    this.weekNumberDisplay,
  });

  @override
  List<Object?> get props => [
    original, subjectName, lessonTypeInfo, teacherImage, weekNumberDisplay
  ];
}

class DaySectionData extends Equatable {
  final String dayName;
  final String? dateDisplay;
  final List<DisplaySchedule> schedules;
  final int weekNumber;
  final bool isStartDay;
  final bool isSemesterEnded;
  final bool showWeekNumberInCard;
  final int? forceWeekNumber;

  const DaySectionData({
    required this.dayName,
     this.dateDisplay,
    required this.schedules,
    required this.weekNumber,
    required this.isStartDay,
    required this.isSemesterEnded,
    this.showWeekNumberInCard = false,
    this.forceWeekNumber,
  });

  @override
  List<Object?> get props => [
    dayName, dateDisplay, schedules, weekNumber, isStartDay, 
    isSemesterEnded, showWeekNumberInCard, forceWeekNumber
  ];
}