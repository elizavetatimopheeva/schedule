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

  static String getEmployeeName(List<Employee>? employees) {
    final employee = employees?.firstOrNull;

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

      if (startDate != null &&
          startDate.isNotEmpty &&
          endDate != null &&
          endDate.isNotEmpty) {
        try {
          final scheduleStartDate = MyDateUtils.parseDate(startDate);
          final scheduleEndDate = MyDateUtils.parseDate(endDate);
          final currentDate = MyDateUtils.parseDate(targetDate);

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

  static List<Schedule> getAllSchedulesForDay(
    Map<String, List<Schedule>>? schedules,
    String dayName,
    int weekNumber,
    String date,
  ) {

    final regularSchedules = getScheduleForDayAndWeek(
      schedules,
      dayName,
      weekNumber,
      date,
    );

    final announcements = getAnnouncementsForDate(date, schedules);

    final filteredRegularSchedules = regularSchedules.where((schedule) {
      final lessonType = schedule.lessonTypeAbbrev?.toLowerCase() ?? '';
      final isExam =
          schedule.lessonTypeAbbrev == 'экз' || lessonType.contains('экз');
      final isConsult =
          schedule.lessonTypeAbbrev == 'конс' || lessonType.contains('конс');
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
}
