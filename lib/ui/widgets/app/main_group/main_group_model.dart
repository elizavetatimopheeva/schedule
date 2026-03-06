// // import 'package:bsuir/domain/entity/employee.dart';
// // import 'package:bsuir/domain/entity/main_group.dart';
// // import 'package:bsuir/domain/entity/schedule.dart';
// // import 'package:bsuir/domain/api_client/api_client.dart';
// // import 'package:bsuir/services/favorite_service.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class MainGroupModel extends ChangeNotifier {
// //   final apiClient = ApiClient();
// //   final int groupNumber;
// //   MainGroup? _mainGroup;
// //   String? _errorMessage;



// //   // Флаг избранного для этой группы
// //   bool _isFavorite = false;
// //   bool get isFavorite => _isFavorite;




// //   MainGroupModel(this.groupNumber);


// //   MainGroup? get mainGroup => _mainGroup;
// //   String? get errorMessage => _errorMessage;

// //   // Future<void> loadMainGroup() async {
// //   //   try {
// //   //     _errorMessage = null;
// //   //     final group = await apiClient.getScheduleResponse(groupNumber);
// //   //     _mainGroup = group;
// //   //     notifyListeners();
// //   //   } catch (e) {
// //   //     _errorMessage = 'Ошибка загрузки расписания: ${e.toString()}';
// //   //     notifyListeners();
// //   //     rethrow;
// //   //   }
// //   // }



// // Future<void> loadMainGroup() async {
// //     try {
// //       _errorMessage = null;
// //       final group = await apiClient.getScheduleResponse(groupNumber);
// //       _mainGroup = group;
      
// //       // Проверяем, есть ли группа в избранном
// //       _isFavorite = await FavoriteService.isFavorite(groupNumber.toString());
      
// //       notifyListeners();
// //     } catch (e) {
// //       _errorMessage = 'Ошибка загрузки расписания: ${e.toString()}';
// //       notifyListeners();
// //       rethrow;
// //     }
// //   }

// //   // Переключить избранное
// //   Future<void> toggleFavorite() async {
// //     await FavoriteService.toggleFavorite(groupNumber.toString());
// //     _isFavorite = !_isFavorite;
// //     notifyListeners();
// //   }



  



// //   bool get isZaochOrDist {
// //     return _mainGroup?.isZaochOrDist == true;
// //   }

// //   DateTime getStartDisplayDate() {
// //     final now = DateTime.now();

// //     DateTime baseStart;

// //     if (isZaochOrDist) {
// //       final startExamsDateStr = _mainGroup?.startExamsDate;
// //       if (startExamsDateStr != null && startExamsDateStr.isNotEmpty) {
// //         baseStart = parseDate(startExamsDateStr);
// //       } else {
// //         baseStart = now;
// //       }
// //     } else {
// //       final startDateStr = _mainGroup?.startDate;
// //       if (startDateStr != null && startDateStr.isNotEmpty) {
// //         baseStart = parseDate(startDateStr);
// //       } else {
// //         baseStart = now;
// //       }
// //     }

// //     // если расписание уже началось — берём today
// //     if (!baseStart.isAfter(now)) {
// //       // ⛔ воскресенье — не учебный день
// //       // if (now.weekday == DateTime.sunday) {
// //       //   return now.add(const Duration(days: 1)); // понедельник
// //       // }
// //       return now;
// //     }

// //     // если расписание ещё НЕ началось — показываем с даты начала
// //     return baseStart;
// //   }

// //   /// Получает базовую дату (понедельник) для недели с учетом типа
// //   DateTime _getMondayForWeek(
// //     bool semesterStarted,
// //     DateTime referenceDate,
// //     int weekOffset,
// //   ) {
// //     final mondayOfReferenceWeek = referenceDate.subtract(
// //       Duration(days: referenceDate.weekday - 1),
// //     );

// //     return mondayOfReferenceWeek.add(Duration(days: weekOffset * 7));
// //   }

// //   /// Получает базовую дату для недели с offset
// //   /// Для семестров, которые уже начались:
// //   ///   - weekOffset = 0: текущая неделя (начиная с сегодняшнего дня)
// //   ///   - weekOffset = 1: следующая неделя
// //   /// Для семестров, которые еще не начались:
// //   ///   - weekOffset = 0: неделя начала
// //   ///   - weekOffset = 1: следующая неделя
// //   DateTime getBaseDateForWeek(int weekOffset) {
// //     final startDate = getStartDisplayDate();
// //     final semesterStarted = hasSemesterStarted();

// //     return _getMondayForWeek(semesterStarted, startDate, weekOffset);
// //   }

// //   DateTime _getMondayOfCurrentWeek() {
// //     final now = DateTime.now();

// //     // if (now.weekday == DateTime.sunday) {
// //     //   // воскресенье = уже следующая неделя
// //     //   return now.add(const Duration(days: 1)); ????????????????????????????????????????????????????????????
// //     // }


// //     return now.subtract(Duration(days: now.weekday - 1));
// //   }

// //   /// Получает дату для конкретного дня недели для ТЕКУЩЕЙ недели
// //   String getDateForCurrentWeekDay(String dayName, String? endDate) {
// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();

// //     final baseWeekday = mondayOfCurrentWeek.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = mondayOfCurrentWeek.add(Duration(days: dayDifference));
// //     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

// //     // if (endDate != null && !isDateValid(targetDate, endDate)) {
// //     //   return '$dateString (семестр окончен)';
// //     // }

// //     return dateString;
// //   }

// //   /// Получает дату для конкретного дня недели для БУДУЩИХ недель
// //   String getDateForFutureWeekDay(
// //     String dayName,
// //     int weekOffset,
// //     String? endDate,
// //   ) {
// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final baseDate = getBaseDateForWeek(weekOffset);

// //     final baseWeekday = baseDate.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = baseDate.add(Duration(days: dayDifference));
// //     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

// //     // if (endDate != null && !isDateValid(targetDate, endDate)) {
// //     //   return '$dateString (семестр окончен)';
// //     // }

// //     return dateString;
// //   }

// //   /// Проверяет, является ли день валидным для текущей недели
// //   bool isDayValidForCurrentWeek(String dayName, String? endDate) {
// //     if (endDate == null) return true;

// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();

// //     final baseWeekday = mondayOfCurrentWeek.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = mondayOfCurrentWeek.add(Duration(days: dayDifference));
// //     return isDateValid(targetDate, endDate);
// //   }

// //   /// Проверяет, является ли день валидным для будущих недель
// //   bool isDayValidForFutureWeek(
// //     String dayName,
// //     int weekOffset,
// //     String? endDate,
// //   ) {
// //     if (endDate == null) return true;

// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final baseDate = getBaseDateForWeek(weekOffset);

// //     final baseWeekday = baseDate.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = baseDate.add(Duration(days: dayDifference));
// //     return isDateValid(targetDate, endDate);
// //   }

// //   /// Получает номер недели для отображения для ТЕКУЩЕЙ недели
// //   int getWeekNumberForCurrentWeek(String? startDate) {
// //     if (startDate == null || startDate.isEmpty) return 1;

// //     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();
// //     final startDateTime = parseDate(startDate);

// //     final difference = mondayOfCurrentWeek.difference(startDateTime).inDays;
// //     final weekNumber = (difference ~/ 7) + 1;

// //     return weekNumber > 0 ? ((weekNumber - 1) % 4) + 1 : 1;
// //   }

// //   /// Получает номер недели для отображения для БУДУЩИХ недель
// //   int getWeekNumberForFutureWeek(int weekOffset, String? startDate) {
// //     if (startDate == null || startDate.isEmpty) return 1;

// //     final baseDate = getBaseDateForWeek(weekOffset);
// //     final startDateTime = parseDate(startDate);

// //     final difference = baseDate.difference(startDateTime).inDays;
// //     final weekNumber = (difference ~/ 7) + 1;

// //     return weekNumber > 0 ? ((weekNumber - 1) % 4) + 1 : 1;
// //   }

// //   // Вспомогательные методы
// //   DateTime parseDate(String dateStr) {
// //     return DateFormat('dd.MM.yyyy').parse(dateStr);
// //   }

// //   String getRussianDayName(DateTime date) {
// //     switch (date.weekday) {
// //       case 1:
// //         return 'Понедельник';
// //       case 2:
// //         return 'Вторник';
// //       case 3:
// //         return 'Среда';
// //       case 4:
// //         return 'Четверг';
// //       case 5:
// //         return 'Пятница';
// //       case 6:
// //         return 'Суббота';
// //       case 7:
// //         return 'Воскресенье';
// //       default:
// //         return 'Понедельник';
// //     }
// //   }

// //   int getWeekdayNumber(String dayName) {
// //     switch (dayName) {
// //       case 'Понедельник':
// //         return 1;
// //       case 'Вторник':
// //         return 2;
// //       case 'Среда':
// //         return 3;
// //       case 'Четверг':
// //         return 4;
// //       case 'Пятница':
// //         return 5;
// //       case 'Суббота':
// //         return 6;
// //       case 'Воскресенье':
// //         return 7;
// //       default:
// //         return 1;
// //     }
// //   }

