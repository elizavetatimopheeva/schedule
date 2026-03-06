import 'package:bsuir/domain/entity/employee.dart';
import 'package:bsuir/domain/entity/main_group.dart';
import 'package:bsuir/domain/entity/schedule.dart';
import 'package:bsuir/domain/api_client/api_client.dart';
import 'package:bsuir/services/favorite_teacher_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainTeacherModel extends ChangeNotifier {
  final apiClient = ApiClient();
  final String teacherId;
  MainGroup? _mainGroup;
  String? _errorMessage;
  int? _currentAcademicWeek;
  final VoidCallback? onFavoriteChanged;

  MainTeacherModel(this.teacherId, {this.onFavoriteChanged});

  MainGroup? get mainGroup => _mainGroup;
  String? get errorMessage => _errorMessage;

  Future<void> loadMainGroup() async {
    try {
      _errorMessage = null;
      _currentAcademicWeek = await apiClient.getCurrentWeek();
      final group = await apiClient.getTeacherResponse(teacherId);
      _mainGroup = group;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Ошибка загрузки расписания: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleFavorite() async {
    await FavoriteTeacherService.toggleFavorite(teacherId);
    notifyListeners();
    onFavoriteChanged?.call();
  }

  Future<bool> isFavorite() async {
    return await FavoriteTeacherService.isFavorite(teacherId);
  }

  // ========== ОСНОВНЫЕ МЕТОДЫ ДЛЯ ВЫЧИСЛЕНИЯ НЕДЕЛЬ ==========

  DateTime _getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  int _weeksUntilSemesterStart() {
    final startDateStr = _mainGroup?.startDate;
    if (startDateStr == null || startDateStr.isEmpty) return 0;

    final now = DateTime.now();
    final startDate = parseDate(startDateStr);

    final currentMonday = _getMonday(now);
    final semesterMonday = _getMonday(startDate);

    final diffDays = semesterMonday.difference(currentMonday).inDays;
    return diffDays > 0 ? diffDays ~/ 7 : 0;
  }

  int getBaseWeekOffset() {
    if (hasSemesterStarted()) {
      return 0;
    }
    return _weeksUntilSemesterStart();
  }

  DateTime _getMondayOfCurrentWeek() {
    final now = DateTime.now();
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    return monday;
  }

  DateTime _getMondayForWeek(int weekOffset) {
    final now = DateTime.now();
    final baseOffset = getBaseWeekOffset();

    final baseMonday = _getMonday(now);

    return baseMonday.add(
      Duration(days: (baseOffset + weekOffset) * 7),
    );
  }

  DateTime getBaseDateForWeek(int weekOffset) {
    return _getMondayForWeek(weekOffset);
  }

  // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ ДАТ ==========

  String getDateForCurrentWeekDay(String dayName, String? endDate) {
    return _getDateForWeekDay(0, dayName, endDate);
  }

  String getDateForFutureWeekDay(
    String dayName,
    int weekOffset,
    String? endDate,
  ) {
    return _getDateForWeekDay(weekOffset, dayName, endDate);
  }

  String _getDateForWeekDay(int weekOffset, String dayName, String? endDate) {
    final monday = _getMondayForWeek(weekOffset);
    
    final targetWeekday = getWeekdayNumber(dayName);
    int dayDifference = targetWeekday - 1;
    final targetDate = monday.add(Duration(days: dayDifference));
    
    final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

    if (endDate != null && !isDateValid(targetDate, endDate)) {
      return '$dateString (семестр окончен)';
    }

    return dateString;
  }

  // ========== ОСНОВНОЙ ИЗМЕНЕННЫЙ МЕТОД ДЛЯ ФИЛЬТРАЦИИ РАСПИСАНИЯ ==========

  List<Schedule> getFilteredSchedulesForDay(
    List<Schedule> daySchedules,
    String targetDate,
  ) {
    return daySchedules.where((schedule) {
      if (schedule.announcement == true) {
        return schedule.startLessonDate == targetDate;
      }
      
      final startDate = schedule.startLessonDate;
      final endDate = schedule.endLessonDate;
      
      if (startDate != null && startDate.isNotEmpty && 
          endDate != null && endDate.isNotEmpty) {
        try {
          final scheduleStartDate = parseDate(startDate);
          final scheduleEndDate = parseDate(endDate);
          final currentDate = parseDate(targetDate);
          
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

  // ========== МЕТОДЫ ДЛЯ ПРОВЕРКИ ВАЛИДНОСТИ ==========

  bool isDayValidForCurrentWeek(String dayName, String? endDate) {
    return _isDayValidForWeek(0, dayName, endDate);
  }

  bool isDayValidForFutureWeek(
    String dayName,
    int weekOffset,
    String? endDate,
  ) {
    return _isDayValidForWeek(weekOffset, dayName, endDate);
  }

  bool _isDayValidForWeek(int weekOffset, String dayName, String? endDate) {
    final monday = _getMondayForWeek(weekOffset);
    final targetWeekday = getWeekdayNumber(dayName);
    int dayDifference = targetWeekday - 1;
    final targetDate = monday.add(Duration(days: dayDifference));
    
    if (endDate != null) {
      return isDateValid(targetDate, endDate);
    }
    
    return true;
  }

  bool shouldShowScheduleForDate(DateTime date) {
    final startDateStr = _mainGroup?.startDate;
    final endDateStr = _mainGroup?.endDate;
    
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final startDate = parseDate(startDateStr);
        if (date.isBefore(startDate)) {
          return false;
        }
      } catch (e) {}
    }
    
    if (endDateStr != null && endDateStr.isNotEmpty) {
      try {
        final endDate = parseDate(endDateStr);
        if (date.isAfter(endDate)) {
          return false;
        }
      } catch (e) {}
    }
    
    return true;
  }

  // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ НОМЕРОВ НЕДЕЛЬ ==========

  int getWeekNumberForCurrentWeek(String? startDate) {
    if (_currentAcademicWeek == null) return 1;

    final baseOffset = getBaseWeekOffset();
    return ((_currentAcademicWeek! - 1 + baseOffset) % 4) + 1;
  }

  int getWeekNumberForFutureWeek(int weekOffset, String? startDate) {
    if (_currentAcademicWeek == null) return 1;

    final baseOffset = getBaseWeekOffset();
    return ((_currentAcademicWeek! - 1 + baseOffset + weekOffset) % 4) + 1;
  }

  int getAbsoluteWeekNumberForDisplay(int weekOffset) {
    if (_currentAcademicWeek == null) return 1;
    return _currentAcademicWeek! + weekOffset;
  }

  // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========

  DateTime parseDate(String dateStr) {
    return DateFormat('dd.MM.yyyy').parse(dateStr);
  }

  String getRussianDayName(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Понедельник';
      case 2:
        return 'Вторник';
      case 3:
        return 'Среда';
      case 4:
        return 'Четверг';
      case 5:
        return 'Пятница';
      case 6:
        return 'Суббота';
      default:
        return 'Воскресенье';
    }
  }

  int getWeekdayNumber(String dayName) {
    switch (dayName) {
      case 'Понедельник':
        return 1;
      case 'Вторник':
        return 2;
      case 'Среда':
        return 3;
      case 'Четверг':
        return 4;
      case 'Пятница':
        return 5;
      case 'Суббота':
        return 6;
      case 'Воскресенье':
        return 7;
      default:
        return 1;
    }
  }

  bool isDateValid(DateTime date, String endDateStr) {
    try {
      final endDate = parseDate(endDateStr);
      return date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
    } catch (e) {
      return true;
    }
  }

  int getCurrentWeekNumber(String? startDateStr, {DateTime? currentDate}) {
    return getWeekNumberForCurrentWeek(startDateStr);
  }

  int getAbsoluteWeekNumber(String? startDateStr, {DateTime? currentDate}) {
    if (_currentAcademicWeek == null) return 1;
    return _currentAcademicWeek!;
  }

  // ========== МЕТОДЫ ДЛЯ РАБОТЫ С РАСПИСАНИЕМ ==========

  List<Schedule> getScheduleForDayAndWeek(
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

    return getFilteredSchedulesForDay(filteredByWeekNumber, targetDate);
  }

  List<Schedule> getAnnouncementsForDate(
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

  // ОСНОВНОЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ РАСПИСАНИЯ (только обычные занятия + объявления)
  List<Schedule> getAllSchedulesForDay(
    Map<String, List<Schedule>>? schedules,
    String dayName,
    int weekNumber,
    String date,
  ) {
    // Проверяем, нужно ли показывать расписание для этой даты
    try {
      final targetDate = parseDate(date);
      if (!shouldShowScheduleForDate(targetDate)) {
        return [];
      }
    } catch (e) {}

    // Получаем регулярные занятия с фильтрацией по неделям и датам
    final regularSchedules = getScheduleForDayAndWeek(
      schedules,
      dayName,
      weekNumber,
      date,
    );
    
    // Получаем объявления для этой даты
    final announcements = getAnnouncementsForDate(date, schedules);

    // ФИЛЬТРУЕМ ЭКЗАМЕНЫ И КОНСУЛЬТАЦИИ (не показываем их в обычном расписании)
    final filteredRegularSchedules = regularSchedules.where((schedule) {
      final lessonType = schedule.lessonTypeAbbrev?.toLowerCase() ?? '';
      final isExam = schedule.lessonTypeAbbrev == 'экз' || 
                    lessonType.contains('экз') ||
                    lessonType.contains('exam');
      final isConsult = schedule.lessonTypeAbbrev == 'конс' || 
                       lessonType.contains('конс') ||
                       lessonType.contains('консультация');
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

  // Метод для получения экзаменов
  List<Schedule> getExamsForDate(String date, List<Schedule>? exams) {
    if (exams == null) return [];

    try {
      final targetDate = parseDate(date);
      if (!shouldShowScheduleForDate(targetDate)) {
        return [];
      }
    } catch (e) {}

    return exams.where((exam) {
      final examDate = exam.dateLesson;
      if (examDate == date) return true;
      
      final startDate = exam.startLessonDate;
      final endDate = exam.endLessonDate;
      
      if (startDate != null && startDate.isNotEmpty && 
          endDate != null && endDate.isNotEmpty) {
        try {
          final scheduleStartDate = parseDate(startDate);
          final scheduleEndDate = parseDate(endDate);
          final currentDate = parseDate(date);
          
          return (currentDate.isAfter(scheduleStartDate) || 
                  currentDate.isAtSameMomentAs(scheduleStartDate)) &&
                 (currentDate.isBefore(scheduleEndDate) || 
                  currentDate.isAtSameMomentAs(scheduleEndDate));
        } catch (e) {
          return false;
        }
      }
      
      return false;
    }).toList();
  }

  // Метод для старого API (для обратной совместимости)
  List<Schedule> getAllSchedulesForDayAuto(
    Map<String, List<Schedule>>? schedules,
    List<Schedule>? exams,
    String dayName,
    int weekNumber,
    String date,
  ) {
    // Просто используем основной метод без экзаменов
    return getAllSchedulesForDay(schedules, dayName, weekNumber, date);
  }

  bool isScheduleActiveOnDate(Schedule schedule, String targetDate) {
    if (schedule.announcement == true) {
      return schedule.startLessonDate == targetDate;
    }
    
    final startDate = schedule.startLessonDate;
    final endDate = schedule.endLessonDate;
    
    if (startDate != null && startDate.isNotEmpty && 
        endDate != null && endDate.isNotEmpty) {
      try {
        final scheduleStartDate = parseDate(startDate);
        final scheduleEndDate = parseDate(endDate);
        final currentDate = parseDate(targetDate);
        
        return (currentDate.isAfter(scheduleStartDate) || 
                currentDate.isAtSameMomentAs(scheduleStartDate)) &&
               (currentDate.isBefore(scheduleEndDate) || 
                currentDate.isAtSameMomentAs(scheduleEndDate));
      } catch (e) {
        return true;
      }
    }
    
    return true;
  }

  // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ ИНФОРМАЦИИ О ПРЕПОДАВАТЕЛЕ ==========

  String getEmployeeNameFromList(List<Employee>? employees) {
    if (employees == null || employees.isEmpty) return '';
    return getEmployeeName(employees.first);
  }

  String getEmployeeName(Employee? employee) {
    if (employee == null) return '';

    final firstName = employee.firstName ?? '';
    final lastName = employee.lastName ?? '';
    final middleName = employee.middleName ?? '';

    if (firstName.isEmpty) return lastName;

    final middleInitial = middleName.isNotEmpty ? '${middleName[0]}.' : '';
    return '$lastName ${firstName[0]}.$middleInitial';
  }

  // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ ИНФОРМАЦИИ О ЗАНЯТИИ ==========

  String getGroupsForSchedule(Schedule schedule) {
    if (schedule.studentGroups != null && schedule.studentGroups!.isNotEmpty) {
      return schedule.studentGroups!.map((group) => group.name ?? '').join(', ');
    }
    
    return '';
  }

  String getSubjectName(Schedule schedule) {
    if (schedule.subject != null && schedule.subject!.isNotEmpty) {
      return schedule.subject!;
    }

    if (schedule.subjectFullName != null &&
        schedule.subjectFullName!.isNotEmpty) {
      return schedule.subjectFullName!;
    }

    return schedule.note ?? 'Занятие';
  }

  String getLessonType(Schedule schedule) {
    return schedule.lessonTypeAbbrev ?? 'Занятие';
  }

  bool isAnnouncement(Schedule schedule) {
    return schedule.announcement == true;
  }

  String getAnnouncementDate(Schedule schedule) {
    return schedule.startLessonDate ?? '';
  }

  // ========== МЕТОДЫ ДЛЯ ПРОВЕРКИ СОСТОЯНИЯ ==========

  bool hasData() {
    return _mainGroup != null;
  }

  bool hasMainSchedules(){
    if (_mainGroup == null) return false;
    return _mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty;
  }

  bool hasSchedules() {
    if (_mainGroup == null) return false;
    return (_mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty) ||
           (_mainGroup!.exams != null && _mainGroup!.exams!.isNotEmpty);
  }

  bool isSemesterEnded() {
    final now = DateTime.now();
    final endDateStr = _mainGroup?.endDate;
    
    if (endDateStr != null && endDateStr.isNotEmpty) {
      try {
        final endDate = parseDate(endDateStr);
        return now.isAfter(endDate);
      } catch (e) {
        return true;
      }
    }
    
    return true;
  }

  bool hasSemesterStarted() {
    final now = DateTime.now();
    final startDateStr = _mainGroup?.startDate;
    
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final startDate = parseDate(startDateStr);
        return now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
      } catch (e) {
        return true;
      }
    }
    
    return true;
  }

  String getDayNameFromDate(String dateStr) {
    try {
      final date = DateFormat('dd.MM.yyyy').parse(dateStr);
      switch (date.weekday) {
        case 1:
          return 'Понедельник';
        case 2:
          return 'Вторник';
        case 3:
          return 'Среда';
        case 4:
          return 'Четверг';
        case 5:
          return 'Пятница';
        case 6:
          return 'Суббота';
        case 7:
          return 'Воскресенье';
        default:
          return 'День';
      }
    } catch (e) {
      return 'День';
    }
  }

  String getTeacherFullName() {
    if (_mainGroup?.employeeDto == null) return '';
    
    final employee = _mainGroup!.employeeDto!;
    final lastName = employee.lastName ?? '';
    final firstName = employee.firstName ?? '';
    final middleName = employee.middleName ?? '';
    
    return '$lastName ${firstName.isNotEmpty ? '${firstName[0]}.' : ''}${middleName.isNotEmpty ? '${middleName[0]}.' : ''}'.trim();
  }

  // ========== МЕТОДЫ ДЛЯ ДАТЫ ОТОБРАЖЕНИЯ ==========

  DateTime getStartDisplayDate() {
    final now = DateTime.now();
    final startDateStr = _mainGroup?.startDate;
    
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final startDate = parseDate(startDateStr);
        final displayDate = startDate.isAfter(now) ? startDate : now;
        return displayDate;
      } catch (e) {
      }
    }
    
    return now;
  }

  DateTime getMinDisplayDate() {
    final startDateStr = _mainGroup?.startDate;
    
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final startDate = parseDate(startDateStr);
        return startDate;
      } catch (e) {
      }
    }
    
    return DateTime.now();
  }

  bool isTodayDate(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year && 
           now.month == date.month && 
           now.day == date.day;
  }

  String getCurrentDateFormatted() {
    return DateFormat('dd.MM.yyyy').format(DateTime.now());
  }
}



















// import 'package:bsuir/domain/entity/employee.dart';
// import 'package:bsuir/domain/entity/main_group.dart';
// import 'package:bsuir/domain/entity/schedule.dart';
// import 'package:bsuir/domain/api_client/api_client.dart';
// import 'package:bsuir/services/favorite_teacher_service.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MainTeacherModel extends ChangeNotifier {
//   final apiClient = ApiClient();
//   final String teacherId;
//   MainGroup? _mainGroup;
//   String? _errorMessage;
//   int? _currentAcademicWeek;
//     final VoidCallback? onFavoriteChanged; // ДОБАВЛЕНО: callback

//   MainTeacherModel(this.teacherId, {this.onFavoriteChanged});




//   MainGroup? get mainGroup => _mainGroup;
//   String? get errorMessage => _errorMessage;

//    Future<void> loadMainGroup() async {
//     try {
//       _errorMessage = null;
//       _currentAcademicWeek = await apiClient.getCurrentWeek();
//       final group = await apiClient.getTeacherResponse(teacherId);
//       _mainGroup = group;
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Ошибка загрузки расписания: ${e.toString()}';
//       notifyListeners();
//       rethrow;
//     }
//   }





//   // ДОБАВЛЕНО: переключить избранное
//   Future<void> toggleFavorite() async {
//     await FavoriteTeacherService.toggleFavorite(teacherId);
//     notifyListeners();
//     // Вызываем callback если он есть
//     onFavoriteChanged?.call();
//   }

//   // ДОБАВЛЕНО: проверка избранного
//   Future<bool> isFavorite() async {
//     return await FavoriteTeacherService.isFavorite(teacherId);
//   }





//   // ========== ОСНОВНЫЕ МЕТОДЫ ДЛЯ ВЫЧИСЛЕНИЯ НЕДЕЛЬ ==========

//   DateTime _getMonday(DateTime date) {
//     // Убираем логику с воскресеньем - воскресенье должно быть частью предыдущей недели
//     return date.subtract(Duration(days: date.weekday - 1));
//   }

//   int _weeksUntilSemesterStart() {
//     final startDateStr = _mainGroup?.startDate;
//     if (startDateStr == null || startDateStr.isEmpty) return 0;

//     final now = DateTime.now();
//     final startDate = parseDate(startDateStr);

//     final currentMonday = _getMonday(now);
//     final semesterMonday = _getMonday(startDate);

//     final diffDays = semesterMonday.difference(currentMonday).inDays;
//     return diffDays > 0 ? diffDays ~/ 7 : 0;
//   }

//   int getBaseWeekOffset() {
//     if (hasSemesterStarted()) {
//       return 0;
//     }
//     return _weeksUntilSemesterStart();
//   }

//   DateTime _getMondayOfCurrentWeek() {
//     final now = DateTime.now();
    
//     // Простой расчет понедельника текущей недели
//     DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    
//     return monday;
//   }

//   // Получаем понедельник для заданной недели (относительно текущей)
//   DateTime _getMondayForWeek(int weekOffset) {
//     final now = DateTime.now();
//     final baseOffset = getBaseWeekOffset();

//     final baseMonday = _getMonday(now);

//     return baseMonday.add(
//       Duration(days: (baseOffset + weekOffset) * 7),
//     );
//   }

//   // Базовая дата для недели (понедельник этой недели)
//   DateTime getBaseDateForWeek(int weekOffset) {
//     return _getMondayForWeek(weekOffset);
//   }

//   // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ ДАТ ==========

//   // Получить дату для дня текущей недели
//   String getDateForCurrentWeekDay(String dayName, String? endDate) {
//     return _getDateForWeekDay(0, dayName, endDate);
//   }

//   // Получить дату для дня будущей недели
//   String getDateForFutureWeekDay(
//     String dayName,
//     int weekOffset,
//     String? endDate,
//   ) {
//     return _getDateForWeekDay(weekOffset, dayName, endDate);
//   }

//   // Общий метод для получения даты дня недели
//   String _getDateForWeekDay(int weekOffset, String dayName, String? endDate) {
//     // Получаем понедельник нужной недели
//     final monday = _getMondayForWeek(weekOffset);
    
//     // Вычисляем нужный день недели
//     final targetWeekday = getWeekdayNumber(dayName);
//     int dayDifference = targetWeekday - 1;
//     final targetDate = monday.add(Duration(days: dayDifference));
    
//     // Форматируем дату
//     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

//     // Проверяем, не закончился ли семестр
//     if (endDate != null && !isDateValid(targetDate, endDate)) {
//       return '$dateString (семестр окончен)';
//     }

//     return dateString;
//   }

//   // ========== ОСНОВНОЙ ИЗМЕНЕННЫЙ МЕТОД ДЛЯ ФИЛЬТРАЦИИ РАСПИСАНИЯ ==========
//   // Теперь проверяем startLessonDate и endLessonDate для каждого занятия

//   List<Schedule> getFilteredSchedulesForDay(
//     List<Schedule> daySchedules,
//     String targetDate,
//   ) {
//     return daySchedules.where((schedule) {
//       // Для объявлений проверяем только startLessonDate
//       if (schedule.announcement == true) {
//         return schedule.startLessonDate == targetDate;
//       }
      
//       // Для регулярных занятий проверяем диапазон дат
//       final startDate = schedule.startLessonDate;
//       final endDate = schedule.endLessonDate;
      
//       // Если обе даты указаны - проверяем диапазон
//       if (startDate != null && startDate.isNotEmpty && 
//           endDate != null && endDate.isNotEmpty) {
//         try {
//           final scheduleStartDate = parseDate(startDate);
//           final scheduleEndDate = parseDate(endDate);
//           final currentDate = parseDate(targetDate);
          
//           return (currentDate.isAfter(scheduleStartDate) || 
//                   currentDate.isAtSameMomentAs(scheduleStartDate)) &&
//                  (currentDate.isBefore(scheduleEndDate) || 
//                   currentDate.isAtSameMomentAs(scheduleEndDate));
//         } catch (e) {
//           // Если ошибка парсинга, показываем занятие
//           return true;
//         }
//       }
      
//       // Если диапазон дат не указан, показываем занятие
//       return true;
//     }).toList();
//   }

//   // ========== МЕТОДЫ ДЛЯ ПРОВЕРКИ ВАЛИДНОСТИ ==========

//   bool isDayValidForCurrentWeek(String dayName, String? endDate) {
//     return _isDayValidForWeek(0, dayName, endDate);
//   }

//   bool isDayValidForFutureWeek(
//     String dayName,
//     int weekOffset,
//     String? endDate,
//   ) {
//     return _isDayValidForWeek(weekOffset, dayName, endDate);
//   }

//   bool _isDayValidForWeek(int weekOffset, String dayName, String? endDate) {
//     final monday = _getMondayForWeek(weekOffset);
//     final targetWeekday = getWeekdayNumber(dayName);
//     int dayDifference = targetWeekday - 1;
//     final targetDate = monday.add(Duration(days: dayDifference));
    
//     // Проверяем, что дата до конца семестра (если указан endDate)
//     if (endDate != null) {
//       return isDateValid(targetDate, endDate);
//     }
    
//     return true;
//   }

//   // Проверяем, нужно ли показывать расписание для этой даты
//   bool shouldShowScheduleForDate(DateTime date) {
//     final startDateStr = _mainGroup?.startDate;
//     final endDateStr = _mainGroup?.endDate;
    
//     // Проверяем начало семестра
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
//         if (date.isBefore(startDate)) {
//           return false;
//         }
//       } catch (e) {
//         // Если ошибка парсинга, показываем всё
//       }
//     }
    
//     // Проверяем конец семестра
//     if (endDateStr != null && endDateStr.isNotEmpty) {
//       try {
//         final endDate = parseDate(endDateStr);
//         if (date.isAfter(endDate)) {
//           return false;
//         }
//       } catch (e) {
//         // Если ошибка парсинга, показываем всё
//       }
//     }
    
//     return true;
//   }

//   // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ НОМЕРОВ НЕДЕЛЬ ==========

//   // Получить номер недели для расписания (1-4) для текущей недели
//   int getWeekNumberForCurrentWeek(String? startDate) {
//     if (_currentAcademicWeek == null) return 1;

//     final baseOffset = getBaseWeekOffset();
//     return ((_currentAcademicWeek! - 1 + baseOffset) % 4) + 1;
//   }

//   // Получить номер недели для расписания (1-4) для будущей недели
//   int getWeekNumberForFutureWeek(int weekOffset, String? startDate) {
//     if (_currentAcademicWeek == null) return 1;

//     final baseOffset = getBaseWeekOffset();
//     return ((_currentAcademicWeek! - 1 + baseOffset + weekOffset) % 4) + 1;
//   }

//   // Получить абсолютный номер недели для отображения
//   int getAbsoluteWeekNumberForDisplay(int weekOffset) {
//     if (_currentAcademicWeek == null) return 1;
//     return _currentAcademicWeek! + weekOffset;
//   }

//   // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========

//   DateTime parseDate(String dateStr) {
//     return DateFormat('dd.MM.yyyy').parse(dateStr);
//   }

//   String getRussianDayName(DateTime date) {
//     switch (date.weekday) {
//       case 1:
//         return 'Понедельник';
//       case 2:
//         return 'Вторник';
//       case 3:
//         return 'Среда';
//       case 4:
//         return 'Четверг';
//       case 5:
//         return 'Пятница';
//       case 6:
//         return 'Суббота';
//       default:
//         return 'Воскресенье';
//     }
//   }

//   int getWeekdayNumber(String dayName) {
//     switch (dayName) {
//       case 'Понедельник':
//         return 1;
//       case 'Вторник':
//         return 2;
//       case 'Среда':
//         return 3;
//       case 'Четверг':
//         return 4;
//       case 'Пятница':
//         return 5;
//       case 'Суббота':
//         return 6;
//       case 'Воскресенье':
//         return 7;
//       default:
//         return 1;
//     }
//   }

//   bool isDateValid(DateTime date, String endDateStr) {
//     try {
//       final endDate = parseDate(endDateStr);
//       return date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
//     } catch (e) {
//       return true;
//     }
//   }

//   int getCurrentWeekNumber(String? startDateStr, {DateTime? currentDate}) {
//     return getWeekNumberForCurrentWeek(startDateStr);
//   }

//   int getAbsoluteWeekNumber(String? startDateStr, {DateTime? currentDate}) {
//     if (_currentAcademicWeek == null) return 1;
//     return _currentAcademicWeek!;
//   }

//   // ========== МЕТОДЫ ДЛЯ РАБОТЫ С РАСПИСАНИЕМ ==========

//   List<Schedule> getScheduleForDayAndWeek(
//     Map<String, List<Schedule>>? schedules,
//     String dayName,
//     int weekNumber,
//     String targetDate, // Добавили параметр целевой даты
//   ) {
//     if (schedules == null) return [];

//     final daySchedules = schedules[dayName] ?? [];

//     final filteredByWeekNumber = daySchedules.where((schedule) {
//       if (schedule.announcement == true) {
//         return false; // Объявления обрабатываются отдельно
//       }

//       final weekNumbers = schedule.weekNumber;
//       if (weekNumbers == null || weekNumbers.isEmpty) return false;
//       return weekNumbers.contains(weekNumber);
//     }).toList();

//     // Фильтруем по датам занятий
//     return getFilteredSchedulesForDay(filteredByWeekNumber, targetDate);
//   }

//   List<Schedule> getAnnouncementsForDate(
//     String date,
//     Map<String, List<Schedule>>? schedules,
//   ) {
//     if (schedules == null) return [];

//     final allAnnouncements = <Schedule>[];

//     for (final daySchedules in schedules.values) {
//       for (final schedule in daySchedules) {
//         if (schedule.announcement == true) {
//           final announcementDate = schedule.startLessonDate;
//           if (announcementDate == date) {
//             allAnnouncements.add(schedule);
//           }
//         }
//       }
//     }

//     allAnnouncements.sort((a, b) {
//       final timeA = a.startLessonTime ?? '';
//       final timeB = b.startLessonTime ?? '';
//       return timeA.compareTo(timeB);
//     });

//     return allAnnouncements;
//   }

//   List<Schedule> getAllSchedulesForDay(
//     Map<String, List<Schedule>>? schedules,
//     String dayName,
//     int weekNumber,
//     String date,
//   ) {
//     // Проверяем, нужно ли показывать расписание для этой даты
//     try {
//       final targetDate = parseDate(date);
//       if (!shouldShowScheduleForDate(targetDate)) {
//         return [];
//       }
//     } catch (e) {
//       // Если ошибка парсинга даты, показываем расписание
//     }

//     // Получаем регулярные занятия с фильтрацией по неделям и датам
//     final regularSchedules = getScheduleForDayAndWeek(
//       schedules,
//       dayName,
//       weekNumber,
//       date, // Передаем целевую дату
//     );
    
//     // Получаем объявления для этой даты
//     final announcements = getAnnouncementsForDate(date, schedules);

//     final allSchedules = [...regularSchedules, ...announcements];
//     allSchedules.sort((a, b) {
//       final timeA = a.startLessonTime ?? '';
//       final timeB = b.startLessonTime ?? '';
//       return timeA.compareTo(timeB);
//     });

//     return allSchedules;
//   }

//   List<Schedule> getExamsForDate(String date, List<Schedule>? exams) {
//     if (exams == null) return [];

//     // Проверяем, нужно ли показывать экзамены для этой даты
//     try {
//       final targetDate = parseDate(date);
//       if (!shouldShowScheduleForDate(targetDate)) {
//         return [];
//       }
//     } catch (e) {
//       // Если ошибка парсинга даты, показываем экзамены
//     }

//     // Для экзаменов тоже используем фильтрацию по датам
//     return exams.where((exam) {
//       final examDate = exam.dateLesson;
//       if (examDate == date) return true;
      
//       // Если exam.dateLesson не совпадает, проверяем startLessonDate/endLessonDate
//       final startDate = exam.startLessonDate;
//       final endDate = exam.endLessonDate;
      
//       if (startDate != null && startDate.isNotEmpty && 
//           endDate != null && endDate.isNotEmpty) {
//         try {
//           final scheduleStartDate = parseDate(startDate);
//           final scheduleEndDate = parseDate(endDate);
//           final currentDate = parseDate(date);
          
//           return (currentDate.isAfter(scheduleStartDate) || 
//                   currentDate.isAtSameMomentAs(scheduleStartDate)) &&
//                  (currentDate.isBefore(scheduleEndDate) || 
//                   currentDate.isAtSameMomentAs(scheduleEndDate));
//         } catch (e) {
//           return false;
//         }
//       }
      
//       return false;
//     }).toList();
//   }



//   List<Schedule> getAllSchedulesForDayAuto(
//     Map<String, List<Schedule>>? schedules,
//     List<Schedule>? exams,
//     String dayName,
//     int weekNumber,
//     String date,
//   ) {
//     return getAllSchedulesForDay(schedules, dayName, weekNumber, date);
//   }




//   // Проверяем, активно ли занятие на указанную дату
//   bool isScheduleActiveOnDate(Schedule schedule, String targetDate) {
//     if (schedule.announcement == true) {
//       return schedule.startLessonDate == targetDate;
//     }
    
//     final startDate = schedule.startLessonDate;
//     final endDate = schedule.endLessonDate;
    
//     if (startDate != null && startDate.isNotEmpty && 
//         endDate != null && endDate.isNotEmpty) {
//       try {
//         final scheduleStartDate = parseDate(startDate);
//         final scheduleEndDate = parseDate(endDate);
//         final currentDate = parseDate(targetDate);
        
//         return (currentDate.isAfter(scheduleStartDate) || 
//                 currentDate.isAtSameMomentAs(scheduleStartDate)) &&
//                (currentDate.isBefore(scheduleEndDate) || 
//                 currentDate.isAtSameMomentAs(scheduleEndDate));
//       } catch (e) {
//         return true;
//       }
//     }
    
//     return true;
//   }

//   // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ ИНФОРМАЦИИ О ПРЕПОДАВАТЕЛЕ ==========

//   String getEmployeeNameFromList(List<Employee>? employees) {
//     if (employees == null || employees.isEmpty) return '';
//     return getEmployeeName(employees.first);
//   }

//   String getEmployeeName(Employee? employee) {
//     if (employee == null) return '';

//     final firstName = employee.firstName ?? '';
//     final lastName = employee.lastName ?? '';
//     final middleName = employee.middleName ?? '';

//     if (firstName.isEmpty) return lastName;

//     final middleInitial = middleName.isNotEmpty ? '${middleName[0]}.' : '';
//     return '$lastName ${firstName[0]}.$middleInitial';
//   }

//   // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ ИНФОРМАЦИИ О ЗАНЯТИИ ==========

//   String getGroupsForSchedule(Schedule schedule) {
//     if (schedule.studentGroups != null && schedule.studentGroups!.isNotEmpty) {
//       return schedule.studentGroups!.map((group) => group.name ?? '').join(', ');
//     }
    
//     return '';
//   }

//   String getSubjectName(Schedule schedule) {
//     if (schedule.subject != null && schedule.subject!.isNotEmpty) {
//       return schedule.subject!;
//     }

//     if (schedule.subjectFullName != null &&
//         schedule.subjectFullName!.isNotEmpty) {
//       return schedule.subjectFullName!;
//     }

//     return schedule.note ?? 'Занятие';
//   }

//   String getLessonType(Schedule schedule) {
//     return schedule.lessonTypeAbbrev ?? 'Занятие';
//   }

//   bool isAnnouncement(Schedule schedule) {
//     return schedule.announcement == true;
//   }

//   String getAnnouncementDate(Schedule schedule) {
//     return schedule.startLessonDate ?? '';
//   }

//   // ========== МЕТОДЫ ДЛЯ ПРОВЕРКИ СОСТОЯНИЯ ==========

//   bool hasData() {
//     return _mainGroup != null;
//   }

//   bool hasMainSchedules(){
//     if (_mainGroup == null) return false;
//     return _mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty;
//   }

//   bool hasSchedules() {
//     if (_mainGroup == null) return false;
//     return (_mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty) ||
//            (_mainGroup!.exams != null && _mainGroup!.exams!.isNotEmpty);
//   }

//   bool isSemesterEnded() {
//     final now = DateTime.now();
//     final endDateStr = _mainGroup?.endDate;
    
//     if (endDateStr != null && endDateStr.isNotEmpty) {
//       try {
//         final endDate = parseDate(endDateStr);
//         return now.isAfter(endDate);
//       } catch (e) {
//         return true;
//       }
//     }
    
//     return true;
//   }

//   bool hasSemesterStarted() {
//     final now = DateTime.now();
//     final startDateStr = _mainGroup?.startDate;
    
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
//         return now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
//       } catch (e) {
//         return true;
//       }
//     }
    
//     return true;
//   }

//   String getDayNameFromDate(String dateStr) {
//     try {
//       final date = DateFormat('dd.MM.yyyy').parse(dateStr);
//       switch (date.weekday) {
//         case 1:
//           return 'Понедельник';
//         case 2:
//           return 'Вторник';
//         case 3:
//           return 'Среда';
//         case 4:
//           return 'Четверг';
//         case 5:
//           return 'Пятница';
//         case 6:
//           return 'Суббота';
//         case 7:
//           return 'Воскресенье';
//         default:
//           return 'День';
//       }
//     } catch (e) {
//       return 'День';
//     }
//   }

//   String getTeacherFullName() {
//     if (_mainGroup?.employeeDto == null) return '';
    
//     final employee = _mainGroup!.employeeDto!;
//     final lastName = employee.lastName ?? '';
//     final firstName = employee.firstName ?? '';
//     final middleName = employee.middleName ?? '';
    
//     return '$lastName ${firstName.isNotEmpty ? '${firstName[0]}.' : ''}${middleName.isNotEmpty ? '${middleName[0]}.' : ''}'.trim();
//   }

//   // ========== МЕТОДЫ ДЛЯ ДАТЫ ОТОБРАЖЕНИЯ ==========

//   DateTime getStartDisplayDate() {
//     final now = DateTime.now();
//     final startDateStr = _mainGroup?.startDate;
    
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
        
//         // Возвращаем дату начала семестра или текущую дату, если семестр уже начался
//         final displayDate = startDate.isAfter(now) ? startDate : now;
        
//         // Убираем логику с воскресеньем
//         return displayDate;
//       } catch (e) {
//         // Если ошибка парсинга, используем текущую дату
//       }
//     }
    
//     // Fallback на текущую дату
//     return now;
//   }

//   // Метод для получения минимальной даты для отображения
//   DateTime getMinDisplayDate() {
//     final startDateStr = _mainGroup?.startDate;
    
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
//         return startDate;
//       } catch (e) {
//         // Если ошибка парсинга, используем текущую дату
//       }
//     }
    
//     // Fallback на текущую дату
//     return DateTime.now();
//   }

//   // Проверка, является ли дата сегодняшней
//   bool isTodayDate(DateTime date) {
//     final now = DateTime.now();
//     return now.year == date.year && 
//            now.month == date.month && 
//            now.day == date.day;
//   }

//   // Получение текущей даты в формате dd.MM.yyyy
//   String getCurrentDateFormatted() {
//     return DateFormat('dd.MM.yyyy').format(DateTime.now());
//   }

// }























// import 'package:bsuir/domain/entity/employee.dart';
// import 'package:bsuir/domain/entity/main_group.dart';
// import 'package:bsuir/domain/entity/schedule.dart';
// import 'package:bsuir/domain/api_client/api_client.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MainTeacherModel extends ChangeNotifier {
//   final apiClient = ApiClient();
//   final String teacherId;
//   MainGroup? _mainGroup;
//   String? _errorMessage;
//   int? _currentAcademicWeek;

//   MainTeacherModel(this.teacherId);

//   MainGroup? get mainGroup => _mainGroup;
//   String? get errorMessage => _errorMessage;

//   Future<void> loadMainGroup() async {
//     try {
//       _errorMessage = null;
      
//       _currentAcademicWeek = await apiClient.getCurrentWeek();
      
//       final group = await apiClient.getTeacherResponse(teacherId);
//       _mainGroup = group;
      
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Ошибка загрузки расписания: ${e.toString()}';
//       notifyListeners();
//       rethrow;
//     }
//   }

//   // ========== ОСНОВНЫЕ МЕТОДЫ ДЛЯ ВЫЧИСЛЕНИЯ НЕДЕЛЬ ==========

//   DateTime _getMonday(DateTime date) {
//     // Убираем логику с воскресеньем - воскресенье должно быть частью предыдущей недели
//     return date.subtract(Duration(days: date.weekday - 1));
//   }

//   int _weeksUntilSemesterStart() {
//     final startDateStr = _mainGroup?.startDate;
//     if (startDateStr == null || startDateStr.isEmpty) return 0;

//     final now = DateTime.now();
//     final startDate = parseDate(startDateStr);

//     final currentMonday = _getMonday(now);
//     final semesterMonday = _getMonday(startDate);

//     final diffDays = semesterMonday.difference(currentMonday).inDays;
//     return diffDays > 0 ? diffDays ~/ 7 : 0;
//   }

//   int getBaseWeekOffset() {
//     if (hasSemesterStarted()) {
//       return 0;
//     }
//     return _weeksUntilSemesterStart();
//   }

//   DateTime _getMondayOfCurrentWeek() {
//     final now = DateTime.now();
    
//     // Простой расчет понедельника текущей недели
//     DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    
//     return monday;
//   }

//   // Получаем понедельник для заданной недели (относительно текущей)
//   DateTime _getMondayForWeek(int weekOffset) {
//     final now = DateTime.now();
//     final baseOffset = getBaseWeekOffset();

//     final baseMonday = _getMonday(now);

//     return baseMonday.add(
//       Duration(days: (baseOffset + weekOffset) * 7),
//     );
//   }

//   // Базовая дата для недели (понедельник этой недели)
//   DateTime getBaseDateForWeek(int weekOffset) {
//     return _getMondayForWeek(weekOffset);
//   }

//   // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ ДАТ ==========

//   // Получить дату для дня текущей недели
//   String getDateForCurrentWeekDay(String dayName, String? endDate) {
//     return _getDateForWeekDay(0, dayName, endDate);
//   }

//   // Получить дату для дня будущей недели
//   String getDateForFutureWeekDay(
//     String dayName,
//     int weekOffset,
//     String? endDate,
//   ) {
//     return _getDateForWeekDay(weekOffset, dayName, endDate);
//   }

//   // Общий метод для получения даты дня недели
//   String _getDateForWeekDay(int weekOffset, String dayName, String? endDate) {
//     // Получаем понедельник нужной недели
//     final monday = _getMondayForWeek(weekOffset);
    
//     // Вычисляем нужный день недели
//     final targetWeekday = getWeekdayNumber(dayName);
//     int dayDifference = targetWeekday - 1;
//     final targetDate = monday.add(Duration(days: dayDifference));
    
//     // Форматируем дату
//     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

//     // Проверяем, не закончился ли семестр
//     if (endDate != null && !isDateValid(targetDate, endDate)) {
//       return '$dateString (семестр окончен)';
//     }

//     return dateString;
//   }

//   // ========== ОСНОВНОЙ ИЗМЕНЕННЫЙ МЕТОД ДЛЯ ФИЛЬТРАЦИИ РАСПИСАНИЯ ==========
//   // Теперь проверяем startLessonDate и endLessonDate для каждого занятия

//   List<Schedule> getFilteredSchedulesForDay(
//     List<Schedule> daySchedules,
//     String targetDate,
//   ) {
//     return daySchedules.where((schedule) {
//       // Для объявлений проверяем только startLessonDate
//       if (schedule.announcement == true) {
//         return schedule.startLessonDate == targetDate;
//       }
      
//       // Для регулярных занятий проверяем диапазон дат
//       final startDate = schedule.startLessonDate;
//       final endDate = schedule.endLessonDate;
      
//       // Если обе даты указаны - проверяем диапазон
//       if (startDate != null && startDate.isNotEmpty && 
//           endDate != null && endDate.isNotEmpty) {
//         try {
//           final scheduleStartDate = parseDate(startDate);
//           final scheduleEndDate = parseDate(endDate);
//           final currentDate = parseDate(targetDate);
          
//           return (currentDate.isAfter(scheduleStartDate) || 
//                   currentDate.isAtSameMomentAs(scheduleStartDate)) &&
//                  (currentDate.isBefore(scheduleEndDate) || 
//                   currentDate.isAtSameMomentAs(scheduleEndDate));
//         } catch (e) {
//           // Если ошибка парсинга, показываем занятие
//           return true;
//         }
//       }
      
//       // Если диапазон дат не указан, показываем занятие
//       return true;
//     }).toList();
//   }

//   // ========== МЕТОДЫ ДЛЯ ПРОВЕРКИ ВАЛИДНОСТИ ==========

//   bool isDayValidForCurrentWeek(String dayName, String? endDate) {
//     return _isDayValidForWeek(0, dayName, endDate);
//   }

//   bool isDayValidForFutureWeek(
//     String dayName,
//     int weekOffset,
//     String? endDate,
//   ) {
//     return _isDayValidForWeek(weekOffset, dayName, endDate);
//   }

//   bool _isDayValidForWeek(int weekOffset, String dayName, String? endDate) {
//     final monday = _getMondayForWeek(weekOffset);
//     final targetWeekday = getWeekdayNumber(dayName);
//     int dayDifference = targetWeekday - 1;
//     final targetDate = monday.add(Duration(days: dayDifference));
    
//     // Проверяем, что дата до конца семестра (если указан endDate)
//     if (endDate != null) {
//       return isDateValid(targetDate, endDate);
//     }
    
//     return true;
//   }

//   // Проверяем, нужно ли показывать расписание для этой даты
//   bool shouldShowScheduleForDate(DateTime date) {
//     final startDateStr = _mainGroup?.startDate;
//     final endDateStr = _mainGroup?.endDate;
    
//     // Проверяем начало семестра
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
//         if (date.isBefore(startDate)) {
//           return false;
//         }
//       } catch (e) {
//         // Если ошибка парсинга, показываем всё
//       }
//     }
    
//     // Проверяем конец семестра
//     if (endDateStr != null && endDateStr.isNotEmpty) {
//       try {
//         final endDate = parseDate(endDateStr);
//         if (date.isAfter(endDate)) {
//           return false;
//         }
//       } catch (e) {
//         // Если ошибка парсинга, показываем всё
//       }
//     }
    
//     return true;
//   }

//   // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ НОМЕРОВ НЕДЕЛЬ ==========

//   // Получить номер недели для расписания (1-4) для текущей недели
//   int getWeekNumberForCurrentWeek(String? startDate) {
//     if (_currentAcademicWeek == null) return 1;

//     final baseOffset = getBaseWeekOffset();
//     return ((_currentAcademicWeek! - 1 + baseOffset) % 4) + 1;
//   }

//   // Получить номер недели для расписания (1-4) для будущей недели
//   int getWeekNumberForFutureWeek(int weekOffset, String? startDate) {
//     if (_currentAcademicWeek == null) return 1;

//     final baseOffset = getBaseWeekOffset();
//     return ((_currentAcademicWeek! - 1 + baseOffset + weekOffset) % 4) + 1;
//   }

//   // Получить абсолютный номер недели для отображения
//   int getAbsoluteWeekNumberForDisplay(int weekOffset) {
//     if (_currentAcademicWeek == null) return 1;
//     return _currentAcademicWeek! + weekOffset;
//   }

//   // ========== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ==========

//   DateTime parseDate(String dateStr) {
//     return DateFormat('dd.MM.yyyy').parse(dateStr);
//   }

//   String getRussianDayName(DateTime date) {
//     switch (date.weekday) {
//       case 1:
//         return 'Понедельник';
//       case 2:
//         return 'Вторник';
//       case 3:
//         return 'Среда';
//       case 4:
//         return 'Четверг';
//       case 5:
//         return 'Пятница';
//       case 6:
//         return 'Суббота';
//       default:
//         return 'Воскресенье';
//     }
//   }

//   int getWeekdayNumber(String dayName) {
//     switch (dayName) {
//       case 'Понедельник':
//         return 1;
//       case 'Вторник':
//         return 2;
//       case 'Среда':
//         return 3;
//       case 'Четверг':
//         return 4;
//       case 'Пятница':
//         return 5;
//       case 'Суббота':
//         return 6;
//       case 'Воскресенье':
//         return 7;
//       default:
//         return 1;
//     }
//   }

//   bool isDateValid(DateTime date, String endDateStr) {
//     try {
//       final endDate = parseDate(endDateStr);
//       return date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
//     } catch (e) {
//       return true;
//     }
//   }

//   int getCurrentWeekNumber(String? startDateStr, {DateTime? currentDate}) {
//     return getWeekNumberForCurrentWeek(startDateStr);
//   }

//   int getAbsoluteWeekNumber(String? startDateStr, {DateTime? currentDate}) {
//     if (_currentAcademicWeek == null) return 1;
//     return _currentAcademicWeek!;
//   }

//   // ========== МЕТОДЫ ДЛЯ РАБОТЫ С РАСПИСАНИЕМ ==========

//   List<Schedule> getScheduleForDayAndWeek(
//     Map<String, List<Schedule>>? schedules,
//     String dayName,
//     int weekNumber,
//     String targetDate, // Добавили параметр целевой даты
//   ) {
//     if (schedules == null) return [];

//     final daySchedules = schedules[dayName] ?? [];

//     final filteredByWeekNumber = daySchedules.where((schedule) {
//       if (schedule.announcement == true) {
//         return false; // Объявления обрабатываются отдельно
//       }

//       final weekNumbers = schedule.weekNumber;
//       if (weekNumbers == null || weekNumbers.isEmpty) return false;
//       return weekNumbers.contains(weekNumber);
//     }).toList();

//     // Фильтруем по датам занятий
//     return getFilteredSchedulesForDay(filteredByWeekNumber, targetDate);
//   }

//   List<Schedule> getAnnouncementsForDate(
//     String date,
//     Map<String, List<Schedule>>? schedules,
//   ) {
//     if (schedules == null) return [];

//     final allAnnouncements = <Schedule>[];

//     for (final daySchedules in schedules.values) {
//       for (final schedule in daySchedules) {
//         if (schedule.announcement == true) {
//           final announcementDate = schedule.startLessonDate;
//           if (announcementDate == date) {
//             allAnnouncements.add(schedule);
//           }
//         }
//       }
//     }

//     allAnnouncements.sort((a, b) {
//       final timeA = a.startLessonTime ?? '';
//       final timeB = b.startLessonTime ?? '';
//       return timeA.compareTo(timeB);
//     });

//     return allAnnouncements;
//   }

//   List<Schedule> getAllSchedulesForDay(
//     Map<String, List<Schedule>>? schedules,
//     String dayName,
//     int weekNumber,
//     String date,
//   ) {
//     // Проверяем, нужно ли показывать расписание для этой даты
//     try {
//       final targetDate = parseDate(date);
//       if (!shouldShowScheduleForDate(targetDate)) {
//         return [];
//       }
//     } catch (e) {
//       // Если ошибка парсинга даты, показываем расписание
//     }

//     // Получаем регулярные занятия с фильтрацией по неделям и датам
//     final regularSchedules = getScheduleForDayAndWeek(
//       schedules,
//       dayName,
//       weekNumber,
//       date, // Передаем целевую дату
//     );
    
//     // Получаем объявления для этой даты
//     final announcements = getAnnouncementsForDate(date, schedules);

//     final allSchedules = [...regularSchedules, ...announcements];
//     allSchedules.sort((a, b) {
//       final timeA = a.startLessonTime ?? '';
//       final timeB = b.startLessonTime ?? '';
//       return timeA.compareTo(timeB);
//     });

//     return allSchedules;
//   }

//   List<Schedule> getExamsForDate(String date, List<Schedule>? exams) {
//     if (exams == null) return [];

//     // Проверяем, нужно ли показывать экзамены для этой даты
//     try {
//       final targetDate = parseDate(date);
//       if (!shouldShowScheduleForDate(targetDate)) {
//         return [];
//       }
//     } catch (e) {
//       // Если ошибка парсинга даты, показываем экзамены
//     }

//     // Для экзаменов тоже используем фильтрацию по датам
//     return exams.where((exam) {
//       final examDate = exam.dateLesson;
//       if (examDate == date) return true;
      
//       // Если exam.dateLesson не совпадает, проверяем startLessonDate/endLessonDate
//       final startDate = exam.startLessonDate;
//       final endDate = exam.endLessonDate;
      
//       if (startDate != null && startDate.isNotEmpty && 
//           endDate != null && endDate.isNotEmpty) {
//         try {
//           final scheduleStartDate = parseDate(startDate);
//           final scheduleEndDate = parseDate(endDate);
//           final currentDate = parseDate(date);
          
//           return (currentDate.isAfter(scheduleStartDate) || 
//                   currentDate.isAtSameMomentAs(scheduleStartDate)) &&
//                  (currentDate.isBefore(scheduleEndDate) || 
//                   currentDate.isAtSameMomentAs(scheduleEndDate));
//         } catch (e) {
//           return false;
//         }
//       }
      
//       return false;
//     }).toList();
//   }

//   List<Schedule> getAllSchedulesForDayAuto(
//     Map<String, List<Schedule>>? schedules,
//     List<Schedule>? exams,
//     String dayName,
//     int weekNumber,
//     String date,
//   ) {
//     return getAllSchedulesForDay(schedules, dayName, weekNumber, date);
//   }


//   // Проверяем, активно ли занятие на указанную дату
//   bool isScheduleActiveOnDate(Schedule schedule, String targetDate) {
//     if (schedule.announcement == true) {
//       return schedule.startLessonDate == targetDate;
//     }
    
//     final startDate = schedule.startLessonDate;
//     final endDate = schedule.endLessonDate;
    
//     if (startDate != null && startDate.isNotEmpty && 
//         endDate != null && endDate.isNotEmpty) {
//       try {
//         final scheduleStartDate = parseDate(startDate);
//         final scheduleEndDate = parseDate(endDate);
//         final currentDate = parseDate(targetDate);
        
//         return (currentDate.isAfter(scheduleStartDate) || 
//                 currentDate.isAtSameMomentAs(scheduleStartDate)) &&
//                (currentDate.isBefore(scheduleEndDate) || 
//                 currentDate.isAtSameMomentAs(scheduleEndDate));
//       } catch (e) {
//         return true;
//       }
//     }
    
//     return true;
//   }

//   // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ ИНФОРМАЦИИ О ПРЕПОДАВАТЕЛЕ ==========

//   String getEmployeeNameFromList(List<Employee>? employees) {
//     if (employees == null || employees.isEmpty) return '';
//     return getEmployeeName(employees.first);
//   }

//   String getEmployeeName(Employee? employee) {
//     if (employee == null) return '';

//     final firstName = employee.firstName ?? '';
//     final lastName = employee.lastName ?? '';
//     final middleName = employee.middleName ?? '';

//     if (firstName.isEmpty) return lastName;

//     final middleInitial = middleName.isNotEmpty ? '${middleName[0]}.' : '';
//     return '$lastName ${firstName[0]}.$middleInitial';
//   }

//   // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ ИНФОРМАЦИИ О ЗАНЯТИИ ==========

//   String getGroupsForSchedule(Schedule schedule) {
//     if (schedule.studentGroups != null && schedule.studentGroups!.isNotEmpty) {
//       return schedule.studentGroups!.map((group) => group.name ?? '').join(', ');
//     }
    
//     return '';
//   }

//   String getSubjectName(Schedule schedule) {
//     if (schedule.subject != null && schedule.subject!.isNotEmpty) {
//       return schedule.subject!;
//     }

//     if (schedule.subjectFullName != null &&
//         schedule.subjectFullName!.isNotEmpty) {
//       return schedule.subjectFullName!;
//     }

//     return schedule.note ?? 'Занятие';
//   }

//   String getLessonType(Schedule schedule) {
//     return schedule.lessonTypeAbbrev ?? 'Занятие';
//   }

//   bool isAnnouncement(Schedule schedule) {
//     return schedule.announcement == true;
//   }

//   String getAnnouncementDate(Schedule schedule) {
//     return schedule.startLessonDate ?? '';
//   }

//   // ========== МЕТОДЫ ДЛЯ ПРОВЕРКИ СОСТОЯНИЯ ==========

//   bool hasData() {
//     return _mainGroup != null;
//   }

//   bool hasMainSchedules(){
//     if (_mainGroup == null) return false;
//     return _mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty;
//   }

//   bool hasSchedules() {
//     if (_mainGroup == null) return false;
//     return (_mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty) ||
//            (_mainGroup!.exams != null && _mainGroup!.exams!.isNotEmpty);
//   }

//   bool isSemesterEnded() {
//     final now = DateTime.now();
//     final endDateStr = _mainGroup?.endDate;
    
//     if (endDateStr != null && endDateStr.isNotEmpty) {
//       try {
//         final endDate = parseDate(endDateStr);
//         return now.isAfter(endDate);
//       } catch (e) {
//         return true;
//       }
//     }
    
//     return true;
//   }

//   bool hasSemesterStarted() {
//     final now = DateTime.now();
//     final startDateStr = _mainGroup?.startDate;
    
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
//         return now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
//       } catch (e) {
//         return true;
//       }
//     }
    
//     return true;
//   }

//   String getDayNameFromDate(String dateStr) {
//     try {
//       final date = DateFormat('dd.MM.yyyy').parse(dateStr);
//       switch (date.weekday) {
//         case 1:
//           return 'Понедельник';
//         case 2:
//           return 'Вторник';
//         case 3:
//           return 'Среда';
//         case 4:
//           return 'Четверг';
//         case 5:
//           return 'Пятница';
//         case 6:
//           return 'Суббота';
//         case 7:
//           return 'Воскресенье';
//         default:
//           return 'День';
//       }
//     } catch (e) {
//       return 'День';
//     }
//   }

//   String getTeacherFullName() {
//     if (_mainGroup?.employeeDto == null) return '';
    
//     final employee = _mainGroup!.employeeDto!;
//     final lastName = employee.lastName ?? '';
//     final firstName = employee.firstName ?? '';
//     final middleName = employee.middleName ?? '';
    
//     return '$lastName ${firstName.isNotEmpty ? '${firstName[0]}.' : ''}${middleName.isNotEmpty ? '${middleName[0]}.' : ''}'.trim();
//   }

//   // ========== МЕТОДЫ ДЛЯ ДАТЫ ОТОБРАЖЕНИЯ ==========

//   DateTime getStartDisplayDate() {
//     final now = DateTime.now();
//     final startDateStr = _mainGroup?.startDate;
    
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
        
//         // Возвращаем дату начала семестра или текущую дату, если семестр уже начался
//         final displayDate = startDate.isAfter(now) ? startDate : now;
        
//         // Убираем логику с воскресеньем
//         return displayDate;
//       } catch (e) {
//         // Если ошибка парсинга, используем текущую дату
//       }
//     }
    
//     // Fallback на текущую дату
//     return now;
//   }

//   // Метод для получения минимальной даты для отображения
//   DateTime getMinDisplayDate() {
//     final startDateStr = _mainGroup?.startDate;
    
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
//         return startDate;
//       } catch (e) {
//         // Если ошибка парсинга, используем текущую дату
//       }
//     }
    
//     // Fallback на текущую дату
//     return DateTime.now();
//   }

//   // Проверка, является ли дата сегодняшней
//   bool isTodayDate(DateTime date) {
//     final now = DateTime.now();
//     return now.year == date.year && 
//            now.month == date.month && 
//            now.day == date.day;
//   }

//   // Получение текущей даты в формате dd.MM.yyyy
//   String getCurrentDateFormatted() {
//     return DateFormat('dd.MM.yyyy').format(DateTime.now());
//   }

// }

























// import 'package:bsuir/domain/entity/employee.dart';
// import 'package:bsuir/domain/entity/main_group.dart';
// import 'package:bsuir/domain/entity/schedule.dart';
// import 'package:bsuir/domain/api_client/api_client.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MainTeacherModel extends ChangeNotifier {
//   final apiClient = ApiClient();
//   final String teacherId;
//   MainGroup? _mainGroup;
//   String? _errorMessage;


//   MainTeacherModel(this.teacherId);

//   MainGroup? get mainGroup => _mainGroup;
//   String? get errorMessage => _errorMessage;

//   Future<void> loadMainGroup() async {
//     try {
//       _errorMessage = null;
//       final group = await apiClient.getTeacherResponse(teacherId);
//       _mainGroup = group;
    
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Ошибка загрузки расписания: ${e.toString()}';
//       notifyListeners();
//       rethrow;
//     }
//   }

//   DateTime getStartDisplayDate() {
//     final now = DateTime.now();
//     final startDateStr = _mainGroup?.startDate;
    
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       final baseStart = parseDate(startDateStr);
      
//       if (!baseStart.isAfter(now)) {
//         if (now.weekday == DateTime.sunday) {
//           return now.add(const Duration(days: 1));
//         }
//         return now;
//       }
//       return baseStart;
//     }
    
//     if (now.weekday == DateTime.sunday) {
//       return now.add(const Duration(days: 1));
//     }
//     return now;
//   }

//   DateTime _getMondayForWeek(
//     bool semesterStarted,
//     DateTime referenceDate,
//     int weekOffset,
//   ) {
//     final mondayOfReferenceWeek = referenceDate.subtract(
//       Duration(days: referenceDate.weekday - 1),
//     );

//     return mondayOfReferenceWeek.add(Duration(days: weekOffset * 7));
//   }

//   DateTime getBaseDateForWeek(int weekOffset) {
//     final startDate = getStartDisplayDate();
//     final semesterStarted = hasSemesterStarted();

//     return _getMondayForWeek(semesterStarted, startDate, weekOffset);
//   }

//   DateTime _getMondayOfCurrentWeek() {
//     final now = DateTime.now();

//     if (now.weekday == DateTime.sunday) {
//       return now.add(const Duration(days: 1));
//     }

//     return now.subtract(Duration(days: now.weekday - 1));
//   }

//   String getDateForCurrentWeekDay(String dayName, String? endDate) {
//     final targetWeekday = getWeekdayNumber(dayName);
//     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();

//     final baseWeekday = mondayOfCurrentWeek.weekday;
//     int dayDifference = targetWeekday - baseWeekday;

//     if (dayDifference < 0) {
//       dayDifference += 7;
//     }

//     final targetDate = mondayOfCurrentWeek.add(Duration(days: dayDifference));
//     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

//     if (endDate != null && !isDateValid(targetDate, endDate)) {
//       return '$dateString (семестр окончен)';
//     }

//     return dateString;
//   }

//   String getDateForFutureWeekDay(
//     String dayName,
//     int weekOffset,
//     String? endDate,
//   ) {
//     final targetWeekday = getWeekdayNumber(dayName);
//     final baseDate = getBaseDateForWeek(weekOffset);

//     final baseWeekday = baseDate.weekday;
//     int dayDifference = targetWeekday - baseWeekday;

//     if (dayDifference < 0) {
//       dayDifference += 7;
//     }

//     final targetDate = baseDate.add(Duration(days: dayDifference));
//     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

//     if (endDate != null && !isDateValid(targetDate, endDate)) {
//       return '$dateString (семестр окончен)';
//     }

//     return dateString;
//   }

//   bool isDayValidForCurrentWeek(String dayName, String? endDate) {
//     if (endDate == null) return true;

//     final targetWeekday = getWeekdayNumber(dayName);
//     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();

//     final baseWeekday = mondayOfCurrentWeek.weekday;
//     int dayDifference = targetWeekday - baseWeekday;

//     if (dayDifference < 0) {
//       dayDifference += 7;
//     }

//     final targetDate = mondayOfCurrentWeek.add(Duration(days: dayDifference));
//     return isDateValid(targetDate, endDate);
//   }

//   bool isDayValidForFutureWeek(
//     String dayName,
//     int weekOffset,
//     String? endDate,
//   ) {
//     if (endDate == null) return true;

//     final targetWeekday = getWeekdayNumber(dayName);
//     final baseDate = getBaseDateForWeek(weekOffset);

//     final baseWeekday = baseDate.weekday;
//     int dayDifference = targetWeekday - baseWeekday;

//     if (dayDifference < 0) {
//       dayDifference += 7;
//     }

//     final targetDate = baseDate.add(Duration(days: dayDifference));
//     return isDateValid(targetDate, endDate);
//   }

//   int getWeekNumberForCurrentWeek(String? startDate) {
//     if (startDate == null || startDate.isEmpty) return 1;

//     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();
//     final startDateTime = parseDate(startDate);

//     final difference = mondayOfCurrentWeek.difference(startDateTime).inDays;
//     final weekNumber = (difference ~/ 7) + 1;

//     return weekNumber > 0 ? ((weekNumber - 1) % 4) + 1 : 1;
//   }

//   int getWeekNumberForFutureWeek(int weekOffset, String? startDate) {
//     if (startDate == null || startDate.isEmpty) return 1;

//     final baseDate = getBaseDateForWeek(weekOffset);
//     final startDateTime = parseDate(startDate);

//     final difference = baseDate.difference(startDateTime).inDays;
//     final weekNumber = (difference ~/ 7) + 1;

//     return weekNumber > 0 ? ((weekNumber - 1) % 4) + 1 : 1;
//   }

//   DateTime parseDate(String dateStr) {
//     return DateFormat('dd.MM.yyyy').parse(dateStr);
//   }

//   String getRussianDayName(DateTime date) {
//     switch (date.weekday) {
//       case 1:
//         return 'Понедельник';
//       case 2:
//         return 'Вторник';
//       case 3:
//         return 'Среда';
//       case 4:
//         return 'Четверг';
//       case 5:
//         return 'Пятница';
//       case 6:
//         return 'Суббота';
//       case 7:
//         return 'Воскресенье';
//       default:
//         return 'Понедельник';
//     }
//   }

//   int getWeekdayNumber(String dayName) {
//     switch (dayName) {
//       case 'Понедельник':
//         return 1;
//       case 'Вторник':
//         return 2;
//       case 'Среда':
//         return 3;
//       case 'Четверг':
//         return 4;
//       case 'Пятница':
//         return 5;
//       case 'Суббота':
//         return 6;
//       case 'Воскресенье':
//         return 7;
//       default:
//         return 1;
//     }
//   }

//   bool isDateValid(DateTime date, String endDateStr) {
//     try {
//       final endDate = parseDate(endDateStr);
//       return date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
//     } catch (e) {
//       return true;
//     }
//   }

//   int getCurrentWeekNumber(String? startDateStr, {DateTime? currentDate}) {
//     if (startDateStr == null || startDateStr.isEmpty) return 1;

//     final current = currentDate ?? DateTime.now();
//     final startDate = parseDate(startDateStr);

//     final difference = current.difference(startDate).inDays;
//     final weekNumber = (difference ~/ 7) + 1;

//     return weekNumber > 0 ? ((weekNumber - 1) % 4) + 1 : 1;
//   }

//   int getAbsoluteWeekNumber(String? startDateStr, {DateTime? currentDate}) {
//     if (startDateStr == null || startDateStr.isEmpty) return 1;

//     final current = currentDate ?? DateTime.now();
//     final startDate = parseDate(startDateStr);

//     final difference = current.difference(startDate).inDays;
//     final weekNumber = (difference ~/ 7) + 1;

//     return weekNumber > 0 ? weekNumber : 1;
//   }

//   List<Schedule> getScheduleForDayAndWeek(
//     Map<String, List<Schedule>>? schedules,
//     String dayName,
//     int weekNumber,
//   ) {
//     if (schedules == null) return [];

//     final daySchedules = schedules[dayName] ?? [];

//     return daySchedules.where((schedule) {
//       if (schedule.announcement == true) {
//         return false;
//       }

//       final weekNumbers = schedule.weekNumber;
//       if (weekNumbers == null || weekNumbers.isEmpty) return false;
//       return weekNumbers.contains(weekNumber);
//     }).toList();
//   }

//   List<Schedule> getAnnouncementsForDate(
//     String date,
//     Map<String, List<Schedule>>? schedules,
//   ) {
//     if (schedules == null) return [];

//     final allAnnouncements = <Schedule>[];

//     for (final daySchedules in schedules.values) {
//       for (final schedule in daySchedules) {
//         if (schedule.announcement == true) {
//           final announcementDate = schedule.startLessonDate;
//           if (announcementDate == date) {
//             allAnnouncements.add(schedule);
//           }
//         }
//       }
//     }

//     allAnnouncements.sort((a, b) {
//       final timeA = a.startLessonTime ?? '';
//       final timeB = b.startLessonTime ?? '';
//       return timeA.compareTo(timeB);
//     });

//     return allAnnouncements;
//   }

//   List<Schedule> getAllSchedulesForDay(
//     Map<String, List<Schedule>>? schedules,
//     String dayName,
//     int weekNumber,
//     String date,
//   ) {
//     final regularSchedules = getScheduleForDayAndWeek(
//       schedules,
//       dayName,
//       weekNumber,
//     );
//     final announcements = getAnnouncementsForDate(date, schedules);

//     final allSchedules = [...regularSchedules, ...announcements];
//     allSchedules.sort((a, b) {
//       final timeA = a.startLessonTime ?? '';
//       final timeB = b.startLessonTime ?? '';
//       return timeA.compareTo(timeB);
//     });

//     return allSchedules;
//   }

//   List<Schedule> getExamsForDate(String date, List<Schedule>? exams) {
//     if (exams == null) return [];

//     return exams.where((exam) {
//       final examDate = exam.dateLesson;
//       return examDate == date;
//     }).toList();
//   }

//   List<Schedule> getAllSchedulesForDayAuto(
//     Map<String, List<Schedule>>? schedules,
//     List<Schedule>? exams,
//     String dayName,
//     int weekNumber,
//     String date,
//   ) {
//     return getAllSchedulesForDay(schedules, dayName, weekNumber, date);
//   }

//   String getEmployeeNameFromList(List<Employee>? employees) {
//     if (employees == null || employees.isEmpty) return '';
//     return getEmployeeName(employees.first);
//   }

//   String getEmployeeName(Employee? employee) {
//     if (employee == null) return '';

//     final firstName = employee.firstName ?? '';
//     final lastName = employee.lastName ?? '';
//     final middleName = employee.middleName ?? '';

//     if (firstName.isEmpty) return lastName;

//     final middleInitial = middleName.isNotEmpty ? '${middleName[0]}.' : '';
//     return '$lastName ${firstName[0]}.$middleInitial';
//   }

//   String getGroupsForSchedule(Schedule schedule) {
//     if (schedule.studentGroups != null && schedule.studentGroups!.isNotEmpty) {
//       return schedule.studentGroups!.map((group) => group.name ?? '').join(', ');
//     }
    
//     return '';
//   }

//   String getSubjectName(Schedule schedule) {
//     if (schedule.subject != null && schedule.subject!.isNotEmpty) {
//       return schedule.subject!;
//     }

//     if (schedule.subjectFullName != null &&
//         schedule.subjectFullName!.isNotEmpty) {
//       return schedule.subjectFullName!;
//     }

//     return schedule.note ?? 'Занятие';
//   }

//   String getLessonType(Schedule schedule) {
//     return schedule.lessonTypeAbbrev ?? 'Занятие';
//   }

//   bool isAnnouncement(Schedule schedule) {
//     return schedule.announcement == true;
//   }

//   String getAnnouncementDate(Schedule schedule) {
//     return schedule.startLessonDate ?? '';
//   }

//   bool hasData() {
//     return _mainGroup != null;
//   }

//   bool hasMainSchedules(){
//     if (_mainGroup == null) return false;
//     return _mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty;
//   }

//   bool hasSchedules() {
//     if (_mainGroup == null) return false;
//     return (_mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty) ||(_mainGroup!.exams != null && _mainGroup!.exams!.isNotEmpty) ;
//   }

//   bool isSemesterEnded() {
//     final now = DateTime.now();
//     final endDateStr = _mainGroup?.endDate;
    
//     if (endDateStr != null && endDateStr.isNotEmpty) {
//       try {
//         final endDate = parseDate(endDateStr);
//         return now.isAfter(endDate);
//       } catch (e) {
//         return true;
//       }
//     }
    
//     return true;
//   }

//   bool hasSemesterStarted() {
//     final now = DateTime.now();
//     final startDateStr = _mainGroup?.startDate;
    
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
//         return now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
//       } catch (e) {
//         return true;
//       }
//     }
    
//     return true;
//   }

//   String getDayNameFromDate(String dateStr) {
//     try {
//       final date = DateFormat('dd.MM.yyyy').parse(dateStr);
//       switch (date.weekday) {
//         case 1:
//           return 'Понедельник';
//         case 2:
//           return 'Вторник';
//         case 3:
//           return 'Среда';
//         case 4:
//           return 'Четверг';
//         case 5:
//           return 'Пятница';
//         case 6:
//           return 'Суббота';
//         case 7:
//           return 'Воскресенье';
//         default:
//           return 'День';
//       }
//     } catch (e) {
//       return 'День';
//     }
//   }

//   String getTeacherFullName() {
//     if (_mainGroup?.employeeDto == null) return '';
    
//     final employee = _mainGroup!.employeeDto!;
//     final lastName = employee.lastName ?? '';
//     final firstName = employee.firstName ?? '';
//     final middleName = employee.middleName ?? '';
    
//     return '$lastName ${firstName.isNotEmpty ? '${firstName[0]}.' : ''}${middleName.isNotEmpty ? '${middleName[0]}.' : ''}'.trim();
//   }
// }













