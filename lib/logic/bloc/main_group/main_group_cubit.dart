import 'package:bsuir/domain/api_client/api_client.dart';
import 'package:bsuir/domain/entity/schedule.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_state.dart';
import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/logic/utils/date_utils.dart';
import 'package:bsuir/services/favorite_group_service.dart';
import 'package:bsuir/services/subgroup_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainGroupCubit extends Cubit<MainGroupState> {
  final ApiClient _apiClient = ApiClient();
  final int groupNumber;

  MainGroupCubit({required this.groupNumber}) : super(MainGroupInitial());

  MainGroupData _determineInitialViewType(MainGroupData state) {
    if (isSemesterEnded(state)) {
      return state.copyWith(selectedViewType: ScheduleViewType.exams);
    }
    return state;
  }

  Future<void> toggleFavorite() async {
    if (state is MainGroupData) {
      final currentState = state as MainGroupData;
      await FavoriteGroupService.toggleFavorite(groupNumber.toString());
      emit(currentState.copyWith(isFavorite: !currentState.isFavorite));
    }
  }

  void changeViewType(ScheduleViewType viewType) {
    if (state is MainGroupData) {
      final currentState = state as MainGroupData;
      emit(currentState.copyWith(selectedViewType: viewType));
    }
  }

  void loadMoreWeeks() {
    if (state is MainGroupData) {
      final currentState = state as MainGroupData;
      if (currentState.mainGroup.endDate != null && currentState.hasMoreWeeks) {
        emit(currentState.copyWith(weeksToShow: currentState.weeksToShow + 1));
      }
    }
  }

  void checkMoreWeeksAvailability() {
    if (state is MainGroupData) {
      final currentState = state as MainGroupData;
      if (!currentState.hasMoreWeeks) return;

      const allDays = [
        'Понедельник',
        'Вторник',
        'Среда',
        'Четверг',
        'Пятница',
        'Суббота',
      ];

      bool weekHasValidDays = false;
      for (final dayName in allDays) {
        if (isDayValidForFutureWeek(
          currentState,
          dayName,
          currentState.weeksToShow,
        )) {
          weekHasValidDays = true;
          break;
        }
      }

      if (!weekHasValidDays) {
        emit(currentState.copyWith(hasMoreWeeks: false));
      }
    }
  }

  DateTime _getMondayForWeek(MainGroupData state, int weekOffset) {
    final now = DateTime.now();
    final baseOffset = getBaseWeekOffset(state);

    DateTime referenceDate = now;

    if (now.weekday == DateTime.sunday) {
      referenceDate = now.add(const Duration(days: 1));
    }

    final baseMonday = MyDateUtils.getMonday(referenceDate);

    return baseMonday.add(Duration(days: (baseOffset + weekOffset) * 7));
  }

  int getBaseWeekOffset(MainGroupData state) {
    if (hasSemesterStarted(state)) {
      return 0;
    }
    return _weeksUntilSemesterStart(state);
  }

  int _weeksUntilSemesterStart(MainGroupData state) {
    final startDateStr = state.mainGroup.startDate;
    if (startDateStr == null || startDateStr.isEmpty) return 0;

    final now = DateTime.now();
    final startDate = MyDateUtils.parseDate(startDateStr);

    final currentMonday = MyDateUtils.getMonday(now);
    final semesterMonday = MyDateUtils.getMonday(startDate);

    final diffDays = semesterMonday.difference(currentMonday).inDays;
    return diffDays > 0 ? diffDays ~/ 7 : 0;
  }

  String getDateForFutureWeekDay(
    MainGroupData state,
    String dayName,
    int weekOffset,
  ) {
    return _getDateForWeekDay(state, weekOffset, dayName);
  }

  String _getDateForWeekDay(
    MainGroupData state,
    int weekOffset,
    String dayName,
  ) {
    final monday = _getMondayForWeek(state, weekOffset);

    final targetWeekday = MyDateUtils.getWeekdayNumber(dayName);
    int dayDifference = targetWeekday - 1;
    final targetDate = monday.add(Duration(days: dayDifference));

    final dateString = MyDateUtils.formatDate(targetDate);
    final endDate = state.mainGroup.endDate;

    if (endDate != null && !MyDateUtils.isDateValid(targetDate, endDate)) {
      return dateString;
    }

    return dateString;
  }

  bool isDayValidForCurrentWeek(MainGroupData state, String dayName) {
    return _isDayValidForWeek(state, 0, dayName);
  }

  bool isDayValidForFutureWeek(
    MainGroupData state,
    String dayName,
    int weekOffset,
  ) {
    return _isDayValidForWeek(state, weekOffset, dayName);
  }

  bool _isDayValidForWeek(MainGroupData state, int weekOffset, String dayName) {
    final monday = _getMondayForWeek(state, weekOffset);
    final targetWeekday = MyDateUtils.getWeekdayNumber(dayName);
    int dayDifference = targetWeekday - 1;
    final targetDate = monday.add(Duration(days: dayDifference));
    final endDate = state.mainGroup.endDate;

    if (endDate != null) {
      return MyDateUtils.isDateValid(targetDate, endDate);
    }

    return true;
  }

  int getWeekNumberForCurrentWeek(MainGroupData state) {
    return getWeekNumberForFutureWeek(state, 0);
  }

  int getWeekNumberForFutureWeek(MainGroupData state, int weekOffset) {
    final baseOffset = getBaseWeekOffset(state);

    int sundayShift = 0;
    if (DateTime.now().weekday == DateTime.sunday) {
      sundayShift = 1;
    }

    return ((state.currentAcademicWeek -
                1 +
                baseOffset +
                weekOffset +
                sundayShift) %
            4) +
        1;
  }

  DateTime getStartDisplayDate(MainGroupData state) {
    final now = DateTime.now();
    final startDateStr = state.mainGroup.startDate;

    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final startDate = MyDateUtils.parseDate(startDateStr);
        final displayDate = startDate.isAfter(now) ? startDate : now;
        return displayDate;
      } catch (e) {}
    }

    return now;
  }

  bool hasSemesterStarted([MainGroupData? state]) {
    final currentState = state ?? (this.state as MainGroupData?);
    if (currentState == null) return true;

    final now = DateTime.now();
    final startDateStr = currentState.mainGroup.startDate;

    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final startDate = MyDateUtils.parseDate(startDateStr);
        return now.isAfter(startDate) || now.isAtSameMomentAs(startDate);
      } catch (e) {
        return true;
      }
    }

    return true;
  }

  bool isSemesterEnded([MainGroupData? state]) {
    final currentState = state ?? (this.state as MainGroupData?);
    if (currentState == null) return true;

    final now = DateTime.now();
    final endDateStr = currentState.mainGroup.endDate;

    if (endDateStr != null && endDateStr.isNotEmpty) {
      try {
        final endDate = MyDateUtils.parseDate(endDateStr);
        return now.isAfter(endDate);
      } catch (e) {
        return true;
      }
    }

    return true;
  }

  Future<void> loadMainGroup() async {
    emit(MainGroupLoading());

    try {
      final currentAcademicWeek = await _apiClient.getCurrentWeek();
      final group = await _apiClient.getScheduleResponse(groupNumber);
      final isFavorite = await FavoriteGroupService.isFavoriteGroup(
        groupNumber.toString(),
      );
      final subgroupFilter = await SubgroupService.getSubgroupFilter(
        groupNumber.toString(),
      );

      final dataState = MainGroupData(
        mainGroup: group,
        currentAcademicWeek: currentAcademicWeek,
        isFavorite: isFavorite,
        subgroupFilter: subgroupFilter,
      );

      final updatedState = _determineInitialViewType(dataState);
      emit(updatedState);
    } catch (e) {
      emit(MainGroupError());
    }
  }

  Future<void> changeSubgroupFilter(SubgroupType filter) async {
    if (state is MainGroupData) {
      final currentState = state as MainGroupData;
      await SubgroupService.setSubgroupFilter(groupNumber.toString(), filter);
      emit(currentState.copyWith(subgroupFilter: filter));
    }
  }

  List<Schedule> filterSchedulesBySubgroup(
    List<Schedule> schedules,
    SubgroupType filter,
  ) {
    if (filter == SubgroupType.all) {
      return schedules;
    }

    final subgroupNumber = filter.subgroupNumber;
    return schedules.where((schedule) {
      if (schedule.numSubgroup == null || schedule.numSubgroup == 0) {
        return true;
      }
      return schedule.numSubgroup == subgroupNumber;
    }).toList();
  }

  List<DisplaySchedule> filterDisplaySchedulesBySubgroup(
    List<DisplaySchedule> schedules,
    SubgroupType filter,
  ) {
    if (filter == SubgroupType.all) {
      return schedules;
    }

    final subgroupNumber = filter.subgroupNumber;
    return schedules.where((schedule) {
      if (schedule.subgroupNumber == 0) {
        return true;
      }
      return schedule.subgroupNumber == subgroupNumber;
    }).toList();
  }
}