// //   bool isDateValid(DateTime date, String endDateStr) {
// //     try {
// //       final endDate = parseDate(endDateStr);
// //       return date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
// //     } catch (e) {
// //       return true;
// //     }
// //   }

// //   int getCurrentWeekNumber(String? startDateStr, {DateTime? currentDate}) {
// //     if (startDateStr == null || startDateStr.isEmpty) return 1;

// //     final current = currentDate ?? DateTime.now();
// //     final startDate = parseDate(startDateStr);

// //     final difference = current.difference(startDate).inDays;
// //     final weekNumber = (difference ~/ 7) + 1;

// //     return weekNumber > 0 ? ((weekNumber - 1) % 4) + 1 : 1;
// //   }

// //   int getAbsoluteWeekNumber(String? startDateStr, {DateTime? currentDate}) {
// //     if (startDateStr == null || startDateStr.isEmpty) return 1;

// //     final current = currentDate ?? DateTime.now();
// //     final startDate = parseDate(startDateStr);

// //     final difference = current.difference(startDate).inDays;
// //     final weekNumber = (difference ~/ 7) + 1;

// //     return weekNumber > 0 ? weekNumber : 1;
// //   }

// //   // Методы для получения расписания 
// //   List<Schedule> getScheduleForDayAndWeek(
// //     Map<String, List<Schedule>>? schedules,
// //     String dayName,
// //     int weekNumber,
// //   ) {
// //     if (schedules == null) return [];

// //     final daySchedules = schedules[dayName] ?? [];

// //     return daySchedules.where((schedule) {
// //       if (schedule.announcement == true) {
// //         return false;
// //       }

// //       final weekNumbers = schedule.weekNumber;
// //       if (weekNumbers == null || weekNumbers.isEmpty) return false;
// //       return weekNumbers.contains(weekNumber);
// //     }).toList();
// //   }

// //   List<Schedule> getAnnouncementsForDate(
// //     String date,
// //     Map<String, List<Schedule>>? schedules,
// //   ) {
// //     if (schedules == null) return [];

// //     final allAnnouncements = <Schedule>[];

// //     for (final daySchedules in schedules.values) {
// //       for (final schedule in daySchedules) {
// //         if (schedule.announcement == true) {
// //           final announcementDate = schedule.startLessonDate;
// //           if (announcementDate == date) {
// //             allAnnouncements.add(schedule);
// //           }
// //         }
// //       }
// //     }

// //     allAnnouncements.sort((a, b) {
// //       final timeA = a.startLessonTime ?? '';
// //       final timeB = b.startLessonTime ?? '';
// //       return timeA.compareTo(timeB);
// //     });

// //     return allAnnouncements;
// //   }

// //   List<Schedule> getAllSchedulesForDay(
// //     Map<String, List<Schedule>>? schedules,
// //     String dayName,
// //     int weekNumber,
// //     String date,
// //   ) {
// //     final regularSchedules = getScheduleForDayAndWeek(
// //       schedules,
// //       dayName,
// //       weekNumber,
// //     );
// //     final announcements = getAnnouncementsForDate(date, schedules);

// //     final allSchedules = [...regularSchedules, ...announcements];
// //     allSchedules.sort((a, b) {
// //       final timeA = a.startLessonTime ?? '';
// //       final timeB = b.startLessonTime ?? '';
// //       return timeA.compareTo(timeB);
// //     });

// //     return allSchedules;
// //   }

// //   List<Schedule> getExamsForDate(String date, List<Schedule>? exams) {
// //     if (exams == null) return [];

// //     return exams.where((exam) {
// //       final examDate = exam.dateLesson;
// //       return examDate == date;
// //     }).toList();
// //   }

// //   List<Schedule> getAllSchedulesForZaochDay(
// //     List<Schedule>? exams,
// //     String date,
// //   ) {
// //     final examsForDate = getExamsForDate(date, exams);

// //     examsForDate.sort((a, b) {
// //       final timeA = a.startLessonTime ?? '';
// //       final timeB = b.startLessonTime ?? '';
// //       return timeA.compareTo(timeB);
// //     });

// //     return examsForDate;
// //   }

// //   List<Schedule> getAllSchedulesForDayAuto(
// //     Map<String, List<Schedule>>? schedules,
// //     List<Schedule>? exams,
// //     String dayName,
// //     int weekNumber,
// //     String date,
// //   ) {
// //     if (isZaochOrDist) {
// //       return getAllSchedulesForZaochDay(exams, date);
// //     } else {
// //       return getAllSchedulesForDay(schedules, dayName, weekNumber, date);
// //     }
// //   }

// //   String getEmployeeName(Employee? employee) {
// //     if (employee == null) return '';

// //     final firstName = employee.firstName ?? '';
// //     final lastName = employee.lastName ?? '';
// //     final middleName = employee.middleName ?? '';

// //     if (firstName.isEmpty) return lastName;

// //     final middleInitial = middleName.isNotEmpty ? '${middleName[0]}.' : '';
// //     return '$lastName ${firstName[0]}.$middleInitial';
// //   }

// //   String getEmployeeNameFromList(List<Employee>? employees) {
// //     if (employees == null || employees.isEmpty) return '';
// //     return getEmployeeName(employees.first);
// //   }

// //   String getTeacherImage(List<Employee>? employees) {
// //     if (employees == null || employees.isEmpty) {
// //       return '';
// //     }
// //     return employees.first.photoLink ?? '';
// //   }

// //   String getSubjectName(Schedule schedule) {
// //     if (schedule.subject != null && schedule.subject!.isNotEmpty) {
// //       return schedule.subject!;
// //     }

// //     if (schedule.subjectFullName != null &&
// //         schedule.subjectFullName!.isNotEmpty) {
// //       return schedule.subjectFullName!;
// //     }

// //     return schedule.note ?? 'Занятие';
// //   }

// //   String getLessonType(Schedule schedule) {
// //     if (isZaochOrDist) {
// //       return schedule.lessonTypeAbbrev ?? 'Экзамен';
// //     }
// //     return schedule.lessonTypeAbbrev ?? 'Занятие';
// //   }

// //   bool isAnnouncement(Schedule schedule) {
// //     return schedule.announcement == true;
// //   }

// //   String getAnnouncementDate(Schedule schedule) {
// //     return schedule.startLessonDate ?? '';
// //   }

// //   bool hasData() {
// //     return _mainGroup != null;
// //   }

// //   bool hasMainSchedules(){
// //     if (_mainGroup == null) return false;

    
// //       return _mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty;
  
// //   }

// //   bool hasSchedules() {
// //     if (_mainGroup == null) return false;

// //     if (isZaochOrDist) {
// //       return _mainGroup!.exams != null && _mainGroup!.exams!.isNotEmpty;
// //     } else {
// //       return _mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty;
// //     }
// //   }

// //   bool isSemesterEnded() {
// //     final now = DateTime.now();
// //     if (isZaochOrDist) {
// //       final endExamsDateStr = _mainGroup?.endExamsDate;
// //       if (endExamsDateStr != null && endExamsDateStr.isNotEmpty) {
// //         try {
// //           final endExamsDate = parseDate(endExamsDateStr);
// //           return now.isBefore(endExamsDate);
// //           // now.isAtSameMomentAs(endExamsDate);
// //         } catch (e) {
// //           return true;
// //         }
// //       }
// //     } else {
// //       final endDateStr = _mainGroup?.endDate;
// //       if (endDateStr != null && endDateStr.isNotEmpty) {
// //         try {
// //           final endDate = parseDate(endDateStr);
// //           return now.isAfter(endDate);

// //           // || now.isAtSameMomentAs(endDate);
// //         } catch (e) {
// //           return true;
// //         }
// //       }
// //     }
// //     return true;
// //   }

// //   //   bool isDateValid(DateTime date, String endDateStr) {
// //   //   try {
// //   //     final endDate = parseDate(endDateStr);
// //   //     return date.isBefore(endDate)
// //   //     || date.isAtSameMomentAs(endDate);
// //   //   } catch (e) {
// //   //     return true;
// //   //   }
// //   // }

// //   // bool hasSemesterStarted() {
// //   //   final now = DateTime.now();

// //   //   if (isZaochOrDist) {
// //   //     final startExamsDateStr = _mainGroup?.startExamsDate;
// //   //     if (startExamsDateStr != null && startExamsDateStr.isNotEmpty) {
// //   //       try {
// //   //         final startExamsDate = parseDate(startExamsDateStr);
// //   //         return now.isAfter(startExamsDate) ||
// //   //             now.isAtSameMomentAs(startExamsDate);
// //   //       } catch (e) {
// //   //         return true;
// //   //       }
// //   //     }
// //   //   } else {
// //   //     final startDateStr = _mainGroup?.startDate;
// //   //     if (startDateStr != null && startDateStr.isNotEmpty) {
// //   //       try {
// //   //         final startDate = parseDate(startDateStr);
// //   //         return now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
// //   //       } catch (e) {
// //   //         return true;
// //   //       }
// //   //     }
// //   //   }

// //   //   return true;
// //   // }
// //   bool hasSemesterStarted() {
// //     final now = DateTime.now();

// //     if (!isZaochOrDist) {
// //       final startDateStr = _mainGroup?.startDate;
// //       if (startDateStr != null && startDateStr.isNotEmpty) {
// //         try {
// //           final startDate = parseDate(startDateStr);
// //           return now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
// //         } catch (e) {
// //           return true;
// //         }
// //       }
// //     }

