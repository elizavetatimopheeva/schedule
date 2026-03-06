// import 'package:bsuir/domain/entity/schedule.dart';
// import 'package:bsuir/resourses/app_colors.dart';
// import 'package:bsuir/resourses/app_fonts.dart';
// import 'package:bsuir/resourses/app_images.dart';
// import 'package:bsuir/ui/widgets/inherited/provider.dart';
// import 'package:bsuir/ui/widgets/main_group/main_group_model.dart';
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
//   int _weeksToShow = 2;
//   bool _hasMoreWeeks = true;

//   @override
//   void initState() {
//     super.initState();
//     final model = NotifierProvider.read<MainGroupModel>(context);
//     model?.loadMainGroup().catchError((error) {
//       print('Ошибка загрузки: $error');
//     });
//     _scrollController.addListener(_scrollListener);
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

//   void _onLessonTap(Schedule schedule) {
//     print('Lesson tapped: ${schedule.subject}');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final model = NotifierProvider.watch<MainGroupModel>(context);
//     final scheduleData = model?.mainGroup;
//     final errorMessage = model?.errorMessage;

//     if (errorMessage != null) {
//       return _buildErrorWidget(errorMessage, model!);
//     }

//     if (scheduleData == null) {
//       return _buildLoadingWidget();
//     }

//     if (!model!.hasData()) {
//       return _buildNoDataWidget();
//     }

//     if (!model.hasSchedules()) {
//       return _buildNoScheduleWidget();
//     }

//     final currentWeek = model.getCurrentWeekNumber(scheduleData.startDate);
//     final absoluteWeek = model.getAbsoluteWeekNumber(scheduleData.startDate);
//     final semesterStarted = model.hasSemesterStarted();
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

//     if (semesterStarted) {
//       // СЕМЕСТР УЖЕ НАЧАЛСЯ
//       // 1. Показываем сегодняшний день
//       final dayName = startRussianName;
//       final todayDateStr = DateFormat('dd.MM.yyyy').format(startDisplayDate);
//       final weekNumber = model.getWeekNumberForCurrentWeek(
//         scheduleData.startDate,
//       );

//       final daySchedules = model.getAllSchedulesForDayAuto(
//         scheduleData.schedules,
//         scheduleData.exams,
//         dayName,
//         weekNumber,
//         todayDateStr,
//       );

//       final isSemesterEnded = scheduleData.endDate != null
//           ? !model.isDateValid(startDisplayDate, scheduleData.endDate!)
//           : false;

//       if (isSemesterEnded) {}
//       validItems.add(
//         _buildDaySection(
//           model,
//           dayName,
//           '$todayDateStr (сегодня)',
//           daySchedules,
//           weekNumber,
//           0,
//           true, // isStartDay
//           isSemesterEnded,
//           semesterStarted: semesterStarted,
//         ),
//       );

//       // 2. Показываем оставшиеся дни текущей недели
//       if (startIndex < allDays.length - 1) {
//         final remainingDays = allDays.sublist(startIndex + 1);

//         for (final dayName in remainingDays) {
//           if (model.isDayValidForCurrentWeek(dayName, scheduleData.endDate)) {
//             final weekNumber = model.getWeekNumberForCurrentWeek(
//               scheduleData.startDate,
//             );
//             final date = model.getDateForCurrentWeekDay(
//               dayName,
//               scheduleData.endDate,
//             );
//             final dateOnly = date.replaceAll(' (семестр окончен)', '');

//             final daySchedules = model.getAllSchedulesForDayAuto(
//               scheduleData.schedules,
//               scheduleData.exams,
//               dayName,
//               weekNumber,
//               dateOnly,
//             );

//             final isSemesterEnded = date.contains('семестр окончен');

//             validItems.add(
//               _buildDaySection(
//                 model,
//                 dayName,
//                 date,
//                 daySchedules,
//                 weekNumber,
//                 0,
//                 false,
//                 isSemesterEnded,
//                 semesterStarted: semesterStarted,
//               ),
//             );
//           }
//         }
//       }

//       // 3. Показываем следующие недели, начиная со следующей недели
//       for (int weekOffset = 1; weekOffset <= _weeksToShow; weekOffset++) {
//         bool weekHasValidDays = false;

//         for (final dayName in allDays) {
//           if (model.isDayValidForFutureWeek(
//             dayName,
//             weekOffset,
//             scheduleData.endDate,
//           )) {
//             final weekNumber = model.getWeekNumberForFutureWeek(
//               weekOffset,
//               scheduleData.startDate,
//             );
//             final date = model.getDateForFutureWeekDay(
//               dayName,
//               weekOffset,
//               scheduleData.endDate,
//             );
//             final dateOnly = date.replaceAll(' (семестр окончен)', '');

//             final daySchedules = model.getAllSchedulesForDayAuto(
//               scheduleData.schedules,
//               scheduleData.exams,
//               dayName,
//               weekNumber,
//               dateOnly,
//             );

//             final isSemesterEnded = date.contains('семестр окончен');

//             validItems.add(
//               _buildDaySection(
//                 model,
//                 dayName,
//                 date,
//                 daySchedules,
//                 weekNumber,
//                 weekOffset, // для отображения: 1, 2, 3...
//                 false,
//                 isSemesterEnded,
//                 semesterStarted: semesterStarted,
//               ),
//             );

//             weekHasValidDays = true;
//           }
//         }

//         if (!weekHasValidDays) {
//           _hasMoreWeeks = false;
//           break;
//         }
//       }
//     } else {
//       // СЕМЕСТР ЕЩЕ НЕ НАЧАЛСЯ

//       // Показываем недели, начиная с недели начала
//       for (int weekOffset = 0; weekOffset < _weeksToShow; weekOffset++) {
//         bool weekHasValidDays = false;

//         for (final dayName in allDays) {
//           if (model.isDayValidForFutureWeek(
//             dayName,
//             weekOffset,
//             scheduleData.endDate,
//           )) {
//             final weekNumber = model.getWeekNumberForFutureWeek(
//               weekOffset,
//               scheduleData.startDate,
//             );
//             final date = model.getDateForFutureWeekDay(
//               dayName,
//               weekOffset,
//               scheduleData.endDate,
//             );
//             final dateOnly = date.replaceAll(' (семестр окончен)', '');

//             final daySchedules = model.getAllSchedulesForDayAuto(
//               scheduleData.schedules,
//               scheduleData.exams,
//               dayName,
//               weekNumber,
//               dateOnly,
//             );

//             final isSemesterEnded = date.contains('семестр окончен');
//             final isStartDay = weekOffset == 0 && dayName == startRussianName;

//             validItems.add(
//               _buildDaySection(
//                 model,
//                 dayName,
//                 date,
//                 daySchedules,
//                 weekNumber,
//                 weekOffset + 1, // для отображения: 1, 2, 3...
//                 isStartDay,
//                 isSemesterEnded,
//                 semesterStarted: semesterStarted,
//               ),
//             );

//             weekHasValidDays = true;
//           }
//         }

//         if (!weekHasValidDays) {
//           _hasMoreWeeks = false;
//           break;
//         }
//       }
//     }

//     return Scaffold(
//       backgroundColor: AppColors.greyBackground,
//       appBar: AppBar(
//         centerTitle: true,
//         title: Column(
//           children: [
//             Text(
//               '${scheduleData.studentGroupDto?.name}',
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 14,
//                 height: 1.3,
//                 fontFamily: AppFonts.montserrat,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//         actions: const [
//           Icon(Icons.star, color: AppColors.blue),
//           SizedBox(width: 30),
//           Icon(Icons.group_work, color: AppColors.blue),
//           SizedBox(width: 20),
//         ],
//         backgroundColor: AppColors.greyBackground,
//       ),
//       body: Column(
//         children: [
//           if (!model.isZaochOrDist)
//             SizedBox.shrink()
//           else
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
//           Expanded(
//             child: validItems.isEmpty
//                 ? _buildNoScheduleWidget()
//                 : ListView(controller: _scrollController, children: validItems),
//           ),
//         ],
//       ),
//     );
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

//   Widget _buildErrorWidget(String errorMessage, MainGroupModel model) {
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
//           const SizedBox(height: 8),
//           const Text(
//             'На выбранный период пар нет',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDaySection(
//     MainGroupModel model,
//     String dayName,
//     String date,
//     List<Schedule> schedules,
//     int weekNumber,
//     int displayWeekOffset,
//     bool isStartDay, //????????????????????????????????????/
//     bool isSemesterEnded, {
//     required bool semesterStarted,
//   }) {
//     return isSemesterEnded
//         ? SizedBox(
//             height: 600,
//             child: ColoredBox(
//               color: AppColors.greyBackground,
//               child: Center(child: Text('Похоже, что пары закончились!')),
//             ),
//           )
//         : schedules.isEmpty
//         ? SizedBox.shrink()
//         : Container(
//             margin: const EdgeInsets.all(8),
//             //decoration: BoxDecoration(color: AppColors.white),
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
//                                       color: Colors.blue,
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
//                               '$date${!model.isZaochOrDist ? ', Неделя: $weekNumber' : ''}',
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
//                         (schedule) =>
//                             _buildLessonCard(model, schedule, isSemesterEnded),
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
//   ) {
//     final isAnnouncement = model.isAnnouncement(schedule);
//     final isZaochGroup = model.isZaochOrDist;
//     final teacherImage = model.getTeacherImage(schedule.employees);
//     final employeeName = model.getEmployeeNameFromList(schedule.employees);
//     final subjectName = model.getSubjectName(schedule);
//     final lessonType = model.getLessonType(schedule);

