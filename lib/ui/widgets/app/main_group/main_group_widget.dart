// import 'package:bsuir/domain/entity/main_group.dart';
// import 'package:bsuir/domain/entity/schedule.dart';
// import 'package:bsuir/resourses/app_colors.dart';
// import 'package:bsuir/resourses/app_fonts.dart';
// import 'package:bsuir/ui/widgets/inherited/provider.dart';
// import 'package:bsuir/ui/widgets/app/main_group/main_group_model.dart';
// import 'package:bsuir/ui/widgets/app/main_group/modal_bottom_sheet_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MainGroupScheduleWidget extends StatefulWidget {
//   const MainGroupScheduleWidget({super.key});

//   @override
//   State<MainGroupScheduleWidget> createState() =>
//       _MainGroupScheduleWidgetState();
// }

// class _MainGroupScheduleWidgetState extends State<MainGroupScheduleWidget> {
//   final ScrollController _scrollController = ScrollController();
//   int _weeksToShow = 5;
//   bool _hasMoreWeeks = true;

//   ScheduleViewType _selectedViewType = ScheduleViewType.schedule;

//   bool _viewTypeInitialized = false;
//   bool _viewTypeReady = false;

//   @override
//   void initState() {
//     super.initState();
//     final model = NotifierProvider.read<MainGroupModel>(context);
//     model?.loadMainGroup().catchError((error) {
//       print('Ошибка загрузки: $error');
//     });
//     _scrollController.addListener(_scrollListener);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _determineInitialViewType();
//     });
//   }

//   void _determineInitialViewType() {
//     final model = NotifierProvider.read<MainGroupModel>(context);
//     if (model == null || model.mainGroup == null) return;