// //     return true;
// //   }

// //   String getDayNameFromDate(String dateStr) {
// //     try {
// //       final date = DateFormat('dd.MM.yyyy').parse(dateStr);
// //       switch (date.weekday) {
// //         case 1:
// //           return 'Понедельник';
// //         case 2:
// //           return 'Вторник';
// //         case 3:
// //           return 'Среда';
// //         case 4:
// //           return 'Четверг';
// //         case 5:
// //           return 'Пятница';
// //         case 6:
// //           return 'Суббота';
// //         case 7:
// //           return 'Воскресенье';
// //         default:
// //           return 'День';
// //       }
// //     } catch (e) {
// //       return 'День';
// //     }
// //   }
// // }


















// // import 'package:bsuir/domain/entity/employee.dart';
// // import 'package:bsuir/domain/entity/main_group.dart';
// // import 'package:bsuir/domain/entity/schedule.dart';
// // import 'package:bsuir/domain/api_client/api_client.dart';
// // import 'package:bsuir/services/favorite_service.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // enum ScheduleViewType { schedule, daily, exams }
// // enum LessonType { lecture, practice, lab, exam, consultation, other }

// // class MainGroupModel extends ChangeNotifier {
// //   final ApiClient _apiClient = ApiClient();
// //   final int groupNumber;
  
// //   MainGroup? _mainGroup;
// //   String? _errorMessage;
// //   bool _isFavorite = false;

// //   MainGroupModel(this.groupNumber);

// //   // Геттеры
// //   MainGroup? get mainGroup => _mainGroup;
// //   String? get errorMessage => _errorMessage;
// //   bool get isFavorite => _isFavorite;
// //   bool get isZaochOrDist => _mainGroup?.isZaochOrDist == true;
  
// //   // Загрузка данных
// //   Future<void> loadMainGroup() async {
// //     try {
// //       _errorMessage = null;
// //       _mainGroup = await _apiClient.getScheduleResponse(groupNumber);
// //       _isFavorite = await FavoriteService.isFavorite(groupNumber.toString());
// //       notifyListeners();
// //     } catch (e) {
// //       _errorMessage = 'Ошибка загрузки расписания';
// //       notifyListeners();
// //       rethrow;
// //     }
// //   }

// //   // Избранное
// //   Future<void> toggleFavorite() async {
// //     await FavoriteService.toggleFavorite(groupNumber.toString());
// //     _isFavorite = !_isFavorite;
// //     notifyListeners();
// //   }

// //   // Проверки данных
// //   bool hasData() => _mainGroup != null;
  
// //   bool hasSchedules() {
// //     if (_mainGroup == null) return false;
// //     return isZaochOrDist 
// //       ? _mainGroup!.exams?.isNotEmpty ?? false
// //       : _mainGroup!.schedules?.isNotEmpty ?? false;
// //   }

// //   // Работа с датами
// //   DateTime parseDate(String dateStr) => DateFormat('dd.MM.yyyy').parse(dateStr);
  
// //   bool isDateValid(DateTime date, String? endDateStr) {
// //     if (endDateStr == null || endDateStr.isEmpty) return true;
    
// //     try {
// //       final endDate = parseDate(endDateStr);
// //       return date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
// //     } catch (e) {
// //       return true;
// //     }
// //   }

// //   bool hasSemesterStarted() {
// //     final now = DateTime.now();
// //     final startDateStr = _mainGroup?.startDate;
    
// //     if (startDateStr == null || startDateStr.isEmpty) return true;
    
// //     try {
// //       final startDate = parseDate(startDateStr);
// //       return now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
// //     } catch (e) {
// //       return true;
// //     }
// //   }

// //   bool isSemesterEnded() {
// //     final now = DateTime.now();
// //     final endDateStr = isZaochOrDist ? _mainGroup?.endExamsDate : _mainGroup?.endDate;
    
// //     if (endDateStr == null || endDateStr.isEmpty) return false;
    
// //     try {
// //       final endDate = parseDate(endDateStr);
// //       return now.isAfter(endDate);
// //     } catch (e) {
// //       return false;
// //     }
// //   }

// //   // Получение дат для отображения
// //   DateTime getStartDisplayDate() {
// //     final now = DateTime.now();
// //     DateTime baseStart = now;

// //     if (isZaochOrDist) {
// //       final startExamsDateStr = _mainGroup?.startExamsDate;
// //       if (startExamsDateStr != null && startExamsDateStr.isNotEmpty) {
// //         baseStart = parseDate(startExamsDateStr);
// //       }
// //     } else {
// //       final startDateStr = _mainGroup?.startDate;
// //       if (startDateStr != null && startDateStr.isNotEmpty) {
// //         baseStart = parseDate(startDateStr);
// //       }
// //     }

// //     return baseStart.isAfter(now) ? baseStart : now;
// //   }


// // String getEmployeeName(Employee? employee) {
// //     if (employee == null) return '';

// //     final firstName = employee.firstName ?? '';
// //     final lastName = employee.lastName ?? '';
// //     final middleName = employee.middleName ?? '';

// //     // if (firstName.isEmpty) return lastName;

// //     // // final middleInitial = middleName.isNotEmpty ? '${middleName[0]}.' : '';

// //     return '$lastName $firstName $middleName';
// //   }
// //     String getEmployeeNameFromList(List<Employee>? employees) {
// //     if (employees == null || employees.isEmpty) return '';
// //     return getEmployeeName(employees.first);
// //   }

// //   // Вспомогательные методы для дней недели
// //   String getRussianDayName(DateTime date) {
// //     const days = [
// //       'Понедельник', 'Вторник', 'Среда', 'Четверг', 
// //       'Пятница', 'Суббота', 'Воскресенье'
// //     ];
// //     return days[date.weekday - 1];
// //   }

// //   int getWeekdayNumber(String dayName) {
// //     const days = {
// //       'Понедельник': 1, 'Вторник': 2, 'Среда': 3,
// //       'Четверг': 4, 'Пятница': 5, 'Суббота': 6, 'Воскресенье': 7
// //     };
// //     return days[dayName] ?? 1;
// //   }

// //   String getDayNameFromDate(String dateStr) {
// //     try {
// //       final date = parseDate(dateStr);
// //       return getRussianDayName(date);
// //     } catch (e) {
// //       return 'День';
// //     }
// //   }

// //   // Методы для вычисления дат (новые методы)
// //   DateTime _getMondayOfCurrentWeek() {
// //     final now = DateTime.now();
// //     return now.subtract(Duration(days: now.weekday - 1));
// //   }

// //   DateTime _getBaseDateForWeek(int weekOffset) {
// //     final startDate = getStartDisplayDate();
// //     //final semesterStarted = hasSemesterStarted();
    
// //     // Если семестр начался, weekOffset = 0 - текущая неделя
// //     // Если не начался, weekOffset = 0 - неделя начала
// //     final mondayOfReferenceWeek = startDate.subtract(
// //       Duration(days: startDate.weekday - 1),
// //     );
    
// //     return mondayOfReferenceWeek.add(Duration(days: weekOffset * 7));
// //   }

// //   /// Получает дату для конкретного дня недели для ТЕКУЩЕЙ недели
// //   String getDateForCurrentWeekDay(String dayName, String? endDate) {
// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();

// //     final baseWeekday = mondayOfCurrentWeek.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = mondayOfCurrentWeek.add(Duration(days: dayDifference));
// //     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

// //     if (endDate != null && !isDateValid(targetDate, endDate)) {
// //       return '$dateString (семестр окончен)';
// //     }

// //     return dateString;
// //   }

// //   /// Получает дату для конкретного дня недели для БУДУЩИХ недель
// //   String getDateForFutureWeekDay(
// //     String dayName,
// //     int weekOffset,
// //     String? endDate,
// //   ) {
// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final baseDate = _getBaseDateForWeek(weekOffset);

// //     final baseWeekday = baseDate.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = baseDate.add(Duration(days: dayDifference));
// //     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

// //     // if (endDate != null && !isDateValid(targetDate, endDate)) {
// //     //   return '$dateString (семестр окончен)';
// //     // }

// //     return dateString;
// //   }

// //   /// Проверяет, является ли день валидным для текущей недели
// //   bool isDayValidForCurrentWeek(String dayName, String? endDate) {
// //     if (endDate == null) return true;

// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();

// //     final baseWeekday = mondayOfCurrentWeek.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = mondayOfCurrentWeek.add(Duration(days: dayDifference));
// //     return isDateValid(targetDate, endDate);
// //   }

// //   /// Проверяет, является ли день валидным для будущих недель
// //   bool isDayValidForFutureWeek(
// //     String dayName,
// //     int weekOffset,
// //     String? endDate,
// //   ) {
// //     if (endDate == null) return true;

// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final baseDate = _getBaseDateForWeek(weekOffset);

// //     final baseWeekday = baseDate.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = baseDate.add(Duration(days: dayDifference));
// //     return isDateValid(targetDate, endDate);
// //   }

// //   /// Получает номер недели для отображения для ТЕКУЩЕЙ недели
// //   int getWeekNumberForCurrentWeek(String? startDate) {
// //     if (startDate == null || startDate.isEmpty) return 1;

