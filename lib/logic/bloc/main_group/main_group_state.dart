import 'package:bsuir/domain/entity/main_group.dart';
import 'package:bsuir/services/subgroup_service.dart';
import 'package:equatable/equatable.dart';

enum ScheduleViewType { schedule, daily, exams }

abstract class MainGroupState extends Equatable {
  const MainGroupState();

  @override
  List<Object?> get props => [];
}

class MainGroupInitial extends MainGroupState {}

class MainGroupLoading extends MainGroupState {}

class MainGroupData extends MainGroupState {
  final MainGroup mainGroup;
  final bool isFavorite;
  final int currentAcademicWeek;
  final ScheduleViewType selectedViewType;
  final int weeksToShow;
  final bool hasMoreWeeks;
  final SubgroupType subgroupFilter;

  const MainGroupData({
    required this.mainGroup,
    required this.isFavorite,
    required this.currentAcademicWeek,
    this.selectedViewType = ScheduleViewType.schedule,
    this.weeksToShow = 5,
    this.hasMoreWeeks = true,
    this.subgroupFilter = SubgroupType.all,
  });

  MainGroupData copyWith({
    MainGroup? mainGroup,
    bool? isFavorite,
    int? currentAcademicWeek,
    ScheduleViewType? selectedViewType,
    int? weeksToShow,
    bool? hasMoreWeeks,
    SubgroupType? subgroupFilter,
  }) {
    return MainGroupData(
      mainGroup: mainGroup ?? this.mainGroup,
      isFavorite: isFavorite ?? this.isFavorite,
      currentAcademicWeek: currentAcademicWeek ?? this.currentAcademicWeek,
      selectedViewType: selectedViewType ?? this.selectedViewType,
      weeksToShow: weeksToShow ?? this.weeksToShow,
      hasMoreWeeks: hasMoreWeeks ?? this.hasMoreWeeks,
      subgroupFilter: subgroupFilter ?? this.subgroupFilter,
    );
  }

  bool get hasSchedules {
    return (mainGroup.schedules != null && mainGroup.schedules!.isNotEmpty) ||
        (mainGroup.exams != null && mainGroup.exams!.isNotEmpty);
  }

  bool get hasMainSchedules {
    return mainGroup.schedules != null && mainGroup.schedules!.isNotEmpty;
  }

  bool get isZaochOrDist => mainGroup.isZaochOrDist == true;

  @override
  List<Object?> get props => [
    mainGroup,
    isFavorite,
    currentAcademicWeek,
    selectedViewType,
    weeksToShow,
    hasMoreWeeks,
    subgroupFilter,
  ];
}

class MainGroupError extends MainGroupState {
}