//     setState(() {
//       if (model.isSemesterEnded()) {
//         _selectedViewType = ScheduleViewType.exams;
//       } else {
//         _selectedViewType = ScheduleViewType.schedule;
//       }
//       _viewTypeReady = true;
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollListener() {
//     final model = NotifierProvider.read<MainGroupModel>(context);
//     final scheduleData = model?.mainGroup;

//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 200 &&
//         _hasMoreWeeks &&
//         scheduleData?.endDate != null) {
//       setState(() {
//         _weeksToShow += 1;
//       });
//     }
//   }

//   void _onLessonTap(MainGroupModel model, Schedule schedule) {
//     showModalBottomSheet(
//       context: context,
//       builder: (ctx) => LessonInfo(model, schedule),
//       isScrollControlled: true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final model = NotifierProvider.watch<MainGroupModel>(context);
//     final scheduleData = model?.mainGroup;
//     final errorMessage = model?.errorMessage;

//     if (!_viewTypeInitialized && scheduleData != null) {
//       _viewTypeInitialized = true;
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _determineInitialViewType();
//       });
//     }
    
//     if (errorMessage != null) {
//       return _buildErrorWidget(model!);
//     }

//     if (!_viewTypeReady || scheduleData == null) {
//       return _buildLoadingWidget();
//     }

//     if (!model!.hasData()) {
//       return _buildNoDataWidget();
//     }

//     if (!model.hasSchedules()) {
//       return _buildNoScheduleWidget();
//     }

//     return Scaffold(
//       backgroundColor: AppColors.greyBackground,
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           '${model.groupNumber}',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 14,
//             height: 1.3,
//             fontFamily: AppFonts.montserrat,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               model.isFavorite ? Icons.star : Icons.star_border,
//               color: model.isFavorite ? Colors.amber : AppColors.blue,
//             ),
//             onPressed: () async {
//               if (model != null) {
//                 await model.toggleFavorite();
//               }
//             },
//           ),
//           const SizedBox(width: 30),
//           const Icon(Icons.group_work, color: AppColors.blue),
//           const SizedBox(width: 20),
//           PopupMenuButton<ScheduleViewType>(
//             onSelected: (value) {
//               setState(() {
//                 _selectedViewType = value;
//               });
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: ScheduleViewType.schedule,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Расписание'),
//                     if (_selectedViewType == ScheduleViewType.schedule)
//                       const Icon(Icons.check, size: 20, color: AppColors.blue),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: ScheduleViewType.daily,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('По дням'),
//                     if (_selectedViewType == ScheduleViewType.daily)
//                       const Icon(Icons.check, size: 20, color: AppColors.blue),
//                   ],
//                 ),
//               ),
//               PopupMenuItem(
//                 value: ScheduleViewType.exams,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Экзамены'),
//                     if (_selectedViewType == ScheduleViewType.exams)
//                       const Icon(Icons.check, size: 20, color: AppColors.blue),
//                   ],
//                 ),
//               ),
//             ],
//             icon: const Icon(Icons.more_vert),
//           ),
//         ],
//         backgroundColor: AppColors.greyBackground,
//       ),
//       body: Column(
//         children: [
//           if (_selectedViewType == ScheduleViewType.exams)
//             Container(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         scheduleData.startExamsDate != null
//                             ? 'Начало: ${scheduleData.startExamsDate}'
//                             : 'Даты не указаны',
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         scheduleData.endExamsDate != null
//                             ? 'Окончание: ${scheduleData.endExamsDate}'
//                             : 'Семестр: дата не указана',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           Expanded(child: _buildBodyContent(model, scheduleData)),
//         ],
//       ),
//     );
//   }

//   Widget _buildBodyContent(MainGroupModel model, MainGroup scheduleData) {
//     switch (_selectedViewType) {
//       case ScheduleViewType.schedule:
//         return _buildScheduleView(model, scheduleData);
//       case ScheduleViewType.daily:
//         return _buildDailyView(model, scheduleData);
//       case ScheduleViewType.exams:
//         return _buildExamsView(model, scheduleData);
//     }
//   }

//   Widget _buildScheduleView(MainGroupModel model, MainGroup scheduleData) {
//     final semesterStarted = model.hasSemesterStarted();
//     final hasMainSchedules = model.hasMainSchedules();
//     final semesterEnded = model.isSemesterEnded();

//     const allDays = [
//       'Понедельник',
//       'Вторник',
//       'Среда',
//       'Четверг',
//       'Пятница',
//       'Суббота',
//     ];

//     final startDisplayDate = model.getStartDisplayDate();
//     final startRussianName = model.getRussianDayName(startDisplayDate);
//     final startIndex = allDays.indexOf(startRussianName);

//     final validItems = <Widget>[];
//     if (hasMainSchedules) {
//       if (semesterStarted) {
//         final dayName = startRussianName;
//         final todayDateStr = DateFormat('dd.MM.yyyy').format(startDisplayDate);
//         final weekNumber = model.getWeekNumberForCurrentWeek(
//           scheduleData.startDate,
//         );

//         // В режимах schedule и daily показываем только обычные занятия (без экзаменов)
//         final daySchedules = model.getAllSchedulesForDay(
//           scheduleData.schedules,
//           dayName,
//           weekNumber,
//           todayDateStr,
//         );

//         final isSemesterEnded = scheduleData.endDate != null
//             ? !model.isDateValid(startDisplayDate, scheduleData.endDate!)
//             : false;

//         validItems.add(
//           _buildDaySection(
//             model,
//             dayName,
//             '$todayDateStr (сегодня)',
//             daySchedules,
//             weekNumber,
//             0,
//             true,
//             isSemesterEnded,
//             semesterStarted: semesterStarted,
//           ),
//         );

//         if (startIndex < allDays.length - 1) {
//           final remainingDays = allDays.sublist(startIndex + 1);

//           for (final dayName in remainingDays) {
//             if (model.isDayValidForCurrentWeek(dayName, scheduleData.endDate)) {
//               final weekNumber = model.getWeekNumberForCurrentWeek(
//                 scheduleData.startDate,
//               );
//               final date = model.getDateForCurrentWeekDay(
//                 dayName,
//                 scheduleData.endDate,
//               );
//               final dateOnly = date.replaceAll(' (семестр окончен)', '');

//               final daySchedules = model.getAllSchedulesForDay(
//                 scheduleData.schedules,
//                 dayName,
//                 weekNumber,
//                 dateOnly,
//               );

//               final isSemesterEnded = date.contains('семестр окончен');

//               validItems.add(
//                 _buildDaySection(
//                   model,
//                   dayName,
//                   date,
//                   daySchedules,
//                   weekNumber,
//                   0,
//                   false,
//                   isSemesterEnded,
//                   semesterStarted: semesterStarted,
//                 ),
//               );
//             }
//           }
//         }

//         for (int weekOffset = 1; weekOffset <= _weeksToShow; weekOffset++) {
//           bool weekHasValidDays = false;

//           for (final dayName in allDays) {
//             if (model.isDayValidForFutureWeek(
//               dayName,
//               weekOffset,
//               scheduleData.endDate,
//             )) {
//               final weekNumber = model.getWeekNumberForFutureWeek(
//                 weekOffset,
//                 scheduleData.startDate,
//               );
//               final date = model.getDateForFutureWeekDay(
//                 dayName,
//                 weekOffset,
//                 scheduleData.endDate,
//               );
//               final dateOnly = date.replaceAll(' (семестр окончен)', '');

//               final daySchedules = model.getAllSchedulesForDay(
//                 scheduleData.schedules,
//                 dayName,
//                 weekNumber,
//                 dateOnly,
//               );

//               final isSemesterEnded = date.contains('семестр окончен');

//               validItems.add(
//                 _buildDaySection(
//                   model,
//                   dayName,
//                   date,
//                   daySchedules,
//                   weekNumber,
//                   weekOffset,
//                   false,
//                   isSemesterEnded,
//                   semesterStarted: semesterStarted,
//                 ),
//               );

//               weekHasValidDays = true;
//             }
//           }

//           if (!weekHasValidDays) {
//             _hasMoreWeeks = false;
//             break;
//           }
//         }
//       } else {
//         for (int weekOffset = 0; weekOffset < _weeksToShow; weekOffset++) {
//           bool weekHasValidDays = false;

//           for (final dayName in allDays) {
//             if (model.isDayValidForFutureWeek(
//               dayName,
//               weekOffset,
//               scheduleData.endDate,
//             )) {
//               final weekNumber = model.getWeekNumberForFutureWeek(
//                 weekOffset,
//                 scheduleData.startDate,
//               );
//               final date = model.getDateForFutureWeekDay(
//                 dayName,
//                 weekOffset,
//                 scheduleData.endDate,
//               );
//               final dateOnly = date.replaceAll(' (семестр окончен)', '');

//               final daySchedules = model.getAllSchedulesForDay(
//                 scheduleData.schedules,
//                 dayName,
//                 weekNumber,
//                 dateOnly,
//               );

//               final isSemesterEnded = date.contains('семестр окончен');
//               final isStartDay = weekOffset == 0 && dayName == startRussianName;

//               validItems.add(
//                 _buildDaySection(
//                   model,
//                   dayName,
//                   date,
//                   daySchedules,
//                   weekNumber,
//                   weekOffset + 1,
//                   isStartDay,
//                   isSemesterEnded,
//                   semesterStarted: semesterStarted,
//                 ),
//               );

//               weekHasValidDays = true;
//             }
//           }

//           if (!weekHasValidDays) {
//             _hasMoreWeeks = false;
//             break;
//           }
//         }
//       }
//     }

//     return validItems.isEmpty || semesterEnded
//         ? _buildNoScheduleWidget()
//         : ListView(controller: _scrollController, children: validItems);
//   }

//   Widget _buildDailyView(MainGroupModel model, MainGroup scheduleData) {
//     final allDays = [
//       'Понедельник',
//       'Вторник',
//       'Среда',
//       'Четверг',
//       'Пятница',
//       'Суббота',
//     ];

//     final validItems = <Widget>[];
//     final semesterStarted = model.hasSemesterStarted();

//     final Map<String, Map<int, List<Schedule>>> schedulesByDayAndWeek = {};

//     // Функция для проверки, является ли занятие обычным (не экзаменом, не консультацией)
//     bool isRegularSchedule(Schedule schedule) {
//       if (schedule.announcement == true) return true;

//       final lessonType = schedule.lessonTypeAbbrev?.toLowerCase() ?? '';
//       final isExam = schedule.lessonTypeAbbrev == 'экз' || 
//                     lessonType.contains('экз') ||
//                     lessonType.contains('exam');
//       final isConsult = schedule.lessonTypeAbbrev == 'конс' || 
//                        lessonType.contains('конс') ||
//                        lessonType.contains('консультация');
//       return !isExam && !isConsult;
//     }

//     // Обрабатываем регулярные занятия по неделям (1-4)
//     for (int weekNumber = 1; weekNumber <= 4; weekNumber++) {
//       for (final dayName in allDays) {
//         String targetDate;
//         try {
//           final now = DateTime.now();
//           final mondayOfCurrentWeek = now.subtract(
//             Duration(days: now.weekday - 1),
//           );
//           final startDate = model.parseDate(scheduleData.startDate ?? '');

//           final weeksFromStart =
//               (mondayOfCurrentWeek.difference(startDate).inDays ~/ 7) + 1;
//           final targetWeek = ((weeksFromStart - 1) ~/ 4) * 4 + weekNumber;

//           final targetDateObj = startDate.add(
//             Duration(days: (targetWeek - 1) * 7 + allDays.indexOf(dayName)),
//           );
//           targetDate = DateFormat('dd.MM.yyyy').format(targetDateObj);
//         } catch (e) {
//           targetDate = '';
//         }

//         // Получаем занятия через основной метод (уже отфильтрованы экзамены)
//         final daySchedules = model.getAllSchedulesForDay(
//           scheduleData.schedules,
//           dayName,
//           weekNumber,
//           targetDate,
//         );

//         // Дополнительная фильтрация на всякий случай
//         final filteredSchedules = daySchedules.where(isRegularSchedule).toList();

//         if (filteredSchedules.isNotEmpty) {
//           if (!schedulesByDayAndWeek.containsKey(dayName)) {
//             schedulesByDayAndWeek[dayName] = {};
//           }
//           schedulesByDayAndWeek[dayName]![weekNumber] = filteredSchedules;
//         }
//       }
//     }

//     // Добавляем объявления
//     if (scheduleData.schedules != null) {
//       for (final daySchedules in scheduleData.schedules!.values) {
//         for (final schedule in daySchedules) {
//           if (schedule.announcement == true) {
//             final announcementDate = schedule.startLessonDate;
//             if (announcementDate != null && announcementDate.isNotEmpty) {
//               try {
//                 final date = DateFormat('dd.MM.yyyy').parse(announcementDate);
//                 final dayName = model.getRussianDayName(date);

//                 if (!schedulesByDayAndWeek.containsKey(dayName)) {
//                   schedulesByDayAndWeek[dayName] = {};
//                 }
//                 if (!schedulesByDayAndWeek[dayName]!.containsKey(0)) {
//                   schedulesByDayAndWeek[dayName]![0] = [];
//                 }
//                 schedulesByDayAndWeek[dayName]![0]!.add(schedule);
//               } catch (e) {}
//             }
//           }
//         }
//       }
//     }

//     // Сортируем дни по порядку
//     final sortedDays = allDays
//         .where((day) => schedulesByDayAndWeek.containsKey(day))
//         .toList();

//     // Создаем виджеты для каждого дня и недели
//     for (final dayName in sortedDays) {
//       final weeksForDay = schedulesByDayAndWeek[dayName]!;
//       final weekNumbers = weeksForDay.keys.toList()..sort();

//       for (final weekNumber in weekNumbers) {
//         final daySchedules = weeksForDay[weekNumber]!;

//         // Сортируем занятия по времени
//         daySchedules.sort((a, b) {
//           final timeA = a.startLessonTime ?? '';
//           final timeB = b.startLessonTime ?? '';
//           return timeA.compareTo(timeB);
//         });

//         String dateDisplay;
//         if (weekNumber == 0) {
//           dateDisplay = 'Объявления';
//         } else {
//           try {
//             final now = DateTime.now();
//             final mondayOfCurrentWeek = now.subtract(
//               Duration(days: now.weekday - 1),
//             );
//             final startDate = model.parseDate(scheduleData.startDate ?? '');

//             final weeksFromStart =
//                 (mondayOfCurrentWeek.difference(startDate).inDays ~/ 7) + 1;
//             final targetWeek = ((weeksFromStart - 1) ~/ 4) * 4 + weekNumber;

//             final targetDate = startDate.add(
//               Duration(days: (targetWeek - 1) * 7 + allDays.indexOf(dayName)),
//             );
//             dateDisplay = DateFormat('dd.MM.yyyy').format(targetDate);
//           } catch (e) {
//             dateDisplay = 'Неделя $weekNumber';
//           }
//         }

//         validItems.add(
//           _buildDaySection(
//             model,
//             dayName,
//             dateDisplay,
//             daySchedules,
//             weekNumber,
//             0,
//             false,
//             false,
//             semesterStarted: semesterStarted,
//             showWeekNumberInCard: true,
//             forceWeekNumber: weekNumber,
//           ),
//         );
//       }
//     }

//     return validItems.isEmpty
//         ? _buildNoScheduleWidget()
//         : ListView(controller: _scrollController, children: validItems);
//   }

//   Widget _buildExamsView(MainGroupModel model, MainGroup scheduleData) {
//     final validItems = <Widget>[];
//     final semesterStarted = model.hasSemesterStarted();

//     if (scheduleData.exams == null || scheduleData.exams!.isEmpty) {
//       return _buildNoScheduleWidget();
//     }

//     final Map<String, List<Schedule>> examsByDate = {};

//     for (final exam in scheduleData.exams!) {
//       final date = exam.dateLesson ?? '';
//       if (date.isNotEmpty) {
//         if (!examsByDate.containsKey(date)) {
//           examsByDate[date] = [];
//         }
//         examsByDate[date]!.add(exam);
//       }
//     }

//     final sortedDates = examsByDate.keys.toList()
//       ..sort((a, b) {
//         try {
//           final dateA = DateFormat('dd.MM.yyyy').parse(a);
//           final dateB = DateFormat('dd.MM.yyyy').parse(b);
//           return dateA.compareTo(dateB);
//         } catch (e) {
//           return a.compareTo(b);
//         }
//       });

//     for (final date in sortedDates) {
//       final examsForDate = examsByDate[date]!;
//       final dayName = model.getDayNameFromDate(date);

//       validItems.add(
//         _buildDaySection(
//           model,
//           dayName,
//           date,
//           examsForDate,
//           1,
//           0,
//           false,
//           false,
//           semesterStarted: semesterStarted,
//           isExamView: true,
//         ),
//       );
//     }

//     return validItems.isEmpty
//         ? _buildNoScheduleWidget()
//         : ListView(controller: _scrollController, children: validItems);
//   }

//   Widget _buildDaySection(
//     MainGroupModel model,
//     String dayName,
//     String date,
//     List<Schedule> schedules,
//     int weekNumber,
//     int displayWeekOffset,
//     bool isStartDay,
//     bool isSemesterEnded, {
//     required bool semesterStarted,
//     bool isExamView = false,
//     bool showWeekNumberInCard = false,
//     int? forceWeekNumber,
//   }) {
//     final effectiveWeekNumber = forceWeekNumber ?? weekNumber;

//     return schedules.isEmpty
//         ? const SizedBox.shrink()
//         : Container(
//             margin: const EdgeInsets.all(8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(color: AppColors.greyBackground),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   dayName,
//                                   style: TextStyle(
//                                     color: isSemesterEnded
//                                         ? Colors.grey[600]
//                                         : Colors.black,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                     height: 1.3,
//                                   ),
//                                 ),
//                                 if (isStartDay && semesterStarted)
//                                   Container(
//                                     margin: const EdgeInsets.only(left: 8),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 2,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: AppColors.blue,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: const Text(
//                                       'Сегодня',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               effectiveWeekNumber == 0
//                                   ? 'Объявления'
//                                   : '$date${!isExamView && effectiveWeekNumber > 0 ? ', Неделя: $effectiveWeekNumber' : ''}',
//                               style: TextStyle(
//                                 color: isSemesterEnded
//                                     ? Colors.grey[600]
//                                     : Colors.black,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 height: 1.3,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isSemesterEnded
//                               ? Colors.grey[300]!
//                               : const Color(0xFFf3f2f8),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   children: schedules
//                       .map(
//                         (schedule) => _buildLessonCard(
//                           model,
//                           schedule,
//                           isSemesterEnded,
//                           isExamView,
//                           showWeekNumberInCard ? effectiveWeekNumber : null,
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ],
//             ),
//           );
//   }