// //     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();
// //     final startDateTime = parseDate(startDate);

// //     final difference = mondayOfCurrentWeek.difference(startDateTime).inDays;
// //     final weekNumber = (difference ~/ 7) + 1;

// //     return weekNumber > 0 ? ((weekNumber - 1) % 4) + 1 : 1;
// //   }

// //   /// Получает номер недели для отображения для БУДУЩИХ недель
// //   int getWeekNumberForFutureWeek(int weekOffset, String? startDate) {
// //     if (startDate == null || startDate.isEmpty) return 1;

// //     final baseDate = _getBaseDateForWeek(weekOffset);
// //     final startDateTime = parseDate(startDate);

// //     final difference = baseDate.difference(startDateTime).inDays;
// //     final weekNumber = (difference ~/ 7) + 1;

// //     return weekNumber > 0 ? ((weekNumber - 1) % 4) + 1 : 1;
// //   }

// //   // Работа с расписанием
// //   List<Schedule> getScheduleForDayAndWeek(
// //     Map<String, List<Schedule>>? schedules,
// //     String dayName,
// //     int weekNumber,
// //   ) {
// //     if (schedules == null) return [];
    
// //     return (schedules[dayName] ?? []).where((schedule) {
// //       if (schedule.announcement == true) return false;
// //       final weekNumbers = schedule.weekNumber;
// //       return weekNumbers != null && weekNumbers.contains(weekNumber);
// //     }).toList();
// //   }

// //   List<Schedule> getAllSchedulesForDayAuto(
// //     Map<String, List<Schedule>>? schedules,
// //     List<Schedule>? exams,
// //     String dayName,
// //     int weekNumber,
// //     String date,
// //   ) {
// //     if (isZaochOrDist) {
// //       return getExamsForDate(date, exams);
// //     } else {
// //       final regularSchedules = getScheduleForDayAndWeek(schedules, dayName, weekNumber);
// //       final announcements = getAnnouncementsForDate(date, schedules);
// //       return _mergeAndSortSchedules(regularSchedules, announcements);
// //     }
// //   }

// //   List<Schedule> getExamsForDate(String date, List<Schedule>? exams) {
// //     return (exams ?? []).where((exam) => exam.dateLesson == date).toList();
// //   }

// //   List<Schedule> getAnnouncementsForDate(
// //     String date,
// //     Map<String, List<Schedule>>? schedules,
// //   ) {
// //     if (schedules == null) return [];
    
// //     final announcements = <Schedule>[];
// //     for (final daySchedules in schedules.values) {
// //       for (final schedule in daySchedules) {
// //         if (schedule.announcement == true && schedule.startLessonDate == date) {
// //           announcements.add(schedule);
// //         }
// //       }
// //     }
// //     return announcements;
// //   }

// //   // Вспомогательные методы для отображения
// //   String getTeacherImage(List<Employee>? employees) {
// //     return employees?.firstOrNull?.photoLink ?? '';
// //   }

// //   String getSubjectName(Schedule schedule) {
// //     return schedule.subject ?? 
// //            schedule.subjectFullName ?? 
// //            schedule.note ?? 
// //            'Занятие';
// //   }

// //   LessonType getLessonTypeEnum(Schedule schedule) {
// //     final abbrev = schedule.lessonTypeAbbrev?.toLowerCase() ?? '';
    
// //     if (abbrev.contains('экз')) return LessonType.exam;
// //     if (abbrev.contains('конс')) return LessonType.consultation;
// //     if (abbrev.contains('лк')) return LessonType.lecture;
// //     if (abbrev.contains('пз')) return LessonType.practice;
// //     if (abbrev.contains('лр')) return LessonType.lab;
    
// //     return LessonType.other;
// //   }

// //   String getLessonTypeDisplay(Schedule schedule) {
// //     return schedule.lessonTypeAbbrev ?? (isZaochOrDist ? 'Экзамен' : 'Занятие');
// //   }

// //   bool isAnnouncement(Schedule schedule) => schedule.announcement == true;

// //   // Приватные вспомогательные методы
// //   List<Schedule> _mergeAndSortSchedules(
// //     List<Schedule> regular, 
// //     List<Schedule> announcements
// //   ) {
// //     final allSchedules = [...regular, ...announcements];
// //     allSchedules.sort((a, b) {
// //       final timeA = a.startLessonTime ?? '';
// //       final timeB = b.startLessonTime ?? '';
// //       return timeA.compareTo(timeB);
// //     });
// //     return allSchedules;
// //   }
// // }


























// // import 'package:bsuir/domain/entity/employee.dart';
// // import 'package:bsuir/domain/entity/main_group.dart';
// // import 'package:bsuir/domain/entity/schedule.dart';
// // import 'package:bsuir/domain/api_client/api_client.dart';
// // import 'package:bsuir/services/favorite_service.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // enum ScheduleViewType { schedule, daily, exams }
// // enum LessonType { lecture, practice, lab, exam, consultation, other }

// // class MainGroupModel extends ChangeNotifier {
// //   final ApiClient _apiClient = ApiClient();
// //   final int groupNumber;
  
// //   MainGroup? _mainGroup;
// //   String? _errorMessage;
// //   bool _isFavorite = false;
// //   int? _currentAbsoluteWeek; // Абсолютный номер недели от API
// //   bool _isWeekLoading = false;

// //   MainGroupModel(this.groupNumber);

// //   // Геттеры
// //   MainGroup? get mainGroup => _mainGroup;
// //   String? get errorMessage => _errorMessage;
// //   bool get isFavorite => _isFavorite;
// //   bool get isZaochOrDist => _mainGroup?.isZaochOrDist == true;
  
// //   // Загрузка данных
// //   Future<void> loadMainGroup() async {
// //     try {
// //       _errorMessage = null;
// //       _isWeekLoading = true;
      
// //       // Загружаем текущую неделю ПАРАЛЛЕЛЬНО с расписанием
// //       final weekFuture = _apiClient.getCurrentWeek();
// //       final scheduleFuture = _apiClient.getScheduleResponse(groupNumber);
      
// //       // Ждем оба запроса
// //       final results = await Future.wait([weekFuture, scheduleFuture]);
      
// //       _currentAbsoluteWeek = results[0] as int;
// //       _mainGroup = results[1] as MainGroup;
      
// //       _isFavorite = await FavoriteService.isFavorite(groupNumber.toString());
// //       notifyListeners();
      
// //     } catch (e) {
// //       _errorMessage = 'Ошибка загрузки расписания';
// //       notifyListeners();
// //       rethrow;
// //     } finally {
// //       _isWeekLoading = false;
// //     }
// //   }

// //   // Избранное
// //   Future<void> toggleFavorite() async {
// //     await FavoriteService.toggleFavorite(groupNumber.toString());
// //     _isFavorite = !_isFavorite;
// //     notifyListeners();
// //   }

// //   // Проверки данных
// //   bool hasData() => _mainGroup != null;
  
// //   bool hasSchedules() {
// //     if (_mainGroup == null) return false;
// //     return isZaochOrDist 
// //       ? _mainGroup!.exams?.isNotEmpty ?? false
// //       : _mainGroup!.schedules?.isNotEmpty ?? false;
// //   }

// //   // Работа с датами
// //   DateTime parseDate(String dateStr) => DateFormat('dd.MM.yyyy').parse(dateStr);
  
// //   bool isDateValid(DateTime date, String? endDateStr) {
// //     if (endDateStr == null || endDateStr.isEmpty) return true;
    
// //     try {
// //       final endDate = parseDate(endDateStr);
// //       return date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
// //     } catch (e) {
// //       return true;
// //     }
// //   }

// //   bool hasSemesterStarted() {
// //     final now = DateTime.now();
// //     final startDateStr = _mainGroup?.startDate;
    
// //     if (startDateStr == null || startDateStr.isEmpty) return true;
    
// //     try {
// //       final startDate = parseDate(startDateStr);
// //       return now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
// //     } catch (e) {
// //       return true;
// //     }
// //   }

// //   bool isSemesterEnded() {
// //     final now = DateTime.now();
// //     final endDateStr = isZaochOrDist ? _mainGroup?.endExamsDate : _mainGroup?.endDate;
    
// //     if (endDateStr == null || endDateStr.isEmpty) return false;
    
// //     try {
// //       final endDate = parseDate(endDateStr);
// //       return now.isAfter(endDate);
// //     } catch (e) {
// //       return false;
// //     }
// //   }

// //   // Получение дат для отображения
// //   DateTime getStartDisplayDate() {
// //     final now = DateTime.now();
    
// //     if (isZaochOrDist) {
// //       final startExamsDateStr = _mainGroup?.startExamsDate;
// //       if (startExamsDateStr != null && startExamsDateStr.isNotEmpty) {
// //         final baseStart = parseDate(startExamsDateStr);
// //         return baseStart.isAfter(now) ? baseStart : now;
// //       }
// //       return now;
// //     } else {
// //       return now; // Для очников всегда показываем с сегодня
// //     }
// //   }

// //   // Вспомогательные методы для дней недели
// //   String getRussianDayName(DateTime date) {
// //     const days = [
// //       'Понедельник', 'Вторник', 'Среда', 'Четверг', 
// //       'Пятница', 'Суббота', 'Воскресенье'
// //     ];
// //     return days[date.weekday - 1];
// //   }

