import 'package:bsuir/domain/entity/main_group.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_cubit.dart';
import 'package:bsuir/logic/bloc/main_group/main_group_state.dart';
import 'package:bsuir/logic/models/schedule_models.dart';
import 'package:bsuir/resourses/app_colors.dart';
import 'package:bsuir/resourses/app_fonts.dart';
import 'package:bsuir/services/subgroup_service.dart';
import 'package:bsuir/ui/widgets/app/main_group/components/empty_state_widgets.dart';
import 'package:bsuir/ui/widgets/app/main_group/modal_bottom_sheet_widget.dart';
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

  void _onLessonTap(
    BuildContext context,
    MainGroupCubit cubit,
    DisplaySchedule schedule,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => lessonInfo(cubit, schedule),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainGroupCubit, MainGroupState>(
      builder: (context, state) {
        if (state is MainGroupError) {
          return ErrorStateWidget();
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
        '${cubit.groupNumber}',
        style: TextStyle(
          color: AppColors.black,
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
            color: state.isFavorite ? AppColors.blue : AppColors.blue,
          ),
          onPressed: () => cubit.toggleFavorite(),
        ),
        _buildSubgroupButton(context, state, cubit),
        const SizedBox(width: 5),
        _buildViewTypeMenu(context, state, cubit),
      ],
      backgroundColor: AppColors.greyBackground,
    );
  }

  Widget _buildSubgroupButton(
    BuildContext context,
    MainGroupData state,
    MainGroupCubit cubit,
  ) {
    return PopupMenuButton<SubgroupType>(
      onSelected: (filter) => cubit.changeSubgroupFilter(filter),
      tooltip: 'Выбор подгруппы',
      icon: Icon(_getSubgroupIcon(state.subgroupFilter), color: AppColors.blue),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: SubgroupType.all,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 20,
                    color: state.subgroupFilter == SubgroupType.all
                        ? AppColors.blue
                        : AppColors.greyText,
                  ),
                  const SizedBox(width: 8),
                  const Text('Вся группа'),
                ],
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: SubgroupType.first,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: state.subgroupFilter == SubgroupType.first
                          ? AppColors.blue
                          : AppColors.greyText,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('1 подгруппа'),
                ],
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: SubgroupType.second,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: state.subgroupFilter == SubgroupType.second
                          ? AppColors.blue
                          : AppColors.greyText,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('2 подгруппа'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getSubgroupIcon(SubgroupType filter) {
    switch (filter) {
      case SubgroupType.all:
        return Icons.people;
      case SubgroupType.first:
      case SubgroupType.second:
        return Icons.person;
    }
  }

  Widget _buildViewTypeMenu(
    BuildContext context,
    MainGroupData state,
    MainGroupCubit cubit,
  ) {
    return PopupMenuButton<ScheduleViewType>(
      onSelected: (value) => cubit.changeViewType(value),
      tooltip: 'Тип расписания',
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
                    : 'Дата начала сессии не указана',
                style: TextStyle(color: AppColors.greyText),
              ),
              const SizedBox(height: 4),
              Text(
                scheduleData.endExamsDate != null
                    ? 'Окончание: ${scheduleData.endExamsDate}'
                    : 'Дата окончания сессии не указана',
                style: const TextStyle(fontSize: 12, color: AppColors.greyText),
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