//   Widget _buildLessonCard(
//     MainGroupModel model,
//     Schedule schedule,
//     bool isSemesterEnded,
//     bool isExamView,
//     int? weekNumberForDisplay,
//   ) {
//     final isAnnouncement = model.isAnnouncement(schedule);
//     final subjectName = model.getSubjectName(schedule);
//     final lessonType = model.getLessonTypeDisplay(schedule);
//     final teacherImage = model.getTeacherImage(schedule.employees);

//     final isExam = (schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('экз'));
//     final isConsult = (schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('конс'));
//     final isLecture = schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('лк');
//     final isPractice = schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('пз');
//     final isLab = schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('лр');

//     return InkWell(
//       onTap: () => _onLessonTap(model, schedule),
//       child: Container(
//         margin: const EdgeInsets.only(right: 12, left: 12, top: 2, bottom: 2),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: AppColors.greyBackground),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   schedule.startLessonTime ?? '--:--',
//                   style: const TextStyle(fontSize: 13, color: AppColors.black),
//                 ),
//                 const SizedBox(height: 1),
//                 Text(
//                   schedule.endLessonTime ?? '--:--',
//                   style: const TextStyle(fontSize: 11, color: AppColors.black),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         isAnnouncement ? 'Объявление!' : subjectName,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.black,
//                         ),
//                       ),
//                       if (schedule.numSubgroup == 0)
//                         const SizedBox.shrink()
//                       else
//                         Row(
//                           children: [
//                             const SizedBox(width: 8),
//                             Icon(
//                               Icons.person,
//                               color: AppColors.greyText,
//                               size: 18,
//                             ),
//                             const SizedBox(width: 3),
//                             Text('${schedule.numSubgroup}'),
//                           ],
//                         ),
//                     ],
//                   ),
//                   if (weekNumberForDisplay != null && !isAnnouncement)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 2),
//                       child: Text(
//                         'Неделя: $weekNumberForDisplay',
//                         style: const TextStyle(
//                           fontSize: 11,
//                           color: Colors.blue,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                   Text(
//                     lessonType,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: _getLessonTypeColor(
//                         isExam,
//                         isConsult,
//                         isLecture,
//                         isPractice,
//                         isLab,
//                         isSemesterEnded,
//                         isExamView,
//                       ),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 3),
//                   if (schedule.auditories != null &&
//                       schedule.auditories!.isNotEmpty)
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.room_outlined,
//                           size: 12,
//                           color: AppColors.greyText,
//                         ),
//                         const SizedBox(width: 2),
//                         Text(
//                           schedule.auditories!.join(', '),
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: AppColors.greyText,
//                           ),
//                         ),
//                       ],
//                     ),
//                   if (schedule.note != null && schedule.note!.isNotEmpty)
//                     Text(
//                       schedule.note!,
//                       style: const TextStyle(fontSize: 10, color: AppColors.greyText),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             Container(
//               width: 45,
//               height: 45,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.grey[300]!, width: 1),
//               ),
//               child: ClipOval(
//                 child: teacherImage.isNotEmpty
//                     ? Image.network(
//                         teacherImage,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Icon(
//                             Icons.person_outline,
//                             color: Colors.grey,
//                             size: 20,
//                           );
//                         },
//                       )
//                     : const Icon(
//                         Icons.person_outline,
//                         color: Colors.grey,
//                         size: 20,
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getLessonTypeColor(
//     bool isExam,
//     bool isConsult,
//     bool isLecture,
//     bool isPractice,
//     bool isLab,
//     bool isSemesterEnded,
//     bool isExamView,
//   ) {
//     if (isConsult) return Colors.brown;
//     if (isSemesterEnded) return Colors.grey;
//     if (isExam) return Colors.purple;
//     if (isLecture) return Colors.green;
//     if (isPractice) return Colors.red;
//     if (isLab) return Colors.orange;
//     return AppColors.black;
//   }

//   Widget _buildLoadingWidget() {
//     return ColoredBox(
//       color: AppColors.greyBackground,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             CircularProgressIndicator(color: AppColors.greyText),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorWidget(MainGroupModel model) {
//     return ColoredBox(
//       color: AppColors.greyBackground,
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, size: 50, color: AppColors.blue),
//               const SizedBox(height: 16),
//               const Text(
//                 'Ошибка загрузки',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.blue,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () => model.loadMainGroup(),
//                 child: const Text('Повторить попытку'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNoDataWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.info_outline, size: 64, color: Colors.grey),
//           const SizedBox(height: 16),
//           const Text(
//             'Нет данных',
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Расписание для этой группы не найдено',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoScheduleWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.sentiment_satisfied_alt_outlined,
//             size: 64,
//             color: Colors.grey,
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Расписание отсутствует',
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:bsuir/domain/entity/main_group.dart';