// //   int getWeekdayNumber(String dayName) {
// //     const days = {
// //       'Понедельник': 1, 'Вторник': 2, 'Среда': 3,
// //       'Четверг': 4, 'Пятница': 5, 'Суббота': 6, 'Воскресенье': 7
// //     };
// //     return days[dayName] ?? 1;
// //   }

// //   String getDayNameFromDate(String dateStr) {
// //     try {
// //       final date = parseDate(dateStr);
// //       return getRussianDayName(date);
// //     } catch (e) {
// //       return 'День';
// //     }
// //   }

// //   // НОВЫЕ МЕТОДЫ с использованием API текущей недели
// //   /// Получает номер недели для отображения (1-4) на основе абсолютной недели от API
// //   int getDisplayWeekNumber({int? weekOffset = 0}) {
// //     if (_currentAbsoluteWeek == null) return 1;
    
// //     // Абсолютная неделя от API + смещение
// //     final absoluteWeek = _currentAbsoluteWeek! + weekOffset!;
    
// //     // Конвертируем в отображаемую неделю (1-4)
// //     return ((absoluteWeek - 1) % 4) + 1;
// //   }

// //   /// Получает абсолютный номер недели с учетом смещения
// //   int getAbsoluteWeekNumber({int? weekOffset = 0}) {
// //     if (_currentAbsoluteWeek == null) return 1;
// //     return _currentAbsoluteWeek! + weekOffset!;
// //   }

// //   /// Получает понедельник для недели с учетом смещения
// //   DateTime _getMondayForWeek(int weekOffset) {
// //     final now = DateTime.now();
// //     final mondayOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1));
    
// //     return mondayOfCurrentWeek.add(Duration(days: weekOffset * 7));
// //   }

// //   /// Получает дату для конкретного дня недели с учетом смещения недели
// //   String getDateForWeekDay(
// //     String dayName,
// //     int weekOffset,  // 0 - текущая неделя, 1 - следующая и т.д.
// //     String? endDate,
// //   ) {
// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final mondayOfWeek = _getMondayForWeek(weekOffset);

// //     final baseWeekday = mondayOfWeek.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = mondayOfWeek.add(Duration(days: dayDifference));
// //     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

// //     if (endDate != null && !isDateValid(targetDate, endDate)) {
// //       return '$dateString (семестр окончен)';
// //     }

// //     return dateString;
// //   }

// //   /// Проверяет, является ли день валидным для недели
// //   bool isDayValidForWeek(
// //     String dayName,
// //     int weekOffset,
// //     String? endDate,
// //   ) {
// //     if (endDate == null) return true;

// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final mondayOfWeek = _getMondayForWeek(weekOffset);

// //     final baseWeekday = mondayOfWeek.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = mondayOfWeek.add(Duration(days: dayDifference));
// //     return isDateValid(targetDate, endDate);
// //   }

// //   // УПРОЩЕННЫЕ ВЕРСИИ СТАРЫХ МЕТОДОВ
// //   String getDateForCurrentWeekDay(String dayName, String? endDate) {
// //     return getDateForWeekDay(dayName, 0, endDate);
// //   }

// //   String getDateForFutureWeekDay(String dayName, int weekOffset, String? endDate) {
// //     return getDateForWeekDay(dayName, weekOffset, endDate);
// //   }

// //   bool isDayValidForCurrentWeek(String dayName, String? endDate) {
// //     return isDayValidForWeek(dayName, 0, endDate);
// //   }

// //   bool isDayValidForFutureWeek(String dayName, int weekOffset, String? endDate) {
// //     return isDayValidForWeek(dayName, weekOffset, endDate);
// //   }

// //   int getWeekNumberForCurrentWeek(String? startDate) {
// //     return getDisplayWeekNumber(weekOffset: 0);
// //   }

// //   int getWeekNumberForFutureWeek(int weekOffset, String? startDate) {
// //     return getDisplayWeekNumber(weekOffset: weekOffset);
// //   }

// //   // Работа с расписанием
// //   List<Schedule> getScheduleForDayAndWeek(
// //     Map<String, List<Schedule>>? schedules,
// //     String dayName,
// //     int weekNumber,  // Отображаемая неделя (1-4)
// //   ) {
// //     if (schedules == null) return [];
    
// //     return (schedules[dayName] ?? []).where((schedule) {
// //       if (schedule.announcement == true) return false;
// //       final weekNumbers = schedule.weekNumber;
// //       return weekNumbers != null && weekNumbers.contains(weekNumber);
// //     }).toList();
// //   }

// //   List<Schedule> getAllSchedulesForDayAuto(
// //     Map<String, List<Schedule>>? schedules,
// //     List<Schedule>? exams,
// //     String dayName,
// //     int weekNumber,  // Отображаемая неделя (1-4)
// //     String date,
// //   ) {
// //     if (isZaochOrDist) {
// //       return getExamsForDate(date, exams);
// //     } else {
// //       final regularSchedules = getScheduleForDayAndWeek(schedules, dayName, weekNumber);
// //       final announcements = getAnnouncementsForDate(date, schedules);
// //       return _mergeAndSortSchedules(regularSchedules, announcements);
// //     }
// //   }

// //   List<Schedule> getExamsForDate(String date, List<Schedule>? exams) {
// //     return (exams ?? []).where((exam) => exam.dateLesson == date).toList();
// //   }

// //   List<Schedule> getAnnouncementsForDate(
// //     String date,
// //     Map<String, List<Schedule>>? schedules,
// //   ) {
// //     if (schedules == null) return [];
    
// //     final announcements = <Schedule>[];
// //     for (final daySchedules in schedules.values) {
// //       for (final schedule in daySchedules) {
// //         if (schedule.announcement == true && schedule.startLessonDate == date) {
// //           announcements.add(schedule);
// //         }
// //       }
// //     }
// //     announcements.sort(_sortByTime);
// //     return announcements;
// //   }

// //   // Вспомогательные методы для отображения


// // String getEmployeeName(Employee? employee) {
// //     if (employee == null) return '';

// //     final firstName = employee.firstName ?? '';
// //     final lastName = employee.lastName ?? '';
// //     final middleName = employee.middleName ?? '';


// //     return '$lastName $firstName $middleName';
// //   }
// //     String getEmployeeNameFromList(List<Employee>? employees) {
// //     if (employees == null || employees.isEmpty) return '';
// //     return getEmployeeName(employees.first);
// //   }

// //   String getTeacherImage(List<Employee>? employees) {
// //     return employees?.firstOrNull?.photoLink ?? '';
// //   }

// //   String getSubjectName(Schedule schedule) {
// //     return schedule.subject ?? 
// //            schedule.subjectFullName ?? 
// //            schedule.note ?? 
// //            'Занятие';
// //   }

// //   LessonType getLessonTypeEnum(Schedule schedule) {
// //     final abbrev = schedule.lessonTypeAbbrev?.toLowerCase() ?? '';
    
// //     if (abbrev.contains('экз')) return LessonType.exam;
// //     if (abbrev.contains('конс')) return LessonType.consultation;
// //     if (abbrev.contains('лк')) return LessonType.lecture;
// //     if (abbrev.contains('пз')) return LessonType.practice;
// //     if (abbrev.contains('лр')) return LessonType.lab;
    
// //     return LessonType.other;
// //   }

// //   String getLessonTypeDisplay(Schedule schedule) {
// //     return schedule.lessonTypeAbbrev ?? (isZaochOrDist ? 'Экзамен' : 'Занятие');
// //   }

// //   bool isAnnouncement(Schedule schedule) => schedule.announcement == true;

// //   // Приватные вспомогательные методы
// //   List<Schedule> _mergeAndSortSchedules(
// //     List<Schedule> regular, 
// //     List<Schedule> announcements
// //   ) {
// //     final allSchedules = [...regular, ...announcements];
// //     allSchedules.sort(_sortByTime);
// //     return allSchedules;
// //   }

// //   int _sortByTime(Schedule a, Schedule b) {
// //     final timeA = a.startLessonTime ?? '';
// //     final timeB = b.startLessonTime ?? '';
// //     return timeA.compareTo(timeB);
// //   }
// // }






// import 'package:bsuir/domain/entity/employee.dart';
// import 'package:bsuir/domain/entity/main_group.dart';
// import 'package:bsuir/domain/entity/schedule.dart';
// import 'package:bsuir/domain/api_client/api_client.dart';
// import 'package:bsuir/services/favorite_service.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// enum ScheduleViewType {schedule, daily, exams}
// enum LessonType { lecture, practice, lab, exam, consultation, other }

// class MainGroupModel extends ChangeNotifier {
//   final ApiClient _apiClient = ApiClient();
//   final int groupNumber;
  
//   MainGroup? _mainGroup;
//   String? _errorMessage;
//   bool _isFavorite = false;
//   int? _currentAcademicWeek;
//   final VoidCallback? onFavoriteChanged;

//   MainGroupModel(this.groupNumber, {this.onFavoriteChanged});

