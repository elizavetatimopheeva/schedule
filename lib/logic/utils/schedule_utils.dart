import 'package:bsuir/domain/entity/employee.dart';
import 'package:bsuir/domain/entity/schedule.dart';
import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/logic/utils/date_utils.dart';
import 'package:bsuir/logic/utils/lesson_type_utils.dart';

class ScheduleUtils {
  static String getSubjectName(Schedule schedule) {
    if (schedule.subject != null && schedule.subject!.isNotEmpty) {
      return schedule.subject!;
    }

    if (schedule.subjectFullName != null &&
        schedule.subjectFullName!.isNotEmpty) {
      return schedule.subjectFullName!;
    }

    return schedule.note ?? 'Занятие';
  }

  static String getTeacherImage(List<Employee>? employees) {
    return employees?.firstOrNull?.photoLink ?? '';
  }

  static String getEmployeeName(Employee? employee) {
    if (employee == null) return '';

    final firstName = employee.firstName;
    final lastName = employee.lastName;
    final middleName = employee.middleName ?? '';

    return '$lastName $firstName $middleName';
  }

  static List<Schedule> filterSchedulesByDate(
    List<Schedule> schedules,
    String targetDate,
  ) {
    return schedules.where((schedule) {
      if (schedule.announcement == true) {
        return schedule.startLessonDate == targetDate;
      }
      
      final startDate = schedule.startLessonDate;
      final endDate = schedule.endLessonDate;
      
      if (startDate != null && startDate.isNotEmpty && 
          endDate != null && endDate.isNotEmpty) {
        try {
          final scheduleStartDate = DateUtils.parseDate(startDate);
          final scheduleEndDate = DateUtils.parseDate(endDate);
          final currentDate = DateUtils.parseDate(targetDate);
          
          return (currentDate.isAfter(scheduleStartDate) || 
                  currentDate.isAtSameMomentAs(scheduleStartDate)) &&
                 (currentDate.isBefore(scheduleEndDate) || 
                  currentDate.isAtSameMomentAs(scheduleEndDate));
        } catch (e) {
          return true;
        }
      }
      
      return true;
    }).toList();
  }

  static List<Schedule> getScheduleForDayAndWeek(
    Map<String, List<Schedule>>? schedules,
    String dayName,
    int weekNumber,
    String targetDate,
  ) {
    if (schedules == null) return [];

    final daySchedules = schedules[dayName] ?? [];

    final filteredByWeekNumber = daySchedules.where((schedule) {
      if (schedule.announcement == true) {
        return false;
      }

      final weekNumbers = schedule.weekNumber;
      if (weekNumbers == null || weekNumbers.isEmpty) return false;
      return weekNumbers.contains(weekNumber);
    }).toList();

    return filterSchedulesByDate(filteredByWeekNumber, targetDate);
  }

  static List<Schedule> getAnnouncementsForDate(
    String date,
    Map<String, List<Schedule>>? schedules,
  ) {
    if (schedules == null) return [];

    final allAnnouncements = <Schedule>[];

    for (final daySchedules in schedules.values) {
      for (final schedule in daySchedules) {
        if (schedule.announcement == true) {
          final announcementDate = schedule.startLessonDate;
          if (announcementDate == date) {
            allAnnouncements.add(schedule);
          }
        }
      }
    }

    allAnnouncements.sort((a, b) {
      final timeA = a.startLessonTime ?? '';
      final timeB = b.startLessonTime ?? '';
      return timeA.compareTo(timeB);
    });

    return allAnnouncements;
  }

  // НОВЫЙ МЕТОД: getAllSchedulesForDay
  static List<Schedule> getAllSchedulesForDay(
    Map<String, List<Schedule>>? schedules,
    String dayName,
    int weekNumber,
    String date,
  ) {
    // try {
    //   final targetDate = DateUtils.parseDate(date);
    //   // Проверка shouldShowScheduleForDate будет добавлена позже, если нужна
    // } catch (e) {}

    final regularSchedules = getScheduleForDayAndWeek(
      schedules,
      dayName,
      weekNumber,
      date,
    );
    
    final announcements = getAnnouncementsForDate(date, schedules);

    final filteredRegularSchedules = regularSchedules.where((schedule) {
      final lessonType = schedule.lessonTypeAbbrev?.toLowerCase() ?? '';
      final isExam = schedule.lessonTypeAbbrev == 'экз' || 
                    lessonType.contains('экз');
      final isConsult = schedule.lessonTypeAbbrev == 'конс' || 
                       lessonType.contains('конс');
      return !isExam && !isConsult;
    }).toList();

    final allSchedules = [...filteredRegularSchedules, ...announcements];
    allSchedules.sort((a, b) {
      final timeA = a.startLessonTime ?? '';
      final timeB = b.startLessonTime ?? '';
      return timeA.compareTo(timeB);
    });

    return allSchedules;
  }

