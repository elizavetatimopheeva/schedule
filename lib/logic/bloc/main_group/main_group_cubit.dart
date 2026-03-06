
import 'package:bsuir/domain/api_client/api_client.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_state.dart';
import 'package:bsuir/logic/utils/date_utils.dart';
import 'package:bsuir/services/favorite_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainGroupCubit extends Cubit<MainGroupState> {
  final ApiClient _apiClient = ApiClient();
  final int groupNumber;

  MainGroupCubit({required this.groupNumber}) : super(MainGroupInitial());

  // Загрузка данных
  Future<void> loadMainGroup() async {
    emit(MainGroupLoading());

    try {
      final currentAcademicWeek = await _apiClient.getCurrentWeek();
      final group = await _apiClient.getScheduleResponse(groupNumber);
      final isFavorite = await FavoriteService.isFavorite(groupNumber.toString());

      final dataState = MainGroupData(
        mainGroup: group,
        currentAcademicWeek: currentAcademicWeek,
        isFavorite: isFavorite,
      );

      // Определяем начальный тип просмотра
      final updatedState = _determineInitialViewType(dataState);
      emit(updatedState);
    } catch (e) {
      emit(MainGroupError('Ошибка загрузки расписания: ${e.toString()}'));
    }
  }

  MainGroupData _determineInitialViewType(MainGroupData state) {
    if (isSemesterEnded(state)) {
      return state.copyWith(selectedViewType: ScheduleViewType.exams);
    }
    return state;
  }

  // Переключение избранного
  Future<void> toggleFavorite() async {
    if (state is MainGroupData) {
      final currentState = state as MainGroupData;
      await FavoriteService.toggleFavorite(groupNumber.toString());
      emit(currentState.copyWith(isFavorite: !currentState.isFavorite));
    }
  }

  // Смена типа просмотра
  void changeViewType(ScheduleViewType viewType) {
    if (state is MainGroupData) {
      final currentState = state as MainGroupData;
      emit(currentState.copyWith(selectedViewType: viewType));
    }
  }

  // Загрузка дополнительных недель
  void loadMoreWeeks() {
    if (state is MainGroupData) {
      final currentState = state as MainGroupData;
      if (currentState.mainGroup.endDate != null && currentState.hasMoreWeeks) {
        emit(currentState.copyWith(weeksToShow: currentState.weeksToShow + 1));
      }
    }
  }

  // Проверка доступности дополнительных недель
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
        if (isDayValidForFutureWeek(currentState, dayName, currentState.weeksToShow)) {
          weekHasValidDays = true;
          break;
        }
      }

      if (!weekHasValidDays) {
        emit(currentState.copyWith(hasMoreWeeks: false));
      }
    }
  }

  // ========== МЕТОДЫ ДЛЯ РАБОТЫ С ДАТАМИ ==========

  DateTime _getMondayForWeek(MainGroupData state, int weekOffset) {
    final now = DateTime.now();
    final baseOffset = getBaseWeekOffset(state);

    final baseMonday = DateUtils.getMonday(now);

    return baseMonday.add(
      Duration(days: (baseOffset + weekOffset) * 7),
    );
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
    final startDate = DateUtils.parseDate(startDateStr);

    final currentMonday = DateUtils.getMonday(now);
    final semesterMonday = DateUtils.getMonday(startDate);

    final diffDays = semesterMonday.difference(currentMonday).inDays;
    return diffDays > 0 ? diffDays ~/ 7 : 0;
  }

  String getDateForCurrentWeekDay(MainGroupData state, String dayName) {
    return _getDateForWeekDay(state, 0, dayName);
  }

  String getDateForFutureWeekDay(MainGroupData state, String dayName, int weekOffset) {
    return _getDateForWeekDay(state, weekOffset, dayName);
  }

  String _getDateForWeekDay(MainGroupData state, int weekOffset, String dayName) {
    final monday = _getMondayForWeek(state, weekOffset);
    
    final targetWeekday = DateUtils.getWeekdayNumber(dayName);
    int dayDifference = targetWeekday - 1;
    final targetDate = monday.add(Duration(days: dayDifference));
    
    final dateString = DateUtils.formatDate(targetDate);
    final endDate = state.mainGroup.endDate;

    if (endDate != null && !DateUtils.isDateValid(targetDate, endDate)) {
      return dateString;
    }

    return dateString;
  }

  bool isDayValidForCurrentWeek(MainGroupData state, String dayName) {
    return _isDayValidForWeek(state, 0, dayName);
  }

  bool isDayValidForFutureWeek(MainGroupData state, String dayName, int weekOffset) {
    return _isDayValidForWeek(state, weekOffset, dayName);
  }

  bool _isDayValidForWeek(MainGroupData state, int weekOffset, String dayName) {
    final monday = _getMondayForWeek(state, weekOffset);
    final targetWeekday = DateUtils.getWeekdayNumber(dayName);
    int dayDifference = targetWeekday - 1;
    final targetDate = monday.add(Duration(days: dayDifference));
    final endDate = state.mainGroup.endDate;
    
    if (endDate != null) {
      return DateUtils.isDateValid(targetDate, endDate);
    }
    
    return true;
  }

  bool shouldShowScheduleForDate(MainGroupData state, DateTime date) {
    final startDateStr = state.mainGroup.startDate;
    final endDateStr = state.mainGroup.endDate;
    
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final startDate = DateUtils.parseDate(startDateStr);
        if (date.isBefore(startDate)) {
          return false;
        }
      } catch (e) {}
    }
    
    if (endDateStr != null && endDateStr.isNotEmpty) {
      try {
        final endDate = DateUtils.parseDate(endDateStr);
        if (date.isAfter(endDate)) {
          return false;
        }
      } catch (e) {}
    }
    
    return true;
  }

  int getWeekNumberForCurrentWeek(MainGroupData state) {
    return getWeekNumberForFutureWeek(state, 0);
  }

  int getWeekNumberForFutureWeek(MainGroupData state, int weekOffset) {
    final baseOffset = getBaseWeekOffset(state);
    return ((state.currentAcademicWeek - 1 + baseOffset + weekOffset) % 4) + 1;
  }

  int getAbsoluteWeekNumberForDisplay(MainGroupData state, int weekOffset) {
    return state.currentAcademicWeek + weekOffset;
  }

  DateTime getStartDisplayDate(MainGroupData state) {
    final now = DateTime.now();
    final startDateStr = state.mainGroup.startDate;
    
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final startDate = DateUtils.parseDate(startDateStr);
        final displayDate = startDate.isAfter(now) ? startDate : now;
        return displayDate;
      } catch (e) {}
    }
    
    return now;
  }

  DateTime getMinDisplayDate(MainGroupData state) {
    final startDateStr = state.mainGroup.startDate;
    
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final startDate = DateUtils.parseDate(startDateStr);
        return startDate;
      } catch (e) {}
    }
    
    return DateTime.now();
  }

  bool hasSemesterStarted([MainGroupData? state]) {
    final currentState = state ?? (this.state as MainGroupData?);
    if (currentState == null) return true;

    final now = DateTime.now();
    final startDateStr = currentState.mainGroup.startDate;
    
    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final startDate = DateUtils.parseDate(startDateStr);
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
        final endDate = DateUtils.parseDate(endDateStr);
        return now.isAfter(endDate);
      } catch (e) {
        return true;
      }
    }
    
    return true;
  }
}