//   // Геттеры
//   MainGroup? get mainGroup => _mainGroup;
//   String? get errorMessage => _errorMessage;
//   bool get isFavorite => _isFavorite;
//   bool get isZaochOrDist => _mainGroup?.isZaochOrDist == true;
  
//   // Загрузка данных
//   Future<void> loadMainGroup() async {
//     try {
//       _errorMessage = null;
//       _currentAcademicWeek = await _apiClient.getCurrentWeek();
//       final group = await _apiClient.getScheduleResponse(groupNumber);
//       _mainGroup = group;
//       _isFavorite = await FavoriteService.isFavorite(groupNumber.toString());
//       notifyListeners();
//     } catch (e) {
//       _errorMessage = 'Ошибка загрузки расписания: ${e.toString()}';
//       notifyListeners();
//       rethrow;
//     }
//   }

//   // Избранное
//   Future<void> toggleFavorite() async {
//     await FavoriteService.toggleFavorite(groupNumber.toString());
//     _isFavorite = !_isFavorite;
//     notifyListeners();
//     onFavoriteChanged?.call();
//   }

//   // Проверки данных
//   bool hasData() => _mainGroup != null;
  
//   bool hasSchedules() {
//     if (_mainGroup == null) return false;
//     return (_mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty) ||
//            (_mainGroup!.exams != null && _mainGroup!.exams!.isNotEmpty);
//   }

//   bool hasMainSchedules() {
//     if (_mainGroup == null) return false;
//     return _mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty;
//   }

//   // ========== ОСНОВНЫЕ МЕТОДЫ ДЛЯ ВЫЧИСЛЕНИЯ НЕДЕЛЬ ==========

//   DateTime _getMonday(DateTime date) {
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
//     DateTime monday = now.subtract(Duration(days: now.weekday - 1));
//     return monday;
//   }

//   DateTime _getMondayForWeek(int weekOffset) {
//     final now = DateTime.now();
//     final baseOffset = getBaseWeekOffset();

//     final baseMonday = _getMonday(now);

//     return baseMonday.add(
//       Duration(days: (baseOffset + weekOffset) * 7),
//     );
//   }

//   DateTime getBaseDateForWeek(int weekOffset) {
//     return _getMondayForWeek(weekOffset);
//   }

//   // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ ДАТ ==========

//   String getDateForCurrentWeekDay(String dayName, String? endDate) {
//     return _getDateForWeekDay(0, dayName, endDate);
//   }

//   String getDateForFutureWeekDay(
//     String dayName,
//     int weekOffset,
//     String? endDate,
//   ) {
//     return _getDateForWeekDay(weekOffset, dayName, endDate);
//   }

//   String _getDateForWeekDay(int weekOffset, String dayName, String? endDate) {
//     final monday = _getMondayForWeek(weekOffset);
    
//     final targetWeekday = getWeekdayNumber(dayName);
//     int dayDifference = targetWeekday - 1;
//     final targetDate = monday.add(Duration(days: dayDifference));
    
//     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

//     if (endDate != null && !isDateValid(targetDate, endDate)) {
//       return '$dateString (семестр окончен)';
//     }

//     return dateString;
//   }

//   // ========== ОСНОВНОЙ ИЗМЕНЕННЫЙ МЕТОД ДЛЯ ФИЛЬТРАЦИИ РАСПИСАНИЯ ==========

//   List<Schedule> getFilteredSchedulesForDay(
//     List<Schedule> daySchedules,
//     String targetDate,
//   ) {
//     return daySchedules.where((schedule) {
//       if (schedule.announcement == true) {
//         return schedule.startLessonDate == targetDate;
//       }
      
//       final startDate = schedule.startLessonDate;
//       final endDate = schedule.endLessonDate;
      
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
//           return true;
//         }
//       }
      
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
    
//     if (endDate != null) {
//       return isDateValid(targetDate, endDate);
//     }
    
//     return true;
//   }

//   bool shouldShowScheduleForDate(DateTime date) {
//     final startDateStr = _mainGroup?.startDate;
//     final endDateStr = _mainGroup?.endDate;
    
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
//         if (date.isBefore(startDate)) {
//           return false;
//         }
//       } catch (e) {}
//     }
    
//     if (endDateStr != null && endDateStr.isNotEmpty) {
//       try {
//         final endDate = parseDate(endDateStr);
//         if (date.isAfter(endDate)) {
//           return false;
//         }
//       } catch (e) {}
//     }
    
//     return true;
//   }

//   // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ НОМЕРОВ НЕДЕЛЬ ==========

//   int getWeekNumberForCurrentWeek(String? startDate) {
//     if (_currentAcademicWeek == null) return 1;

//     final baseOffset = getBaseWeekOffset();
//     return ((_currentAcademicWeek! - 1 + baseOffset) % 4) + 1;
//   }

//   int getWeekNumberForFutureWeek(int weekOffset, String? startDate) {
//     if (_currentAcademicWeek == null) return 1;

//     final baseOffset = getBaseWeekOffset();
//     return ((_currentAcademicWeek! - 1 + baseOffset + weekOffset) % 4) + 1;
//   }

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
//     String targetDate,
//   ) {
//     if (schedules == null) return [];

//     final daySchedules = schedules[dayName] ?? [];

//     final filteredByWeekNumber = daySchedules.where((schedule) {
//       if (schedule.announcement == true) {
//         return false;
//       }

//       final weekNumbers = schedule.weekNumber;
//       if (weekNumbers == null || weekNumbers.isEmpty) return false;
//       return weekNumbers.contains(weekNumber);
//     }).toList();

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

//   // ОСНОВНОЙ МЕТОД ДЛЯ ПОЛУЧЕНИЯ РАСПИСАНИЯ (только обычные занятия + объявления)
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
//     } catch (e) {}

//     // Получаем регулярные занятия с фильтрацией по неделям и датам
//     final regularSchedules = getScheduleForDayAndWeek(
//       schedules,
//       dayName,
//       weekNumber,
//       date,
//     );
    
//     // Получаем объявления для этой даты
//     final announcements = getAnnouncementsForDate(date, schedules);

//     // ФИЛЬТРУЕМ ЭКЗАМЕНЫ И КОНСУЛЬТАЦИИ (не показываем их в обычном расписании)
//     final filteredRegularSchedules = regularSchedules.where((schedule) {
//       final lessonType = schedule.lessonTypeAbbrev?.toLowerCase() ?? '';
//       final isExam = schedule.lessonTypeAbbrev == 'экз' || 
//                     lessonType.contains('экз') ||
//                     lessonType.contains('exam');
//       final isConsult = schedule.lessonTypeAbbrev == 'конс' || 
//                        lessonType.contains('конс') ||
//                        lessonType.contains('консультация');
//       return !isExam && !isConsult;
//     }).toList();

//     final allSchedules = [...filteredRegularSchedules, ...announcements];
//     allSchedules.sort((a, b) {
//       final timeA = a.startLessonTime ?? '';
//       final timeB = b.startLessonTime ?? '';
//       return timeA.compareTo(timeB);
//     });

//     return allSchedules;
//   }

//   // Метод для получения экзаменов
//   List<Schedule> getExamsForDate(String date, List<Schedule>? exams) {
//     if (exams == null) return [];

//     try {
//       final targetDate = parseDate(date);
//       if (!shouldShowScheduleForDate(targetDate)) {
//         return [];
//       }
//     } catch (e) {}

//     return exams.where((exam) {
//       final examDate = exam.dateLesson;
//       if (examDate == date) return true;
      
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

//   // Метод для старого API (для обратной совместимости)
//   List<Schedule> getAllSchedulesForDayAuto(
//     Map<String, List<Schedule>>? schedules,
//     List<Schedule>? exams,
//     String dayName,
//     int weekNumber,
//     String date,
//   ) {
//     // Просто используем основной метод без экзаменов
//     return getAllSchedulesForDay(schedules, dayName, weekNumber, date);
//   }

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

//     return '$lastName $firstName $middleName';
//   }

//   String getTeacherImage(List<Employee>? employees) {
//     return employees?.firstOrNull?.photoLink ?? '';
//   }

//   // ========== МЕТОДЫ ДЛЯ ПОЛУЧЕНИЯ ИНФОРМАЦИИ О ЗАНЯТИИ ==========

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

//   String getLessonTypeDisplay(Schedule schedule) {
//     return schedule.lessonTypeAbbrev ?? 'Занятие';
//   }

//   LessonType getLessonTypeEnum(Schedule schedule) {
//     final abbrev = schedule.lessonTypeAbbrev?.toLowerCase() ?? '';
    
//     if (abbrev.contains('экз')) return LessonType.exam;
//     if (abbrev.contains('конс')) return LessonType.consultation;
//     if (abbrev.contains('лк')) return LessonType.lecture;
//     if (abbrev.contains('пз')) return LessonType.practice;
//     if (abbrev.contains('лр')) return LessonType.lab;
    
//     return LessonType.other;
//   }

//   bool isAnnouncement(Schedule schedule) {
//     return schedule.announcement == true;
//   }

//   // ========== МЕТОДЫ ДЛЯ ПРОВЕРКИ СОСТОЯНИЯ ==========

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

//   // ========== МЕТОДЫ ДЛЯ ДАТЫ ОТОБРАЖЕНИЯ ==========