  // НОВЫЙ МЕТОД: getExamsForDate
  // static List<Schedule> getExamsForDate(String date, List<Schedule>? exams) {
  //   if (exams == null) return [];

  //   // try {
  //   //   final targetDate = DateUtils.parseDate(date);
  //   //   // Проверка валидности даты может быть добавлена позже
  //   // } catch (e) {}

  //   return exams.where((exam) {
  //     final examDate = exam.dateLesson;
  //     if (examDate == date) return true;
      
  //     final startDate = exam.startLessonDate;
  //     final endDate = exam.endLessonDate;
      
  //     if (startDate != null && startDate.isNotEmpty && 
  //         endDate != null && endDate.isNotEmpty) {
  //       try {
  //         final scheduleStartDate = DateUtils.parseDate(startDate);
  //         final scheduleEndDate = DateUtils.parseDate(endDate);
  //         final currentDate = DateUtils.parseDate(date);
          
  //         return (currentDate.isAfter(scheduleStartDate) || 
  //                 currentDate.isAtSameMomentAs(scheduleStartDate)) &&
  //                (currentDate.isBefore(scheduleEndDate) || 
  //                 currentDate.isAtSameMomentAs(scheduleEndDate));
  //       } catch (e) {
  //         return false;
  //       }
  //     }
      
  //     return false;
  //   }).toList();
  // }

  // НОВЫЙ МЕТОД: shouldShowScheduleForDate
  // static bool shouldShowScheduleForDate(
  //   DateTime date,
  //   String? startDateStr,
  //   String? endDateStr,
  // ) {
  //   if (startDateStr != null && startDateStr.isNotEmpty) {
  //     try {
  //       final startDate = DateUtils.parseDate(startDateStr);
  //       if (date.isBefore(startDate)) {
  //         return false;
  //       }
  //     } catch (e) {}
  //   }
    
  //   if (endDateStr != null && endDateStr.isNotEmpty) {
  //     try {
  //       final endDate = DateUtils.parseDate(endDateStr);
  //       if (date.isAfter(endDate)) {
  //         return false;
  //       }
  //     } catch (e) {}
  //   }
    
  //   return true;
  // }

  static List<DisplaySchedule> convertToDisplaySchedules(
    List<Schedule> schedules,
    String? weekNumberDisplay,
  ) {
    return schedules.map((schedule) {
      return DisplaySchedule(
        original: schedule,
        subjectName: getSubjectName(schedule),
        lessonTypeInfo: LessonTypeUtils.getLessonTypeInfo(schedule),
        teacherImage: getTeacherImage(schedule.employees),
        weekNumberDisplay: weekNumberDisplay,
      );
    }).toList();
  }

  // static bool isScheduleActiveOnDate(Schedule schedule, String targetDate) {
  //   if (schedule.announcement == true) {
  //     return schedule.startLessonDate == targetDate;
  //   }
    
  //   final startDate = schedule.startLessonDate;
  //   final endDate = schedule.endLessonDate;
    
  //   if (startDate != null && startDate.isNotEmpty && 
  //       endDate != null && endDate.isNotEmpty) {
  //     try {
  //       final scheduleStartDate = DateUtils.parseDate(startDate);
  //       final scheduleEndDate = DateUtils.parseDate(endDate);
  //       final currentDate = DateUtils.parseDate(targetDate);
        
  //       return (currentDate.isAfter(scheduleStartDate) || 
  //               currentDate.isAtSameMomentAs(scheduleStartDate)) &&
  //              (currentDate.isBefore(scheduleEndDate) || 
  //               currentDate.isAtSameMomentAs(scheduleEndDate));
  //     } catch (e) {
  //       return true;
  //     }
  //   }
    
  //   return true;
  // }
}