//     final isExam =
//         (schedule.lessonTypeAbbrev == null ||
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('экз'));
//     final isConsult =
//         (schedule.lessonTypeAbbrev == null ||
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('конс'));
//     final isLecture =
//         schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('лк');
//     final isPractice =
//         schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('пз');
//     final isLab =
//         schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('лр');

//     final specificDate = (isAnnouncement || isZaochGroup)
//         ? model.getAnnouncementDate(schedule)
//         : null;

//     return InkWell(
//       onTap: () => _onLessonTap(schedule),
//       child: Container(
//         margin: const EdgeInsets.only(right: 12, left: 12, top: 2, bottom: 2),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         // const EdgeInsets.all(10),
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
//                   style: TextStyle(
//                     fontSize: 13,
//                     //fontWeight: FontWeight.w500,
//                     color: AppColors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 1),
//                 Text(
//                   schedule.endLessonTime ?? '--:--',
//                   style: TextStyle(
//                     fontSize: 11,
//                     //fontWeight: FontWeight.w500,
//                     color: AppColors.black,
//                   ),
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
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.black,
//                         ),
//                       ),
//                       if (schedule.numSubgroup == 0)
//                         SizedBox.shrink()
//                       else
//                         Row(
//                           children: [
//                             SizedBox(width: 8),
//                             Icon(
//                               Icons.person,
//                               color: AppColors.greyText,
//                               size: 18,
//                             ),
//                             SizedBox(width: 3),
//                             Text('${schedule.numSubgroup}'),
//                           ],
//                         ),
//                     ],
//                   ),
//                   //const SizedBox(height: 2),
//                   isAnnouncement
//                       ? SizedBox.shrink()
//                       : Text(
//                           lessonType,
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: _getLessonTypeColor(
//                               isExam,
//                               isConsult,
//                               isLecture,
//                               isPractice,
//                               isLab,
//                               isSemesterEnded,
//                             ),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
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
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.greyText,
//                           ),
//                         ),
//                       ],
//                     ),
//                   if (schedule.note != null && schedule.note!.isNotEmpty)
//                     Text(
//                       schedule.note!,
//                       style: TextStyle(fontSize: 10, color: AppColors.greyText),
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
//                         // width: 45,
//                         // height: 45,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Icon(
//                             Icons.person_outline,
//                             color: Colors.grey[400],
//                             size: 20,
//                           );
//                         },
//                       )
//                     : Icon(
//                         Icons.person_outline,
//                         color: Colors.grey[400],
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
//   ) {
//     if (isConsult) return Colors.brown;
//     if (isSemesterEnded) return Colors.grey;
//     if (isExam) return Colors.purple;
//     if (isLecture) return Colors.green;
//     if (isPractice) return Colors.red;
//     if (isLab) return Colors.orange;
//     return AppColors.black;
//   }
// }

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
//   int _weeksToShow = 2;
//   bool _hasMoreWeeks = true;

//   // Тип отображения: 0 - расписание, 1 - по дням, 2 - экзамены
//   int _selectedViewType = 0;

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

//     // Определяем начальный тип отображения
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _determineInitialViewType();
//     });
//   }

//   void _determineInitialViewType() {
//     final model = NotifierProvider.read<MainGroupModel>(context);
//     if (model == null || model.mainGroup == null) return;

//     setState(() {
//       if (model.isZaochOrDist || model.isSemesterEnded()) {
//         _selectedViewType = 2;
//       } else {
//         _selectedViewType = 0;
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
//     print('Lesson tapped: ${schedule.subject}');
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => LessonInfo(model, schedule),
//       isScrollControlled: true,
//     );
//   }

//   // String _getAppBarTitle(MainGroupModel model, MainGroup scheduleData) {
//   //   switch (_selectedViewType) {
//   //     case 0:
//   //       return 'Расписание ${scheduleData.studentGroupDto?.name}';
//   //     case 1:
//   //       return 'Расписание по дням';
//   //     case 2:
//   //       return 'Экзамены ${scheduleData.studentGroupDto?.name}';
//   //     default:
//   //       return 'Расписание';
//   //   }
//   // }

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

//     return Scaffold(
//       backgroundColor: AppColors.greyBackground,
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           '${model?.groupNumber}',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 14,
//             height: 1.3,
//             fontFamily: AppFonts.montserrat,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: [
//           // const Icon(Icons.star, color: AppColors.blue),
//           IconButton(
//             icon: Icon(
//               model?.isFavorite == true ? Icons.star : Icons.star_border,
//               color: model?.isFavorite == true ? Colors.amber : AppColors.blue,
//             ),
//             onPressed: () async {
//               if (model != null) {
//                 await model.toggleFavorite();
//                 // // Можно показать SnackBar для обратной связи
//                 // ScaffoldMessenger.of(context).showSnackBar(
//                 //   SnackBar(
//                 //     content: Text(
//                 //       model.isFavorite
//                 //           ? 'Группа добавлена в избранное'
//                 //           : 'Группа удалена из избранного',
//                 //     ),
//                 //     duration: const Duration(seconds: 2),
//                 //   ),

//               }
//             },
//           ),

//           const SizedBox(width: 17),
//           const Icon(Icons.group_work, color: AppColors.blue),
//           // const SizedBox(width: 2),
//           // PopupMenuButton для выбора типа отображения
//           PopupMenuButton<int>(
//             onSelected: (value) {
//               setState(() {
//                 _selectedViewType = value;
//               });
//             },
//             itemBuilder: (context) => [
//               // Расписание
//               PopupMenuItem(
//                 value: 0,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Расписание'),
//                     if (_selectedViewType == 0)
//                       const Icon(Icons.check, size: 20, color: AppColors.blue),
//                   ],
//                 ),
//               ),
//               // По дням
//               PopupMenuItem(
//                 value: 1,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('По дням'),
//                     if (_selectedViewType == 1)
//                       const Icon(Icons.check, size: 20, color: AppColors.blue),
//                   ],
//                 ),
//               ),
//               // Экзамены
//               PopupMenuItem(
//                 value: 2,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Экзамены'),
//                     if (_selectedViewType == 2)
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
//       body: !model!.hasData()
//           ? _buildNoDataWidget()
//           : !model.hasSchedules()
//           ? _buildNoScheduleWidget()
//           : Column(
//               children: [
//                 if (!model.isZaochOrDist && _selectedViewType != 2)
//                   const SizedBox.shrink()
//                 else if (_selectedViewType == 2)
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               scheduleData.startExamsDate != null
//                                   ? 'Начало: ${scheduleData.startExamsDate}'
//                                   : 'Даты не указаны',
//                               style: TextStyle(color: Colors.grey[600]),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               scheduleData.endExamsDate != null
//                                   ? 'Окончание: ${scheduleData.endExamsDate}'
//                                   : 'Семестр: дата не указана',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 Expanded(child: _buildBodyContent(model, scheduleData)),
//               ],
//             ),
//     );
//   }

//   Widget _buildBodyContent(MainGroupModel model, MainGroup scheduleData) {
//     switch (_selectedViewType) {
//       case 0:
//         return _buildScheduleView(model, scheduleData);
//       case 1:
//         return _buildDailyView(model, scheduleData);
//       case 2:
//         return _buildExamsView(model, scheduleData);
//       default:
//         return _buildScheduleView(model, scheduleData);
//     }
//   }

//   Widget _buildScheduleView(MainGroupModel model, MainGroup scheduleData) {
//     //final currentWeek = model.getCurrentWeekNumber(scheduleData.startDate);
//     // final absoluteWeek = model.getAbsoluteWeekNumber(scheduleData.startDate);
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
//     //bool sem = model.mainGroup!.schedules!.isNotEmpty;

//     final validItems = <Widget>[];
//     if (hasMainSchedules) {
//       if (semesterStarted) {
//         // СЕМЕСТР УЖЕ НАЧАЛСЯ
//         // 1. Показываем сегодняшний день
//         final dayName = startRussianName;
//         final todayDateStr = DateFormat('dd.MM.yyyy').format(startDisplayDate);
//         final weekNumber = model.getWeekNumberForCurrentWeek(
//           scheduleData.startDate,
//         );

//         final daySchedules = model.getAllSchedulesForDayAuto(
//           scheduleData.schedules,
//           scheduleData.exams,
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
//             true, // isStartDay
//             isSemesterEnded,
//             semesterStarted: semesterStarted,
//           ),
//         );

//         // 2. Показываем оставшиеся дни текущей недели
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

//               final daySchedules = model.getAllSchedulesForDayAuto(
//                 scheduleData.schedules,
//                 scheduleData.exams,
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

//         // 3. Показываем следующие недели, начиная со следующей недели
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

//               final daySchedules = model.getAllSchedulesForDayAuto(
//                 scheduleData.schedules,
//                 scheduleData.exams,
//                 dayName,
//                 weekNumber,
//                 dateOnly,
//               );

//               // final isSemesterEnded = date.contains('семестр окончен');

//               validItems.add(
//                 _buildDaySection(
//                   model,
//                   dayName,
//                   date,
//                   daySchedules,
//                   weekNumber,
//                   weekOffset, // для отображения: 1, 2, 3...
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
//         // СЕМЕСТР ЕЩЕ НЕ НАЧАЛСЯ

//         // Показываем недели, начиная с недели начала
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

//               final daySchedules = model.getAllSchedulesForDayAuto(
//                 scheduleData.schedules,
//                 scheduleData.exams,
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
//                   weekOffset + 1, // для отображения: 1, 2, 3...
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

//     // В режиме "по дням" показываем ВСЕ 4 недели
//     // Группируем занятия по дням и неделям
//     final Map<String, Map<int, List<Schedule>>> schedulesByDayAndWeek = {};

//     // Собираем все занятия для всех 4 недель
//     for (int weekNumber = 1; weekNumber <= 4; weekNumber++) {
//       for (final dayName in allDays) {
//         // Получаем расписание для этого дня и этой недели
//         final daySchedules = model.getScheduleForDayAndWeek(
//           scheduleData.schedules,
//           dayName,
//           weekNumber,
//         );

//         if (daySchedules.isNotEmpty) {
//           if (!schedulesByDayAndWeek.containsKey(dayName)) {
//             schedulesByDayAndWeek[dayName] = {};
//           }
//           schedulesByDayAndWeek[dayName]![weekNumber] = daySchedules;
//         }
//       }
//     }

//     // Также добавляем объявления
//     if (scheduleData.schedules != null) {
//       for (final daySchedules in scheduleData.schedules!.values) {
//         for (final schedule in daySchedules) {
//           if (schedule.announcement == true) {
//             final announcementDate = schedule.startLessonDate;
//             if (announcementDate != null && announcementDate.isNotEmpty) {
//               // Определяем день недели для объявления
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
//               } catch (e) {
//                 // Если не удалось распарсить дату, пропускаем
//               }
//             }
//           }
//         }
//       }
//     }

//     // Сортируем дни недели в правильном порядке
//     final sortedDays = allDays
//         .where((day) => schedulesByDayAndWeek.containsKey(day))
//         .toList();

//     for (final dayName in sortedDays) {
//       final weeksForDay = schedulesByDayAndWeek[dayName]!;
//       final weekNumbers = weeksForDay.keys.toList()..sort();

//       // Для каждого дня показываем все недели
//       for (final weekNumber in weekNumbers) {
//         final daySchedules = weeksForDay[weekNumber]!;

//         // Сортируем по времени
//         daySchedules.sort((a, b) {
//           final timeA = a.startLessonTime ?? '';
//           final timeB = b.startLessonTime ?? '';
//           return timeA.compareTo(timeB);
//         });

//         // Создаем заголовок для дня и недели
//         String dateDisplay;
//         if (weekNumber == 0) {
//           dateDisplay = 'Объявления';
//         } else {
//           // Получаем дату для этого дня и недели
//           try {
//             // Для упрощения используем текущую дату как базовую
//             final now = DateTime.now();
//             final mondayOfCurrentWeek = now.subtract(
//               Duration(days: now.weekday - 1),
//             );
//             final startDate = model.parseDate(scheduleData.startDate ?? '');

//             // Вычисляем неделю от начала семестра
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
//             forceWeekNumber:
//                 weekNumber, // Принудительно передаем номер недели для отображения
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

//     // Группируем экзамены по датам
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

//     // Сортируем даты
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

//     // Создаем виджеты для каждой даты
//     for (final date in sortedDates) {
//       final examsForDate = examsByDate[date]!;
//       final dayName = model.getDayNameFromDate(date);

//       validItems.add(
//         _buildDaySection(
//           model,
//           dayName,
//           date,
//           examsForDate,
//           1, // Для экзаменов номер недели не важен
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
//     int? forceWeekNumber, // Принудительный номер недели для отображения
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
//                                   : '$date${!model.isZaochOrDist && !isExamView && effectiveWeekNumber > 0 ? ', Неделя: $effectiveWeekNumber' : ''}',
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
//     int? weekNumberForDisplay, // null = не показывать номер недели
//   ) {
//     final isAnnouncement = model.isAnnouncement(schedule);
//     //final isZaochGroup = model.isZaochOrDist;
//     final teacherImage = model.getTeacherImage(schedule.employees);
//     // final employeeName = model.getEmployeeNameFromList(schedule.employees);
//     final subjectName = model.getSubjectName(schedule);
//     final lessonType = model.getLessonType(schedule);

//     final isExam =
//         // isExamView ||
//         (schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('экз'));
//     final isConsult =
//         (schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('конс'));
//     final isLecture =
//         schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('лк');
//     final isPractice =
//         schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('пз');
//     final isLab =
//         schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('лр');

//     // final specificDate = (isAnnouncement || isZaochGroup)
//     //     ? model.getAnnouncementDate(schedule)
//     //     : null;

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
//                   style: TextStyle(fontSize: 13, color: AppColors.black),
//                 ),
//                 const SizedBox(height: 1),
//                 Text(
//                   schedule.endLessonTime ?? '--:--',
//                   style: TextStyle(fontSize: 11, color: AppColors.black),
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
//                         style: TextStyle(
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
//                   // Показываем номер недели, если передан
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
//                   // ],
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
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.greyText,
//                           ),
//                         ),
//                       ],
//                     ),
//                   if (schedule.note != null && schedule.note!.isNotEmpty)
//                     Text(
//                       schedule.note!,
//                       style: TextStyle(fontSize: 10, color: AppColors.greyText),
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
//                           return Icon(
//                             Icons.person_outline,
//                             color: Colors.grey[400],
//                             size: 20,
//                           );
//                         },
//                       )
//                     : Icon(
//                         Icons.person_outline,
//                         color: Colors.grey[400],
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
//     return Material(
//       color: AppColors.greyBackground,
//       child: Center(
//         child: CircularProgressIndicator(color: AppColors.greyText),
//       ),
//     );
//   }

//   Widget _buildErrorWidget(MainGroupModel model) {
//     return Material(
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
//     return Material(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.info_outline, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text(
//               'Нет данных',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Расписание для этой группы не найдено',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoScheduleWidget() {
//     return Material(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.sentiment_satisfied_alt_outlined,
//               size: 64,
//               color: Colors.grey,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Расписание отсутствует',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             // const Text(
//             //   'На выбранный период пар нет',
//             //   textAlign: TextAlign.center,
//             //   style: TextStyle(fontSize: 14, color: Colors.grey),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }

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
//   int _weeksToShow = 2;
//   bool _hasMoreWeeks = true;

//   // Тип отображения: 0 - расписание, 1 - по дням, 2 - экзамены
//   int _selectedViewType = 0;

//   bool _viewTypeInitialized = false;
//   bool _viewTypeReady = false;

//   @override
//   void initState() {
//     super.initState();
//     final model = NotifierProvider.read<MainGroupModel>(context);
//     model?.loadMainGroup();
//     // .catchError((error) {
//     //   print('Ошибка загрузки: $error');
//     // });
//     _scrollController.addListener(_scrollListener);

//     // // Определяем начальный тип отображения
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   _determineInitialViewType();
//     // });
//   }

//   void _determineInitialViewType() {
//     final model = NotifierProvider.read<MainGroupModel>(context);
//     if (model == null || model.mainGroup == null) return;

//     setState(() {
//       if (model.isZaochOrDist || model.isSemesterEnded()) {
//         _selectedViewType = 2;
//       } else {
//         _selectedViewType = 0;
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
//       builder: (context) => LessonInfo(model, schedule),
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

//     return Scaffold(
//       backgroundColor: AppColors.greyBackground,
//       appBar: AppBar(
//         centerTitle: true,
//         title: Text(
//           '${model?.groupNumber}',
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
//               model?.isFavorite == true ? Icons.star : Icons.star_border,
//               color: model?.isFavorite == true
//                   ? AppColors.blue
//                   : AppColors.blue,
//             ),
//             onPressed: () async {
//               if (model != null) {
//                 await model.toggleFavorite();
//               }
//             },
//           ),

//           const SizedBox(width: 17),
//           const Icon(Icons.group_work, color: AppColors.blue),
//           popUpMenuButton(),
//         ],
//         backgroundColor: AppColors.greyBackground,
//       ),
//       body: !model!.hasData()
//           ? _buildNoDataWidget()
//           : !model.hasSchedules()
//           ? _buildNoScheduleWidget()
//           : Column(
//               children: [
//                 if (!model.isZaochOrDist && _selectedViewType != 2)
//                   const SizedBox.shrink()
//                 else if (_selectedViewType == 2)
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               scheduleData.startExamsDate != null
//                                   ? 'Начало: ${scheduleData.startExamsDate}'
//                                   : 'Даты не указаны',
//                               style: TextStyle(color: AppColors.greyText),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               scheduleData.endExamsDate != null
//                                   ? 'Окончание: ${scheduleData.endExamsDate}'
//                                   : 'Семестр: дата не указана',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: AppColors.greyText,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 Expanded(child: _buildBodyContent(model, scheduleData)),
//               ],
//             ),
//     );
//   }

//   PopupMenuButton<int> popUpMenuButton() {
//     return PopupMenuButton<int>(
//       onSelected: (value) {
//         setState(() {
//           _selectedViewType = value;
//         });
//       },
//       itemBuilder: (context) => [
//         // Расписание
//         PopupMenuItem(
//           value: 0,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Расписание'),
//               if (_selectedViewType == 0)
//                 const Icon(Icons.check, size: 20, color: AppColors.blue),
//             ],
//           ),
//         ),
//         // По дням
//         PopupMenuItem(
//           value: 1,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('По дням'),
//               if (_selectedViewType == 1)
//                 const Icon(Icons.check, size: 20, color: AppColors.blue),
//             ],
//           ),
//         ),
//         // Экзамены
//         PopupMenuItem(
//           value: 2,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Экзамены'),
//               if (_selectedViewType == 2)
//                 const Icon(Icons.check, size: 20, color: AppColors.blue),
//             ],
//           ),
//         ),
//       ],
//       icon: const Icon(Icons.more_vert),
//     );
//   }

//   Widget _buildBodyContent(MainGroupModel model, MainGroup scheduleData) {
//     switch (_selectedViewType) {
//       case 0:
//         return _buildScheduleView(model, scheduleData);
//       case 1:
//         return _buildDailyView(model, scheduleData);
//       case 2:
//         return _buildExamsView(model, scheduleData);
//       default:
//         return _buildScheduleView(model, scheduleData);
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
//         // СЕМЕСТР УЖЕ НАЧАЛСЯ
//         // 1. Показываем сегодняшний день
//         final dayName = startRussianName;
//         final todayDateStr = DateFormat('dd.MM.yyyy').format(startDisplayDate);
//         final weekNumber = model.getWeekNumberForCurrentWeek(
//           scheduleData.startDate,
//         );

//         final daySchedules = model.getAllSchedulesForDayAuto(
//           scheduleData.schedules,
//           scheduleData.exams,
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
//             true, // isStartDay
//             isSemesterEnded,
//             semesterStarted: semesterStarted,
//           ),
//         );

//         // 2. Показываем оставшиеся дни текущей недели
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
//               // final dateOnly = date.replaceAll(' (семестр окончен)', '');

//               final daySchedules = model.getAllSchedulesForDayAuto(
//                 scheduleData.schedules,
//                 scheduleData.exams,
//                 dayName,
//                 weekNumber,
//                 date,
//               );

//               // final isSemesterEnded = date.contains('семестр окончен');

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

//         // 3. Показываем следующие недели, начиная со следующей недели
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
//               // final dateOnly = date.replaceAll(' (семестр окончен)', '');

//               final daySchedules = model.getAllSchedulesForDayAuto(
//                 scheduleData.schedules,
//                 scheduleData.exams,
//                 dayName,
//                 weekNumber,
//                 date,
//               );

//               // final isSemesterEnded = date.contains('семестр окончен');

//               validItems.add(
//                 _buildDaySection(
//                   model,
//                   dayName,
//                   date,
//                   daySchedules,
//                   weekNumber,
//                   weekOffset, // для отображения: 1, 2, 3...
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
//         // СЕМЕСТР ЕЩЕ НЕ НАЧАЛСЯ

//         // Показываем недели, начиная с недели начала
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
//               // final dateOnly = date.replaceAll(' (семестр окончен)', '');

//               final daySchedules = model.getAllSchedulesForDayAuto(
//                 scheduleData.schedules,
//                 scheduleData.exams,
//                 dayName,
//                 weekNumber,
//                 date,
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
//                   weekOffset + 1, // для отображения: 1, 2, 3...
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

//     // Собираем все занятия для всех 4 недель
//     for (int weekNumber = 1; weekNumber <= 4; weekNumber++) {
//       for (final dayName in allDays) {
//         // Получаем расписание для этого дня и этой недели
//         final daySchedules = model.getScheduleForDayAndWeek(
//           scheduleData.schedules,
//           dayName,
//           weekNumber,
//         );

//         if (daySchedules.isNotEmpty) {
//           if (!schedulesByDayAndWeek.containsKey(dayName)) {
//             schedulesByDayAndWeek[dayName] = {};
//           }
//           schedulesByDayAndWeek[dayName]![weekNumber] = daySchedules;
//         }
//       }
//     }

//     // // Также добавляем объявления
//     // if (scheduleData.schedules != null) {
//     //   for (final daySchedules in scheduleData.schedules!.values) {
//     //     for (final schedule in daySchedules) {
//     //       if (schedule.announcement == true) {
//     //         final announcementDate = schedule.startLessonDate;
//     //         if (announcementDate != null && announcementDate.isNotEmpty) {
//     //           // Определяем день недели для объявления
//     //           try {
//     //             final date = DateFormat('dd.MM.yyyy').parse(announcementDate);
//     //             final dayName = model.getRussianDayName(date);

//     //             if (!schedulesByDayAndWeek.containsKey(dayName)) {
//     //               schedulesByDayAndWeek[dayName] = {};
//     //             }
//     //             if (!schedulesByDayAndWeek[dayName]!.containsKey(0)) {
//     //               schedulesByDayAndWeek[dayName]![0] = [];
//     //             }
//     //             schedulesByDayAndWeek[dayName]![0]!.add(schedule);
//     //           } catch (e) {
//     //             // Если не удалось распарсить дату, пропускаем
//     //           }
//     //         }
//     //       }
//     //     }
//     //   }
//     // }

//     // Сортируем дни недели в правильном порядке
//     final sortedDays = allDays
//         .where((day) => schedulesByDayAndWeek.containsKey(day))
//         .toList();

//     for (final dayName in sortedDays) {
//       final weeksForDay = schedulesByDayAndWeek[dayName]!;
//       final weekNumbers = weeksForDay.keys.toList()..sort();

//       // Для каждого дня показываем все недели
//       for (final weekNumber in weekNumbers) {
//         final daySchedules = weeksForDay[weekNumber]!;

//         // Сортируем по времени
//         daySchedules.sort((a, b) {
//           final timeA = a.startLessonTime ?? '';
//           final timeB = b.startLessonTime ?? '';
//           return timeA.compareTo(timeB);
//         });

//         // Создаем заголовок для дня и недели
//         String dateDisplay;
//         if (weekNumber == 0) {
//           dateDisplay = 'Объявления';
//         } else {
//           // Получаем дату для этого дня и недели
//           try {
//             // Для упрощения используем текущую дату как базовую
//             final now = DateTime.now();
//             final mondayOfCurrentWeek = now.subtract(
//               Duration(days: now.weekday - 1),
//             );
//             final startDate = model.parseDate(scheduleData.startDate ?? '');

//             // Вычисляем неделю от начала семестра
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
//             forceWeekNumber:
//                 weekNumber, // Принудительно передаем номер недели для отображения
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

//     // Группируем экзамены по датам
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

//     // Сортируем даты
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

//     // Создаем виджеты для каждой даты
//     for (final date in sortedDates) {
//       final examsForDate = examsByDate[date]!;
//       final dayName = model.getDayNameFromDate(date);

//       validItems.add(
//         _buildDaySection(
//           model,
//           dayName,
//           date,
//           examsForDate,
//           1, // Для экзаменов номер недели не важен
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
//     int? forceWeekNumber, // Принудительный номер недели для отображения
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
//                                   : '$date${!model.isZaochOrDist && !isExamView && effectiveWeekNumber > 0 ? ', Неделя: $effectiveWeekNumber' : ''}',
//                               style: TextStyle(
//                                 color: Colors.black,
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
//     final teacherImage = model.getTeacherImage(schedule.employees);
//     final subjectName = model.getSubjectName(schedule);
//     final lessonType = model.getLessonType(schedule);

//     final isExam =
//         (schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('экз'));
//     final isConsult =
//         (schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('конс'));
//     final isLecture =
//         schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('лк');
//     final isPractice =
//         schedule.lessonTypeAbbrev != null &&
//         schedule.lessonTypeAbbrev!.toLowerCase().contains('пз');
//     final isLab =
//         schedule.lessonTypeAbbrev != null &&
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
//                   style: TextStyle(fontSize: 13, color: AppColors.black),
//                 ),
//                 const SizedBox(height: 1),
//                 Text(
//                   schedule.endLessonTime ?? '--:--',
//                   style: TextStyle(fontSize: 11, color: AppColors.black),
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
//                         style: TextStyle(
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
//                   // ],
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
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.greyText,
//                           ),
//                         ),
//                       ],
//                     ),
//                   if (schedule.note != null && schedule.note!.isNotEmpty)
//                     Text(
//                       schedule.note!,
//                       style: TextStyle(fontSize: 10, color: AppColors.greyText),
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
//                           return Icon(
//                             Icons.person_outline,
//                             color: Colors.grey[400],
//                             size: 20,
//                           );
//                         },
//                       )
//                     : Icon(
//                         Icons.person_outline,
//                         color: Colors.grey[400],
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
//     return Material(
//       color: AppColors.greyBackground,
//       child: Center(
//         child: CircularProgressIndicator(color: AppColors.greyText),
//       ),
//     );
//   }

//   Widget _buildErrorWidget(MainGroupModel model) {
//     return Material(
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
//     return Material(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.info_outline, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text(
//               'Нет данных',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Расписание для этой группы не найдено',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoScheduleWidget() {
//     return Material(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.sentiment_satisfied_alt_outlined,
//               size: 64,
//               color: Colors.grey,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Расписание отсутствует',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//           ],
//         ),
//       ),
//     );
//   }
// }









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
//   final List<String> _allDays = const [
//     'Понедельник',
//     'Вторник',
//     'Среда',
//     'Четверг',
//     'Пятница',
//     'Суббота',
//   ];

//   int _weeksToShow = 2;
//   ScheduleViewType _selectedViewType = ScheduleViewType.schedule;
//   bool _isViewTypeDetermined = false;

//   @override
//   void initState() {
//     super.initState();
//     final model = NotifierProvider.read<MainGroupModel>(context);
//     model?.loadMainGroup();
//     _scrollController.addListener(_scrollListener);
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
//         scheduleData?.endDate != null) {
//       setState(() => _weeksToShow += 1);
//     }
//   }

//   void _onLessonTap(MainGroupModel model, Schedule schedule) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => LessonInfo(model, schedule),
//       isScrollControlled: true,
//     );
//   }

//   void _determineInitialViewType() {
//     final model = NotifierProvider.read<MainGroupModel>(context);
//     if (model == null || model.mainGroup == null || _isViewTypeDetermined)
//       return;

//     setState(() {
//       _isViewTypeDetermined = true;
//       _selectedViewType = (model.isZaochOrDist || model.isSemesterEnded())
//           ? ScheduleViewType.exams
//           : ScheduleViewType.schedule;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final model = NotifierProvider.watch<MainGroupModel>(context);
//     final scheduleData = model?.mainGroup;

//     // Определяем начальный тип отображения
//     if (!_isViewTypeDetermined && scheduleData != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _determineInitialViewType();
//       });
//     }

//     // Обработка состояний
//     if (model?.errorMessage != null) {
//       return _buildErrorWidget(model!);
//     }

//     if (!_isViewTypeDetermined || scheduleData == null) {
//       return _buildLoadingWidget();
//     }

//     // if (!model!.hasData()) {
//     //   return _buildNoDataWidget();
//     // }

//     // if (!model.hasSchedules()) {
//     //   return _buildNoScheduleWidget();
//     // }

//     return Scaffold(
//       backgroundColor: AppColors.greyBackground,
//       appBar: _buildAppBar(model!),
//       body: _buildBody(model, scheduleData),
//     );
//   }

//   // Строительные методы
//   AppBar _buildAppBar(MainGroupModel model) {
//     return AppBar(
//       centerTitle: true,
//       title: Text(
//         '${model.groupNumber}',
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 14,
//           height: 1.3,
//           fontFamily: AppFonts.montserrat,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//       actions: [
//         IconButton(
//           icon: Icon(
//             model.isFavorite ? Icons.star : Icons.star_border,
//             color: AppColors.blue,
//           ),
//           onPressed: () => model.toggleFavorite(),
//         ),
//         const SizedBox(width: 8),
//         const Icon(Icons.group_work, color: AppColors.blue),
//         _buildViewTypeMenu(),
//       ],
//       backgroundColor: AppColors.greyBackground,
//     );
//   }

//   Widget _buildBody(MainGroupModel model, MainGroup scheduleData) {
//     return Column(
//       children: [
//         if (_selectedViewType == ScheduleViewType.exams &&
//             scheduleData.startExamsDate != null)
//           _buildExamsHeader(scheduleData),
//         Expanded(child: _buildViewContent(model, scheduleData)),
//       ],
//     );
//   }

//   Widget _buildExamsHeader(MainGroup scheduleData) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         // crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Начало: ${scheduleData.startExamsDate ?? 'Даты не указаны'}',
//             style: TextStyle(color: AppColors.greyText),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Окончание: ${scheduleData.endExamsDate ?? 'Дата не указана'}',
//             style: const TextStyle(fontSize: 12, color: AppColors.greyText),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildViewContent(MainGroupModel model, MainGroup scheduleData) {
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
//     if (model.isSemesterEnded()) {
//       return _buildNoScheduleWidget();
//     }

//     final semesterStarted = model.hasSemesterStarted();
//     final startDate = model.getStartDisplayDate();
//     final startDayName = model.getRussianDayName(startDate);
//     final startIndex = _allDays.indexOf(startDayName);

//     final weekItems = <Widget>[];
//     final now = DateTime.now();

//     // Построение расписания по неделям
//     for (int weekOffset = 0; weekOffset < _weeksToShow; weekOffset++) {
//       final weekItemsAdded = _buildWeekSchedule(
//         model,
//         scheduleData,
//         weekOffset,
//         semesterStarted,
//         startIndex,
//         startDayName,
//         now,
//       );

//       if (weekItemsAdded.isEmpty) break;
//       weekItems.addAll(weekItemsAdded);
//     }

//     return weekItems.isEmpty
//         ? _buildNoScheduleWidget()
//         : ListView(controller: _scrollController, children: weekItems);
//   }

//   List<Widget> _buildWeekSchedule(
//     MainGroupModel model,
//     MainGroup scheduleData,
//     int weekOffset,
//     bool semesterStarted,
//     int startIndex,
//     String startDayName,
//     DateTime now,
//   ) {
//     final items = <Widget>[];
//     final startDayIndex = semesterStarted ? startIndex : 0;

//     for (int dayIndex = startDayIndex; dayIndex < _allDays.length; dayIndex++) {
//       final dayName = _allDays[dayIndex];
//       final shouldShowDay = _shouldShowDay(
//         model,
//         scheduleData,
//         dayName,
//         weekOffset,
//         semesterStarted,
//         dayIndex == startIndex && semesterStarted,
//       );

//       if (!shouldShowDay) continue;

//       final dateInfo = _getDateInfo(
//         model,
//         scheduleData,
//         dayName,
//         weekOffset,
//         semesterStarted,
//       );
//       final daySchedules = model.getAllSchedulesForDayAuto(
//         scheduleData.schedules,
//         scheduleData.exams,
//         dayName,
//         dateInfo.weekNumber,
//         dateInfo.dateString,
//       );

//       if (daySchedules.isNotEmpty) {
//         items.add(
//           _buildDaySection(
//             model,
//             DaySectionData(
//               dayName: dayName,
//               date: dateInfo.displayDate,
//               schedules: daySchedules,
//               weekNumber: dateInfo.weekNumber,
//               isStartDay: dayIndex == startIndex && semesterStarted,
//               isSemesterEnded: false,
//               semesterStarted: semesterStarted,
//             ),
//           ),
//         );
//       }
//     }

//     return items;
//   }

//   bool _shouldShowDay(
//     MainGroupModel model,
//     MainGroup scheduleData,
//     String dayName,
//     int weekOffset,
//     bool semesterStarted,
//     bool isFirstDayOfWeek,
//   ) {
//     if (weekOffset == 0 && semesterStarted && !isFirstDayOfWeek) {
//       return true; // Оставшиеся дни текущей недели
//     }

//     if (weekOffset > 0 || !semesterStarted) {
//       return true; // Все дни для будущих недель
//     }

//     return false;
//   }

//   DateInfo _getDateInfo(
//     MainGroupModel model,
//     MainGroup scheduleData,
//     String dayName,
//     int weekOffset,
//     bool semesterStarted,
//   ) {
//     final dateStr = semesterStarted && weekOffset == 0
//         ? model.getDateForCurrentWeekDay(dayName, scheduleData.endDate)
//         : model.getDateForFutureWeekDay(
//             dayName,
//             weekOffset,
//             scheduleData.endDate,
//           );

//     final weekNumber = semesterStarted && weekOffset == 0
//         ? model.getWeekNumberForCurrentWeek(scheduleData.startDate)
//         : model.getWeekNumberForFutureWeek(weekOffset, scheduleData.startDate);

//     final displayDate =
//         semesterStarted &&
//             weekOffset == 0 &&
//             dayName == model.getRussianDayName(DateTime.now())
//         ? '$dateStr (сегодня)'
//         : dateStr;

//     return DateInfo(
//       dateString: dateStr,
//       displayDate: displayDate,
//       weekNumber: weekNumber,
//     );
//   }

//   Widget _buildDailyView(MainGroupModel model, MainGroup scheduleData) {
//     final schedulesByDay = <String, Map<int, List<Schedule>>>{};

//     // Собираем расписание по дням
//     for (int weekNumber = 1; weekNumber <= 4; weekNumber++) {
//       for (final dayName in _allDays) {
//         final daySchedules = model.getScheduleForDayAndWeek(
//           scheduleData.schedules,
//           dayName,
//           weekNumber,
//         );

//         if (daySchedules.isNotEmpty) {
//           schedulesByDay.putIfAbsent(dayName, () => {})[weekNumber] =
//               daySchedules;
//         }
//       }
//     }

//     final items = <Widget>[];
//     for (final dayName in _allDays.where(schedulesByDay.containsKey)) {
//       final weeksForDay = schedulesByDay[dayName]!;
//       final weekNumbers = weeksForDay.keys.toList()..sort();

//       for (final weekNumber in weekNumbers) {
//         final daySchedules = weeksForDay[weekNumber]!..sort(_sortByTime);

//         items.add(
//           _buildDaySection(
//             model,
//             DaySectionData(
//               dayName: dayName,
//               date: 'Неделя $weekNumber',
//               schedules: daySchedules,
//               weekNumber: weekNumber,
//               isStartDay: false,
//               isSemesterEnded: false,
//               semesterStarted: true,
//               showWeekNumberInCard: true,
//             ),
//           ),
//         );
//       }
//     }

//     return items.isEmpty
//         ? _buildNoScheduleWidget()
//         : ListView(controller: _scrollController, children: items);
//   }

//   Widget _buildExamsView(MainGroupModel model, MainGroup scheduleData) {
//     if (scheduleData.exams == null || scheduleData.exams!.isEmpty) {
//       return _buildNoScheduleWidget();
//     }

//     // Группируем экзамены по датам
//     final examsByDate = <String, List<Schedule>>{};
//     for (final exam in scheduleData.exams!) {
//       final date = exam.dateLesson ?? '';
//       if (date.isNotEmpty) {
//         examsByDate.putIfAbsent(date, () => []).add(exam);
//       }
//     }

//     // Сортируем даты
//     final sortedDates = examsByDate.keys.toList()
//       ..sort((a, b) => _compareDates(a, b));

//     final items = <Widget>[];
//     for (final date in sortedDates) {
//       final examsForDate = examsByDate[date]!;
//       final dayName = model.getDayNameFromDate(date);

//       items.add(
//         _buildDaySection(
//           model,
//           DaySectionData(
//             dayName: dayName,
//             date: date,
//             schedules: examsForDate,
//             weekNumber: 1,
//             isStartDay: false,
//             isSemesterEnded: false,
//             semesterStarted: true,
//             isExamView: true,
//           ),
//         ),
//       );
//     }

//     return items.isEmpty
//         ? _buildNoScheduleWidget()
//         : ListView(controller: _scrollController, children: items);
//   }

//   int _compareDates(String a, String b) {
//     try {
//       final dateA = DateFormat('dd.MM.yyyy').parse(a);
//       final dateB = DateFormat('dd.MM.yyyy').parse(b);
//       return dateA.compareTo(dateB);
//     } catch (e) {
//       return a.compareTo(b);
//     }
//   }

//   int _sortByTime(Schedule a, Schedule b) {
//     final timeA = a.startLessonTime ?? '';
//     final timeB = b.startLessonTime ?? '';
//     return timeA.compareTo(timeB);
//   }

//   Widget _buildDaySection(MainGroupModel model, DaySectionData data) {
//     if (data.schedules.isEmpty) return const SizedBox.shrink();

//     return !model.hasData()
//         ? _buildNoDataWidget()
//         : !model.hasSchedules()
//         ? _buildNoScheduleWidget()
//         : Container(
//             margin: const EdgeInsets.all(8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Заголовок дня
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
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
//                                   data.dayName,
//                                   style: TextStyle(
//                                     color: AppColors.black,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                     height: 1.3,
//                                   ),
//                                 ),
//                                 if (data.isStartDay && data.semesterStarted)
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
//                               data.date,
//                               style: const TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 height: 1.3,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Карточки занятий
//                 Column(
//                   children: data.schedules
//                       .map(
//                         (schedule) => _buildLessonCard(model, schedule, data),
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
//     DaySectionData dayData,
//   ) {
//     final isAnnouncement = model.isAnnouncement(schedule);
//     final teacherImage = model.getTeacherImage(schedule.employees);
//     final lessonType = model.getLessonTypeEnum(schedule);

//     return InkWell(
//       onTap: () => _onLessonTap(model, schedule),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: AppColors.greyBackground),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Время
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
//             // Информация о занятии
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         isAnnouncement
//                             ? 'Объявление!'
//                             : model.getSubjectName(schedule),
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.black,
//                         ),
//                       ),
//                       if (schedule.numSubgroup != null &&
//                           schedule.numSubgroup! > 0)
//                         Row(
//                           children: [
//                             const SizedBox(width: 8),
//                             const Icon(
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
//                   if (dayData.showWeekNumberInCard && !isAnnouncement)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 2),
//                       child: Text(
//                         'Неделя: ${dayData.weekNumber}',
//                         style: const TextStyle(
//                           fontSize: 11,
//                           color: Colors.blue,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                   Text(
//                     model.getLessonTypeDisplay(schedule),
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: _getLessonTypeColor(
//                         lessonType,
//                         dayData.isSemesterEnded,
//                       ),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   if (schedule.auditories?.isNotEmpty ?? false)
//                     Row(
//                       children: [
//                         const Icon(
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
//                   if (schedule.note?.isNotEmpty ?? false)
//                     Text(
//                       schedule.note!,
//                       style: const TextStyle(
//                         fontSize: 10,
//                         color: AppColors.greyText,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             // Фото преподавателя
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

//   Color _getLessonTypeColor(LessonType type, bool isSemesterEnded) {
//     if (isSemesterEnded) return Colors.grey;

//     switch (type) {
//       case LessonType.exam:
//         return Colors.purple;
//       case LessonType.consultation:
//         return Colors.brown;
//       case LessonType.lecture:
//         return Colors.green;
//       case LessonType.practice:
//         return Colors.red;
//       case LessonType.lab:
//         return Colors.orange;
//       default:
//         return AppColors.black;
//     }
//   }

//   PopupMenuButton<ScheduleViewType> _buildViewTypeMenu() {
//     return PopupMenuButton<ScheduleViewType>(
//       onSelected: (value) => setState(() => _selectedViewType = value),
//       itemBuilder: (context) => [
//         _buildMenuItem(
//           ScheduleViewType.schedule,
//           'Расписание',
//           Icons.calendar_today,
//         ),
//         _buildMenuItem(ScheduleViewType.daily, 'По дням', Icons.view_day),
//         _buildMenuItem(ScheduleViewType.exams, 'Экзамены', Icons.assignment),
//       ],
//       icon: const Icon(Icons.more_vert),
//     );
//   }

//   PopupMenuItem<ScheduleViewType> _buildMenuItem(
//     ScheduleViewType value,
//     String text,
//     IconData icon,
//   ) {
//     return PopupMenuItem(
//       value: value,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 20, color: AppColors.blue),
//               const SizedBox(width: 8),
//               Text(text),
//             ],
//           ),
//           if (_selectedViewType == value)
//             const Icon(Icons.check, size: 20, color: AppColors.blue),
//         ],
//       ),
//     );
//   }

//   // Состояния загрузки/ошибок
//   Widget _buildLoadingWidget() {
//     return Material(
//       child: Center(
//         child: CircularProgressIndicator(color: AppColors.greyText),
//       ),
//     );
//   }

//   Widget _buildErrorWidget(MainGroupModel model) {
//     return Material(
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
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
//               const SizedBox(height: 8),
//               // Text(model.errorMessage ?? 'Неизвестная ошибка'),
//               // const SizedBox(height: 20),
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
//     return Material(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.info_outline, size: 64, color: Colors.grey),
//             const SizedBox(height: 16),
//             const Text(
//               'Нет данных',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Расписание для этой группы не найдено',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoScheduleWidget() {
//     return Material(
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.sentiment_satisfied_alt_outlined,
//               size: 64,
//               color: Colors.grey,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Расписание отсутствует',
//               style: TextStyle(fontSize: 18, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Вспомогательные классы для упрощения передачи данных
// class DaySectionData {
//   final String dayName;
//   final String date;
//   final List<Schedule> schedules;
//   final int weekNumber;
//   final bool isStartDay;
//   final bool isSemesterEnded;
//   final bool semesterStarted;
//   final bool isExamView;
//   final bool showWeekNumberInCard;

//   DaySectionData({
//     required this.dayName,
//     required this.date,
//     required this.schedules,
//     required this.weekNumber,
//     this.isStartDay = false,
//     this.isSemesterEnded = false,
//     required this.semesterStarted,
//     this.isExamView = false,
//     this.showWeekNumberInCard = false,
//   });
// }

// class DateInfo {
//   final String dateString;
//   final String displayDate;
//   final int weekNumber;

//   DateInfo({
//     required this.dateString,
//     required this.displayDate,
//     required this.weekNumber,
//   });
// }










import 'package:bsuir/domain/entity/main_group.dart';
import 'package:bsuir/domain/entity/schedule.dart';
import 'package:bsuir/resourses/app_colors.dart';
import 'package:bsuir/resourses/app_fonts.dart';
import 'package:bsuir/ui/widgets/inherited/provider.dart';
import 'package:bsuir/ui/widgets/app/main_group/main_group_model.dart';
import 'package:bsuir/ui/widgets/app/main_group/modal_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainGroupScheduleWidget extends StatefulWidget {
  const MainGroupScheduleWidget({super.key});

  @override
  State<MainGroupScheduleWidget> createState() =>
      _MainGroupScheduleWidgetState();
}

class _MainGroupScheduleWidgetState extends State<MainGroupScheduleWidget> {
  final ScrollController _scrollController = ScrollController();
  int _weeksToShow = 5;
  bool _hasMoreWeeks = true;

  ScheduleViewType _selectedViewType = ScheduleViewType.schedule;

  bool _viewTypeInitialized = false;
  bool _viewTypeReady = false;

  @override
  void initState() {
    super.initState();
    final model = NotifierProvider.read<MainGroupModel>(context);
    model?.loadMainGroup().catchError((error) {
      print('Ошибка загрузки: $error');
    });
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determineInitialViewType();
    });
  }

  void _determineInitialViewType() {
    final model = NotifierProvider.read<MainGroupModel>(context);
    if (model == null || model.mainGroup == null) return;

    setState(() {
      if (model.isSemesterEnded()) {
        _selectedViewType = ScheduleViewType.exams;
      } else {
        _selectedViewType = ScheduleViewType.schedule;
      }
      _viewTypeReady = true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final model = NotifierProvider.read<MainGroupModel>(context);
    final scheduleData = model?.mainGroup;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        _hasMoreWeeks &&
        scheduleData?.endDate != null) {
      setState(() {
        _weeksToShow += 1;
      });
    }
  }

  void _onLessonTap(MainGroupModel model, Schedule schedule) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => LessonInfo(model, schedule),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MainGroupModel>(context);
    final scheduleData = model?.mainGroup;
    final errorMessage = model?.errorMessage;

    if (!_viewTypeInitialized && scheduleData != null) {
      _viewTypeInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _determineInitialViewType();
      });
    }
    
    if (errorMessage != null) {
      return _buildErrorWidget(model!);
    }

    if (!_viewTypeReady || scheduleData == null) {
      return _buildLoadingWidget();
    }

    if (!model!.hasData()) {
      return _buildNoDataWidget();
    }

    if (!model.hasSchedules()) {
      return _buildNoScheduleWidget();
    }

    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '${model.groupNumber}',
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
              model.isFavorite ? Icons.star : Icons.star_border,
              color: model.isFavorite ? Colors.amber : AppColors.blue,
            ),
            onPressed: () async {
              if (model != null) {
                await model.toggleFavorite();
              }
            },
          ),
          const SizedBox(width: 30),
          const Icon(Icons.group_work, color: AppColors.blue),
          const SizedBox(width: 20),
          PopupMenuButton<ScheduleViewType>(
            onSelected: (value) {
              setState(() {
                _selectedViewType = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ScheduleViewType.schedule,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Расписание'),
                    if (_selectedViewType == ScheduleViewType.schedule)
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
                    if (_selectedViewType == ScheduleViewType.daily)
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
                    if (_selectedViewType == ScheduleViewType.exams)
                      const Icon(Icons.check, size: 20, color: AppColors.blue),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
        backgroundColor: AppColors.greyBackground,
      ),
      body: Column(
        children: [
          if (_selectedViewType == ScheduleViewType.exams)
            Container(
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
            ),
          Expanded(child: _buildBodyContent(model, scheduleData)),
        ],
      ),
    );
  }

  Widget _buildBodyContent(MainGroupModel model, MainGroup scheduleData) {
    switch (_selectedViewType) {
      case ScheduleViewType.schedule:
        return _buildScheduleView(model, scheduleData);
      case ScheduleViewType.daily:
        return _buildDailyView(model, scheduleData);
      case ScheduleViewType.exams:
        return _buildExamsView(model, scheduleData);
    }
  }

  Widget _buildScheduleView(MainGroupModel model, MainGroup scheduleData) {
    final semesterStarted = model.hasSemesterStarted();
    final hasMainSchedules = model.hasMainSchedules();
    final semesterEnded = model.isSemesterEnded();

    const allDays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
    ];

    final startDisplayDate = model.getStartDisplayDate();
    final startRussianName = model.getRussianDayName(startDisplayDate);
    final startIndex = allDays.indexOf(startRussianName);

    final validItems = <Widget>[];
    if (hasMainSchedules) {
      if (semesterStarted) {
        final dayName = startRussianName;
        final todayDateStr = DateFormat('dd.MM.yyyy').format(startDisplayDate);
        final weekNumber = model.getWeekNumberForCurrentWeek(
          scheduleData.startDate,
        );

        // В режимах schedule и daily показываем только обычные занятия (без экзаменов)
        final daySchedules = model.getAllSchedulesForDay(
          scheduleData.schedules,
          dayName,
          weekNumber,
          todayDateStr,
        );

        final isSemesterEnded = scheduleData.endDate != null
            ? !model.isDateValid(startDisplayDate, scheduleData.endDate!)
            : false;

        validItems.add(
          _buildDaySection(
            model,
            dayName,
            '$todayDateStr (сегодня)',
            daySchedules,
            weekNumber,
            0,
            true,
            isSemesterEnded,
            semesterStarted: semesterStarted,
          ),
        );

        if (startIndex < allDays.length - 1) {
          final remainingDays = allDays.sublist(startIndex + 1);

          for (final dayName in remainingDays) {
            if (model.isDayValidForCurrentWeek(dayName, scheduleData.endDate)) {
              final weekNumber = model.getWeekNumberForCurrentWeek(
                scheduleData.startDate,
              );
              final date = model.getDateForCurrentWeekDay(
                dayName,
                scheduleData.endDate,
              );
              final dateOnly = date.replaceAll(' (семестр окончен)', '');

              final daySchedules = model.getAllSchedulesForDay(
                scheduleData.schedules,
                dayName,
                weekNumber,
                dateOnly,
              );

              final isSemesterEnded = date.contains('семестр окончен');

              validItems.add(
                _buildDaySection(
                  model,
                  dayName,
                  date,
                  daySchedules,
                  weekNumber,
                  0,
                  false,
                  isSemesterEnded,
                  semesterStarted: semesterStarted,
                ),
              );
            }
          }
        }

        for (int weekOffset = 1; weekOffset <= _weeksToShow; weekOffset++) {
          bool weekHasValidDays = false;

          for (final dayName in allDays) {
            if (model.isDayValidForFutureWeek(
              dayName,
              weekOffset,
              scheduleData.endDate,
            )) {
              final weekNumber = model.getWeekNumberForFutureWeek(
                weekOffset,
                scheduleData.startDate,
              );
              final date = model.getDateForFutureWeekDay(
                dayName,
                weekOffset,
                scheduleData.endDate,
              );
              final dateOnly = date.replaceAll(' (семестр окончен)', '');

              final daySchedules = model.getAllSchedulesForDay(
                scheduleData.schedules,
                dayName,
                weekNumber,
                dateOnly,
              );

              final isSemesterEnded = date.contains('семестр окончен');

              validItems.add(
                _buildDaySection(
                  model,
                  dayName,
                  date,
                  daySchedules,
                  weekNumber,
                  weekOffset,
                  false,
                  isSemesterEnded,
                  semesterStarted: semesterStarted,
                ),
              );

              weekHasValidDays = true;
            }
          }

          if (!weekHasValidDays) {
            _hasMoreWeeks = false;
            break;
          }
        }
      } else {
        for (int weekOffset = 0; weekOffset < _weeksToShow; weekOffset++) {
          bool weekHasValidDays = false;

          for (final dayName in allDays) {
            if (model.isDayValidForFutureWeek(
              dayName,
              weekOffset,
              scheduleData.endDate,
            )) {
              final weekNumber = model.getWeekNumberForFutureWeek(
                weekOffset,
                scheduleData.startDate,
              );
              final date = model.getDateForFutureWeekDay(
                dayName,
                weekOffset,
                scheduleData.endDate,
              );
              final dateOnly = date.replaceAll(' (семестр окончен)', '');

              final daySchedules = model.getAllSchedulesForDay(
                scheduleData.schedules,
                dayName,
                weekNumber,
                dateOnly,
              );

              final isSemesterEnded = date.contains('семестр окончен');
              final isStartDay = weekOffset == 0 && dayName == startRussianName;

              validItems.add(
                _buildDaySection(
                  model,
                  dayName,
                  date,
                  daySchedules,
                  weekNumber,
                  weekOffset + 1,
                  isStartDay,
                  isSemesterEnded,
                  semesterStarted: semesterStarted,
                ),
              );

              weekHasValidDays = true;
            }
          }

          if (!weekHasValidDays) {
            _hasMoreWeeks = false;
            break;
          }
        }
      }
    }

    return validItems.isEmpty || semesterEnded
        ? _buildNoScheduleWidget()
        : ListView(controller: _scrollController, children: validItems);
  }

  Widget _buildDailyView(MainGroupModel model, MainGroup scheduleData) {
    final allDays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
    ];

    final validItems = <Widget>[];
    final semesterStarted = model.hasSemesterStarted();

    final Map<String, Map<int, List<Schedule>>> schedulesByDayAndWeek = {};

    // Функция для проверки, является ли занятие обычным (не экзаменом, не консультацией)
    bool isRegularSchedule(Schedule schedule) {
      if (schedule.announcement == true) return true;

      final lessonType = schedule.lessonTypeAbbrev?.toLowerCase() ?? '';
      final isExam = schedule.lessonTypeAbbrev == 'экз' || 
                    lessonType.contains('экз') ||
                    lessonType.contains('exam');
      final isConsult = schedule.lessonTypeAbbrev == 'конс' || 
                       lessonType.contains('конс') ||
                       lessonType.contains('консультация');
      return !isExam && !isConsult;
    }

    // Обрабатываем регулярные занятия по неделям (1-4)
    for (int weekNumber = 1; weekNumber <= 4; weekNumber++) {
      for (final dayName in allDays) {
        String targetDate;
        try {
          final now = DateTime.now();
          final mondayOfCurrentWeek = now.subtract(
            Duration(days: now.weekday - 1),
          );
          final startDate = model.parseDate(scheduleData.startDate ?? '');

          final weeksFromStart =
              (mondayOfCurrentWeek.difference(startDate).inDays ~/ 7) + 1;
          final targetWeek = ((weeksFromStart - 1) ~/ 4) * 4 + weekNumber;

          final targetDateObj = startDate.add(
            Duration(days: (targetWeek - 1) * 7 + allDays.indexOf(dayName)),
          );
          targetDate = DateFormat('dd.MM.yyyy').format(targetDateObj);
        } catch (e) {
          targetDate = '';
        }

        // Получаем занятия через основной метод (уже отфильтрованы экзамены)
        final daySchedules = model.getAllSchedulesForDay(
          scheduleData.schedules,
          dayName,
          weekNumber,
          targetDate,
        );

        // Дополнительная фильтрация на всякий случай
        final filteredSchedules = daySchedules.where(isRegularSchedule).toList();

        if (filteredSchedules.isNotEmpty) {
          if (!schedulesByDayAndWeek.containsKey(dayName)) {
            schedulesByDayAndWeek[dayName] = {};
          }
          schedulesByDayAndWeek[dayName]![weekNumber] = filteredSchedules;
        }
      }
    }

    // Добавляем объявления
    if (scheduleData.schedules != null) {
      for (final daySchedules in scheduleData.schedules!.values) {
        for (final schedule in daySchedules) {
          if (schedule.announcement == true) {
            final announcementDate = schedule.startLessonDate;
            if (announcementDate != null && announcementDate.isNotEmpty) {
              try {
                final date = DateFormat('dd.MM.yyyy').parse(announcementDate);
                final dayName = model.getRussianDayName(date);

                if (!schedulesByDayAndWeek.containsKey(dayName)) {
                  schedulesByDayAndWeek[dayName] = {};
                }
                if (!schedulesByDayAndWeek[dayName]!.containsKey(0)) {
                  schedulesByDayAndWeek[dayName]![0] = [];
                }
                schedulesByDayAndWeek[dayName]![0]!.add(schedule);
              } catch (e) {}
            }
          }
        }
      }
    }

    // Сортируем дни по порядку
    final sortedDays = allDays
        .where((day) => schedulesByDayAndWeek.containsKey(day))
        .toList();

    // Создаем виджеты для каждого дня и недели
    for (final dayName in sortedDays) {
      final weeksForDay = schedulesByDayAndWeek[dayName]!;
      final weekNumbers = weeksForDay.keys.toList()..sort();

      for (final weekNumber in weekNumbers) {
        final daySchedules = weeksForDay[weekNumber]!;

        // Сортируем занятия по времени
        daySchedules.sort((a, b) {
          final timeA = a.startLessonTime ?? '';
          final timeB = b.startLessonTime ?? '';
          return timeA.compareTo(timeB);
        });

        String dateDisplay;
        if (weekNumber == 0) {
          dateDisplay = 'Объявления';
        } else {
          try {
            final now = DateTime.now();
            final mondayOfCurrentWeek = now.subtract(
              Duration(days: now.weekday - 1),
            );
            final startDate = model.parseDate(scheduleData.startDate ?? '');

            final weeksFromStart =
                (mondayOfCurrentWeek.difference(startDate).inDays ~/ 7) + 1;
            final targetWeek = ((weeksFromStart - 1) ~/ 4) * 4 + weekNumber;

            final targetDate = startDate.add(
              Duration(days: (targetWeek - 1) * 7 + allDays.indexOf(dayName)),
            );
            dateDisplay = DateFormat('dd.MM.yyyy').format(targetDate);
          } catch (e) {
            dateDisplay = 'Неделя $weekNumber';
          }
        }

        validItems.add(
          _buildDaySection(
            model,
            dayName,
            dateDisplay,
            daySchedules,
            weekNumber,
            0,
            false,
            false,
            semesterStarted: semesterStarted,
            showWeekNumberInCard: true,
            forceWeekNumber: weekNumber,
          ),
        );
      }
    }

    return validItems.isEmpty
        ? _buildNoScheduleWidget()
        : ListView(controller: _scrollController, children: validItems);
  }

  Widget _buildExamsView(MainGroupModel model, MainGroup scheduleData) {
    final validItems = <Widget>[];
    final semesterStarted = model.hasSemesterStarted();

    if (scheduleData.exams == null || scheduleData.exams!.isEmpty) {
      return _buildNoScheduleWidget();
    }

    final Map<String, List<Schedule>> examsByDate = {};

    for (final exam in scheduleData.exams!) {
      final date = exam.dateLesson ?? '';
      if (date.isNotEmpty) {
        if (!examsByDate.containsKey(date)) {
          examsByDate[date] = [];
        }
        examsByDate[date]!.add(exam);
      }
    }

    final sortedDates = examsByDate.keys.toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('dd.MM.yyyy').parse(a);
          final dateB = DateFormat('dd.MM.yyyy').parse(b);
          return dateA.compareTo(dateB);
        } catch (e) {
          return a.compareTo(b);
        }
      });

    for (final date in sortedDates) {
      final examsForDate = examsByDate[date]!;
      final dayName = model.getDayNameFromDate(date);

      validItems.add(
        _buildDaySection(
          model,
          dayName,
          date,
          examsForDate,
          1,
          0,
          false,
          false,
          semesterStarted: semesterStarted,
          isExamView: true,
        ),
      );
    }

    return validItems.isEmpty
        ? _buildNoScheduleWidget()
        : ListView(controller: _scrollController, children: validItems);
  }

  Widget _buildDaySection(
    MainGroupModel model,
    String dayName,
    String date,
    List<Schedule> schedules,
    int weekNumber,
    int displayWeekOffset,
    bool isStartDay,
    bool isSemesterEnded, {
    required bool semesterStarted,
    bool isExamView = false,
    bool showWeekNumberInCard = false,
    int? forceWeekNumber,
  }) {
    final effectiveWeekNumber = forceWeekNumber ?? weekNumber;

    return schedules.isEmpty
        ? const SizedBox.shrink()
        : Container(
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(color: AppColors.greyBackground),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    color: isSemesterEnded
                                        ? Colors.grey[600]
                                        : Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                                if (isStartDay && semesterStarted)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Сегодня',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              effectiveWeekNumber == 0
                                  ? 'Объявления'
                                  : '$date${!isExamView && effectiveWeekNumber > 0 ? ', Неделя: $effectiveWeekNumber' : ''}',
                              style: TextStyle(
                                color: isSemesterEnded
                                    ? Colors.grey[600]
                                    : Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSemesterEnded
                              ? Colors.grey[300]!
                              : const Color(0xFFf3f2f8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: schedules
                      .map(
                        (schedule) => _buildLessonCard(
                          model,
                          schedule,
                          isSemesterEnded,
                          isExamView,
                          showWeekNumberInCard ? effectiveWeekNumber : null,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
  }

  Widget _buildLessonCard(
    MainGroupModel model,
    Schedule schedule,
    bool isSemesterEnded,
    bool isExamView,
    int? weekNumberForDisplay,
  ) {
    final isAnnouncement = model.isAnnouncement(schedule);
    final subjectName = model.getSubjectName(schedule);
    final lessonType = model.getLessonTypeDisplay(schedule);
    final teacherImage = model.getTeacherImage(schedule.employees);

    final isExam = (schedule.lessonTypeAbbrev != null &&
        schedule.lessonTypeAbbrev!.toLowerCase().contains('экз'));
    final isConsult = (schedule.lessonTypeAbbrev != null &&
        schedule.lessonTypeAbbrev!.toLowerCase().contains('конс'));
    final isLecture = schedule.lessonTypeAbbrev != null &&
        schedule.lessonTypeAbbrev!.toLowerCase().contains('лк');
    final isPractice = schedule.lessonTypeAbbrev != null &&
        schedule.lessonTypeAbbrev!.toLowerCase().contains('пз');
    final isLab = schedule.lessonTypeAbbrev != null &&
        schedule.lessonTypeAbbrev!.toLowerCase().contains('лр');

    return InkWell(
      onTap: () => _onLessonTap(model, schedule),
      child: Container(
        margin: const EdgeInsets.only(right: 12, left: 12, top: 2, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.greyBackground),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  schedule.startLessonTime ?? '--:--',
                  style: const TextStyle(fontSize: 13, color: AppColors.black),
                ),
                const SizedBox(height: 1),
                Text(
                  schedule.endLessonTime ?? '--:--',
                  style: const TextStyle(fontSize: 11, color: AppColors.black),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isAnnouncement ? 'Объявление!' : subjectName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      if (schedule.numSubgroup == 0)
                        const SizedBox.shrink()
                      else
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            Icon(
                              Icons.person,
                              color: AppColors.greyText,
                              size: 18,
                            ),
                            const SizedBox(width: 3),
                            Text('${schedule.numSubgroup}'),
                          ],
                        ),
                    ],
                  ),
                  if (weekNumberForDisplay != null && !isAnnouncement)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Неделя: $weekNumberForDisplay',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  Text(
                    lessonType,
                    style: TextStyle(
                      fontSize: 11,
                      color: _getLessonTypeColor(
                        isExam,
                        isConsult,
                        isLecture,
                        isPractice,
                        isLab,
                        isSemesterEnded,
                        isExamView,
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (schedule.auditories != null &&
                      schedule.auditories!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.room_outlined,
                          size: 12,
                          color: AppColors.greyText,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          schedule.auditories!.join(', '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.greyText,
                          ),
                        ),
                      ],
                    ),
                  if (schedule.note != null && schedule.note!.isNotEmpty)
                    Text(
                      schedule.note!,
                      style: const TextStyle(fontSize: 10, color: AppColors.greyText),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: ClipOval(
                child: teacherImage.isNotEmpty
                    ? Image.network(
                        teacherImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person_outline,
                            color: Colors.grey,
                            size: 20,
                          );
                        },
                      )
                    : const Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLessonTypeColor(
    bool isExam,
    bool isConsult,
    bool isLecture,
    bool isPractice,
    bool isLab,
    bool isSemesterEnded,
    bool isExamView,
  ) {
    if (isConsult) return Colors.brown;
    if (isSemesterEnded) return Colors.grey;
    if (isExam) return Colors.purple;
    if (isLecture) return Colors.green;
    if (isPractice) return Colors.red;
    if (isLab) return Colors.orange;
    return AppColors.black;
  }

  Widget _buildLoadingWidget() {
    return ColoredBox(
      color: AppColors.greyBackground,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: AppColors.greyText),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(MainGroupModel model) {
    return ColoredBox(
      color: AppColors.greyBackground,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 50, color: AppColors.blue),
              const SizedBox(height: 16),
              const Text(
                'Ошибка загрузки',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => model.loadMainGroup(),
                child: const Text('Повторить попытку'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Нет данных',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Расписание для этой группы не найдено',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoScheduleWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.sentiment_satisfied_alt_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Расписание отсутствует',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}