//   DateTime getStartDisplayDate() {
//     final now = DateTime.now();
//     final startDateStr = _mainGroup?.startDate;
    
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
//         final displayDate = startDate.isAfter(now) ? startDate : now;
//         return displayDate;
//       } catch (e) {
//       }
//     }
    
//     return now;
//   }

//   DateTime getMinDisplayDate() {
//     final startDateStr = _mainGroup?.startDate;
    
//     if (startDateStr != null && startDateStr.isNotEmpty) {
//       try {
//         final startDate = parseDate(startDateStr);
//         return startDate;
//       } catch (e) {
//       }
//     }
    
//     return DateTime.now();
//   }

//   bool isTodayDate(DateTime date) {
//     final now = DateTime.now();
//     return now.year == date.year && 
//            now.month == date.month && 
//            now.day == date.day;
//   }

//   String getCurrentDateFormatted() {
//     return DateFormat('dd.MM.yyyy').format(DateTime.now());
//   }
// }
















































// // import 'package:bsuir/domain/entity/employee.dart';
// // import 'package:bsuir/domain/entity/main_group.dart';
// // import 'package:bsuir/domain/entity/schedule.dart';
// // import 'package:bsuir/domain/api_client/api_client.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class MainGroupModel extends ChangeNotifier {
// //   final apiClient = ApiClient();
// //   final int groupNumber;
// //   MainGroup? _mainGroup;
// //   String? _errorMessage;

// //   MainGroupModel(this.groupNumber);

// //   MainGroup? get mainGroup => _mainGroup;
// //   String? get errorMessage => _errorMessage;

// //   Future<void> loadMainGroup() async {
// //     try {
// //       _errorMessage = null;
// //       final group = await apiClient.getScheduleResponse(groupNumber);
// //       _mainGroup = group;
// //       notifyListeners();
// //     } catch (e) {
// //       _errorMessage = 'Ошибка загрузки расписания: ${e.toString()}';
// //       notifyListeners();
// //       rethrow;
// //     }
// //   }

// //   bool get isZaochOrDist {
// //     return _mainGroup?.isZaochOrDist == true ? true : false;
// //   }

// //   DateTime getStartDisplayDate() {
// //     final now = DateTime.now();

// //     DateTime baseStart;

// //     if (isZaochOrDist) {
// //       final startExamsDateStr = _mainGroup?.startExamsDate;
// //       if (startExamsDateStr != null && startExamsDateStr.isNotEmpty) {
// //         baseStart = parseDate(startExamsDateStr);
// //       } else {
// //         baseStart = now;
// //       }
// //     } else {
// //       final startDateStr = _mainGroup?.startDate;
// //       if (startDateStr != null && startDateStr.isNotEmpty) {
// //         baseStart = parseDate(startDateStr);
// //       } else {
// //         baseStart = now;
// //       }
// //     }

// //     // если расписание уже началось — берём today
// //     if (!baseStart.isAfter(now)) {
// //       // ⛔ воскресенье — не учебный день
// //       if (now.weekday == DateTime.sunday) {
// //         return now.add(const Duration(days: 1)); // понедельник
// //       }
// //       return now;
// //     }

// //     // если расписание ещё НЕ началось — показываем с даты начала
// //     return baseStart;
// //   }

// //   /// Получает базовую дату (понедельник) для недели с учетом типа
// //   DateTime _getMondayForWeek(
// //     bool semesterStarted,
// //     DateTime referenceDate,
// //     int weekOffset,
// //   ) {
// //     final mondayOfReferenceWeek = referenceDate.subtract(
// //       Duration(days: referenceDate.weekday - 1),
// //     );

// //     return mondayOfReferenceWeek.add(Duration(days: weekOffset * 7));
// //   }

// //   /// Получает базовую дату для недели с offset
// //   /// Для семестров, которые уже начались:
// //   ///   - weekOffset = 0: текущая неделя (начиная с сегодняшнего дня)
// //   ///   - weekOffset = 1: следующая неделя
// //   /// Для семестров, которые еще не начались:
// //   ///   - weekOffset = 0: неделя начала
// //   ///   - weekOffset = 1: следующая неделя
// //   DateTime getBaseDateForWeek(int weekOffset) {
// //     final startDate = getStartDisplayDate();
// //     final semesterStarted = hasSemesterStarted();

// //     return _getMondayForWeek(semesterStarted, startDate, weekOffset);
// //   }

// //   DateTime _getMondayOfCurrentWeek() {
// //     final now = DateTime.now();

// //     if (now.weekday == DateTime.sunday) {
// //       // воскресенье = уже следующая неделя
// //       return now.add(const Duration(days: 1));
// //     }

// //     return now.subtract(Duration(days: now.weekday - 1));
// //   }

// //   /// Получает дату для конкретного дня недели для ТЕКУЩЕЙ недели
// //   String getDateForCurrentWeekDay(String dayName, String? endDate) {
// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();

// //     final baseWeekday = mondayOfCurrentWeek.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = mondayOfCurrentWeek.add(Duration(days: dayDifference));
// //     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

// //     if (endDate != null && !isDateValid(targetDate, endDate)) {
// //       return '$dateString (семестр окончен)';
// //     }

// //     return dateString;
// //   }

// //   /// Получает дату для конкретного дня недели для БУДУЩИХ недель
// //   String getDateForFutureWeekDay(
// //     String dayName,
// //     int weekOffset,
// //     String? endDate,
// //   ) {
// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final baseDate = getBaseDateForWeek(weekOffset);

// //     final baseWeekday = baseDate.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = baseDate.add(Duration(days: dayDifference));
// //     final dateString = DateFormat('dd.MM.yyyy').format(targetDate);

// //     if (endDate != null && !isDateValid(targetDate, endDate)) {
// //       return '$dateString (семестр окончен)';
// //     }

// //     return dateString;
// //   }

// //   /// Проверяет, является ли день валидным для текущей недели
// //   bool isDayValidForCurrentWeek(String dayName, String? endDate) {
// //     if (endDate == null) return true;

// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();

// //     final baseWeekday = mondayOfCurrentWeek.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = mondayOfCurrentWeek.add(Duration(days: dayDifference));
// //     return isDateValid(targetDate, endDate);
// //   }

// //   /// Проверяет, является ли день валидным для будущих недель
// //   bool isDayValidForFutureWeek(
// //     String dayName,
// //     int weekOffset,
// //     String? endDate,
// //   ) {
// //     if (endDate == null) return true;

// //     final targetWeekday = getWeekdayNumber(dayName);
// //     final baseDate = getBaseDateForWeek(weekOffset);

// //     final baseWeekday = baseDate.weekday;
// //     int dayDifference = targetWeekday - baseWeekday;

// //     if (dayDifference < 0) {
// //       dayDifference += 7;
// //     }

// //     final targetDate = baseDate.add(Duration(days: dayDifference));
// //     return isDateValid(targetDate, endDate);
// //   }

// //   /// Получает номер недели для отображения для ТЕКУЩЕЙ недели
// //   int getWeekNumberForCurrentWeek(String? startDate) {
// //     if (startDate == null || startDate.isEmpty) return 1;

// //     final mondayOfCurrentWeek = _getMondayOfCurrentWeek();
// //     final startDateTime = parseDate(startDate);

// //     final difference = mondayOfCurrentWeek.difference(startDateTime).inDays;
// //     final weekNumber = (difference ~/ 7) + 1;

// //     return weekNumber > 0 ? ((weekNumber - 1) % 4) + 1 : 1;
// //   }

// //   /// Получает номер недели для отображения для БУДУЩИХ недель
// //   int getWeekNumberForFutureWeek(int weekOffset, String? startDate) {
// //     if (startDate == null || startDate.isEmpty) return 1;

// //     final baseDate = getBaseDateForWeek(weekOffset);
// //     final startDateTime = parseDate(startDate);

// //     final difference = baseDate.difference(startDateTime).inDays;
// //     final weekNumber = (difference ~/ 7) + 1;

// //     return weekNumber > 0 ? ((weekNumber - 1) % 4) + 1 : 1;
// //   }

// //   // Вспомогательные методы
// //   DateTime parseDate(String dateStr) {
// //     return DateFormat('dd.MM.yyyy').parse(dateStr);
// //   }

// //   String getRussianDayName(DateTime date) {
// //     switch (date.weekday) {
// //       case 1:
// //         return 'Понедельник';
// //       case 2:
// //         return 'Вторник';
// //       case 3:
// //         return 'Среда';
// //       case 4:
// //         return 'Четверг';
// //       case 5:
// //         return 'Пятница';
// //       case 6:
// //         return 'Суббота';
// //       case 7:
// //         return 'Воскресенье';
// //       default:
// //         return 'Понедельник';
// //     }
// //   }

// //   int getWeekdayNumber(String dayName) {
// //     switch (dayName) {
// //       case 'Понедельник':
// //         return 1;
// //       case 'Вторник':
// //         return 2;
// //       case 'Среда':
// //         return 3;
// //       case 'Четверг':
// //         return 4;
// //       case 'Пятница':
// //         return 5;
// //       case 'Суббота':
// //         return 6;
// //       case 'Воскресенье':
// //         return 7;
// //       default:
// //         return 1;
// //     }
// //   }