import 'package:bsuir/logic/bloc/main_group/main_group_cubit.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_state.dart';
import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/resourses/app_colors.dart';
import 'package:bsuir/resourses/app_fonts.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/empty_state_widgets.dart';

import 'package:bsuir/ui/widgets/app/main_group/views/daily_view.dart';
import 'package:bsuir/ui/widgets/app/main_group/views/exams_view.dart';

import 'package:bsuir/ui/widgets/app/main_group/views/schedule_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainGroupScheduleWidget extends StatefulWidget {
  final int groupNumber;

  const MainGroupScheduleWidget({super.key, required this.groupNumber});

  @override
  State<MainGroupScheduleWidget> createState() =>
      _MainGroupScheduleWidgetState();
}

class _MainGroupScheduleWidgetState extends State<MainGroupScheduleWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<MainGroupCubit>().loadMainGroup();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final state = context.read<MainGroupCubit>().state;
    if (state is MainGroupData) {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          state.hasMoreWeeks &&
          state.mainGroup.endDate != null) {
        context.read<MainGroupCubit>().loadMoreWeeks();
      }
    }
  }

  void _onLessonTap(BuildContext context, MainGroupCubit cubit, DisplaySchedule schedule) {
    // showModalBottomSheet(
    //   context: context,
    //   builder: (ctx) => LessonInfo(cubit, schedule.original),
    //   isScrollControlled: true,
    // );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainGroupCubit, MainGroupState>(
      builder: (context, state) {
        if (state is MainGroupError) {
          return ErrorStateWidget(
            message: state.message,
            onRetry: () => context.read<MainGroupCubit>().loadMainGroup(),
          );
        }

        if (state is MainGroupLoading) {
          return const LoadingStateWidget();
        }

        if (state is MainGroupData) {
          if (!state.hasSchedules) {
            return const NoScheduleStateWidget();
          }

          return Scaffold(
            backgroundColor: AppColors.greyBackground,
            appBar: _buildAppBar(context, state),
            body: Column(
              children: [
                if (state.selectedViewType == ScheduleViewType.exams)
                  _buildExamsHeader(state.mainGroup),
                Expanded(child: _buildBodyContent(context, state)),
              ],
            ),
          );
        }

        return const NoDataStateWidget();
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MainGroupData state) {
    final cubit = context.read<MainGroupCubit>();

    return AppBar(
      centerTitle: true,
      title: Text(
        '${widget.groupNumber}',
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          height: 1.3,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            state.isFavorite ? Icons.star : Icons.star_border,
            color: state.isFavorite ? Colors.amber : AppColors.blue,
          ),
          onPressed: () => cubit.toggleFavorite(),
        ),
        const SizedBox(width: 30),
        const Icon(Icons.group_work, color: AppColors.blue),
        const SizedBox(width: 20),
        _buildViewTypeMenu(context, state, cubit),
      ],
      backgroundColor: AppColors.greyBackground,
    );
  }

  Widget _buildViewTypeMenu(BuildContext context, MainGroupData state, MainGroupCubit cubit) {
    return PopupMenuButton<ScheduleViewType>(
      onSelected: (value) => cubit.changeViewType(value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ScheduleViewType.schedule,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Расписание'),
              if (state.selectedViewType == ScheduleViewType.schedule)
                const Icon(Icons.check, size: 20, color: AppColors.blue),
            ],
          ),
        ),
        PopupMenuItem(
          value: ScheduleViewType.daily,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('По дням'),
              if (state.selectedViewType == ScheduleViewType.daily)
                const Icon(Icons.check, size: 20, color: AppColors.blue),
            ],
          ),
        ),
        PopupMenuItem(
          value: ScheduleViewType.exams,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Экзамены'),
              if (state.selectedViewType == ScheduleViewType.exams)
                const Icon(Icons.check, size: 20, color: AppColors.blue),
            ],
          ),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }

  Widget _buildExamsHeader(MainGroup scheduleData) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scheduleData.startExamsDate != null
                    ? 'Начало: ${scheduleData.startExamsDate}'
                    : 'Даты не указаны',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                scheduleData.endExamsDate != null
                    ? 'Окончание: ${scheduleData.endExamsDate}'
                    : 'Семестр: дата не указана',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context, MainGroupData state) {
    final cubit = context.read<MainGroupCubit>();

    switch (state.selectedViewType) {
      case ScheduleViewType.schedule:
        return ScheduleView(
          state: state,
          cubit: cubit,
          scrollController: _scrollController,
          onLessonTap: (schedule) => _onLessonTap(context, cubit, schedule),
        );
      case ScheduleViewType.daily:
        return DailyView(
          state: state,
          cubit: cubit,
          scrollController: _scrollController,
          onLessonTap: (schedule) => _onLessonTap(context, cubit, schedule),
        );
      case ScheduleViewType.exams:
        return ExamsView(
          state: state,
          cubit: cubit,
          scrollController: _scrollController,
          onLessonTap: (schedule) => _onLessonTap(context, cubit, schedule),
        );
    }
  }
}