// //   bool isDateValid(DateTime date, String endDateStr) {
// //     try {
// //       final endDate = parseDate(endDateStr);
// //       return date.isBefore(endDate)
// //       || date.isAtSameMomentAs(endDate);
// //     } catch (e) {
// //       return true;
// //     }
// //   }

// //   int getCurrentWeekNumber(String? startDateStr, {DateTime? currentDate}) {
// //     if (startDateStr == null || startDateStr.isEmpty) return 1;

// //     final current = currentDate ?? DateTime.now();
// //     final startDate = parseDate(startDateStr);

// //     final difference = current.difference(startDate).inDays;
// //     final weekNumber = (difference ~/ 7) + 1;

// //     return weekNumber > 0 ? ((weekNumber - 1) % 4) + 1 : 1;
// //   }

// //   int getAbsoluteWeekNumber(String? startDateStr, {DateTime? currentDate}) {
// //     if (startDateStr == null || startDateStr.isEmpty) return 1;

// //     final current = currentDate ?? DateTime.now();
// //     final startDate = parseDate(startDateStr);

// //     final difference = current.difference(startDate).inDays;
// //     final weekNumber = (difference ~/ 7) + 1;

// //     return weekNumber > 0 ? weekNumber : 1;
// //   }

// //   // Методы для получения расписания (оставляем без изменений)
// //   List<Schedule> getScheduleForDayAndWeek(
// //     Map<String, List<Schedule>>? schedules,
// //     String dayName,
// //     int weekNumber,
// //   ) {
// //     if (schedules == null) return [];

// //     final daySchedules = schedules[dayName] ?? [];

// //     return daySchedules.where((schedule) {
// //       if (schedule.announcement == true) {
// //         return false;
// //       }

// //       final weekNumbers = schedule.weekNumber;
// //       if (weekNumbers == null || weekNumbers.isEmpty) return false;
// //       return weekNumbers.contains(weekNumber);
// //     }).toList();
// //   }

// //   List<Schedule> getAnnouncementsForDate(
// //     String date,
// //     Map<String, List<Schedule>>? schedules,
// //   ) {
// //     if (schedules == null) return [];

// //     final allAnnouncements = <Schedule>[];

// //     for (final daySchedules in schedules.values) {
// //       for (final schedule in daySchedules) {
// //         if (schedule.announcement == true) {
// //           final announcementDate = schedule.startLessonDate;
// //           if (announcementDate == date) {
// //             allAnnouncements.add(schedule);
// //           }
// //         }
// //       }
// //     }

// //     allAnnouncements.sort((a, b) {
// //       final timeA = a.startLessonTime ?? '';
// //       final timeB = b.startLessonTime ?? '';
// //       return timeA.compareTo(timeB);
// //     });

// //     return allAnnouncements;
// //   }

// //   List<Schedule> getAllSchedulesForDay(
// //     Map<String, List<Schedule>>? schedules,
// //     String dayName,
// //     int weekNumber,
// //     String date,
// //   ) {
// //     final regularSchedules = getScheduleForDayAndWeek(
// //       schedules,
// //       dayName,
// //       weekNumber,
// //     );
// //     final announcements = getAnnouncementsForDate(date, schedules);

// //     final allSchedules = [...regularSchedules, ...announcements];
// //     allSchedules.sort((a, b) {
// //       final timeA = a.startLessonTime ?? '';
// //       final timeB = b.startLessonTime ?? '';
// //       return timeA.compareTo(timeB);
// //     });

// //     return allSchedules;
// //   }

// //   List<Schedule> getExamsForDate(String date, List<Schedule>? exams) {
// //     if (exams == null) return [];

// //     return exams.where((exam) {
// //       final examDate = exam.dateLesson;
// //       return examDate == date;
// //     }).toList();
// //   }

// //   List<Schedule> getAllSchedulesForZaochDay(
// //     List<Schedule>? exams,
// //     String date,
// //   ) {
// //     final examsForDate = getExamsForDate(date, exams);

// //     examsForDate.sort((a, b) {
// //       final timeA = a.startLessonTime ?? '';
// //       final timeB = b.startLessonTime ?? '';
// //       return timeA.compareTo(timeB);
// //     });

// //     return examsForDate;
// //   }

// //   List<Schedule> getAllSchedulesForDayAuto(
// //     Map<String, List<Schedule>>? schedules,
// //     List<Schedule>? exams,
// //     String dayName,
// //     int weekNumber,
// //     String date,
// //   ) {
// //     if (isZaochOrDist) {
// //       return getAllSchedulesForZaochDay(exams, date);
// //     } else {
// //       return getAllSchedulesForDay(schedules, dayName, weekNumber, date);
// //     }
// //   }

// //   String getEmployeeName(Employee? employee) {
// //     if (employee == null) return '';

// //     final firstName = employee.firstName ?? '';
// //     final lastName = employee.lastName ?? '';
// //     final middleName = employee.middleName ?? '';

// //     if (firstName.isEmpty) return lastName;

// //     final middleInitial = middleName.isNotEmpty ? '${middleName[0]}.' : '';
// //     return '$lastName ${firstName[0]}.$middleInitial';
// //   }

// //   String getEmployeeNameFromList(List<Employee>? employees) {
// //     if (employees == null || employees.isEmpty) return '';
// //     return getEmployeeName(employees.first);
// //   }

// //   String getTeacherImage(List<Employee>? employees) {
// //     if (employees == null || employees.isEmpty) {
// //       return '';
// //     }
// //     return employees.first.photoLink ?? '';
// //   }

// //   String getSubjectName(Schedule schedule) {
// //     if (schedule.subject != null && schedule.subject!.isNotEmpty) {
// //       return schedule.subject!;
// //     }

// //     if (schedule.subjectFullName != null &&
// //         schedule.subjectFullName!.isNotEmpty) {
// //       return schedule.subjectFullName!;
// //     }

// //     return schedule.note ?? 'Занятие';
// //   }

// //   String getLessonType(Schedule schedule) {
// //     if (isZaochOrDist) {
// //       return schedule.lessonTypeAbbrev ?? 'Экзамен';
// //     }
// //     return schedule.lessonTypeAbbrev ?? 'Занятие';
// //   }

// //   bool isAnnouncement(Schedule schedule) {
// //     return schedule.announcement == true;
// //   }

// //   String getAnnouncementDate(Schedule schedule) {
// //     return schedule.startLessonDate ?? '';
// //   }

// //   bool hasData() {
// //     return _mainGroup != null;
// //   }

// //   bool hasSchedules() {
// //     if (_mainGroup == null) return false;

// //     if (isZaochOrDist) {
// //       return _mainGroup!.exams != null && _mainGroup!.exams!.isNotEmpty;
// //     } else {
// //       return _mainGroup!.schedules != null && _mainGroup!.schedules!.isNotEmpty;
// //     }
// //   }


// //    bool isSemesterEnded() {
// //   final now = DateTime.now();

// //   if (isZaochOrDist) {
// //     final endExamsDateStr = _mainGroup?.endExamsDate;
// //     if (endExamsDateStr != null && endExamsDateStr.isNotEmpty) {
// //       final endExamsDate = parseDate(endExamsDateStr);
// //       return now.isAfter(endExamsDate);
// //     }
// //   } else {
// //     final endDateStr = _mainGroup?.endDate;
// //     if (endDateStr != null && endDateStr.isNotEmpty) {
// //       final endDate = parseDate(endDateStr);
// //       return now.isAfter(endDate);
// //     }
// //   }

// //   return false;
// // }




// // List<Schedule> getAllSchedulesForDayAllWeeks(
// //   Map<String, List<Schedule>>? schedules,
// //   String dayName,
// // ) {
// //   if (schedules == null) return [];

// //   final daySchedules = schedules[dayName] ?? [];

// //   final result = daySchedules
// //       .where((s) => s.announcement != true)
// //       .toList();

// //   result.sort((a, b) {
// //     final t1 = a.startLessonTime ?? '';
// //     final t2 = b.startLessonTime ?? '';
// //     return t1.compareTo(t2);
// //   });

// //   return result;
// // }




// //   //   bool isDateValid(DateTime date, String endDateStr) {
// //   //   try {
// //   //     final endDate = parseDate(endDateStr);
// //   //     return date.isBefore(endDate)
// //   //     || date.isAtSameMomentAs(endDate);
// //   //   } catch (e) {
// //   //     return true;
// //   //   }
// //   // }

// //   bool hasSemesterStarted() {
// //     final now = DateTime.now();

// //     if (isZaochOrDist) {
// //       final startExamsDateStr = _mainGroup?.startExamsDate;
// //       if (startExamsDateStr != null && startExamsDateStr.isNotEmpty) {
// //         try {
// //           final startExamsDate = parseDate(startExamsDateStr);
// //           return now.isAfter(startExamsDate) ||
// //               now.isAtSameMomentAs(startExamsDate);
// //         } catch (e) {
// //           return true;
// //         }
// //       }
// //     } else {
// //       final startDateStr = _mainGroup?.startDate;
// //       if (startDateStr != null && startDateStr.isNotEmpty) {
// //         try {
// //           final startDate = parseDate(startDateStr);
// //           return now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
// //         } catch (e) {
// //           return true;
// //         }
// //       }
// //     }

// //     return true;
// //   }
// // }

