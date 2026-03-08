// import 'dart:async';
// import 'package:bsuir/domain/entity/groups.dart';
// import 'package:bsuir/ui/widgets/navigation/main_navigation.dart';
// import 'package:flutter/material.dart';
// import 'package:bsuir/domain/api_client/api_client.dart';

// class SearchGroupModel extends ChangeNotifier {
//   final apiClient = ApiClient();
//   var _allGroups = <Groups>[];
//   var _filteredGroups = <Groups>[];
//   var isSearchingGroups = false;
//   Timer? searchDebounce;
//   String? _searchQuery;
//   List<Groups> get groups => _filteredGroups;

//   void onGroupTap(BuildContext context, int index) {
//     final groupNumber = int.parse(_filteredGroups[index].name);
//     Navigator.of(
//       context,
//     ).pushNamed(MainNavigationRouteNames.mainGroup, arguments: groupNumber);
//   }

//   Future<void> getAllGroups() async {
//     final groups = await apiClient.getGroups();
//     _allGroups += groups;
//     _filteredGroups = groups;
//     notifyListeners();
//   }

//   Future<void> searchGroup(String text) async {
//     searchDebounce?.cancel();
//     searchDebounce = Timer(const Duration(milliseconds: 150), () {
//       _performSearch(text);
//     });
//   }

//   void _performSearch(String text) {
//     final searchQuery = text.trim();

//     if (searchQuery.isEmpty) {
//       _filteredGroups = _allGroups;
//       isSearchingGroups = false;
//     } else {
//       isSearchingGroups = true;
//       _filteredGroups = _allGroups.where((groups) {
//         return groups.name.toLowerCase().contains(searchQuery.toLowerCase());
//       }).toList();
//     }
//     _searchQuery = searchQuery.isEmpty ? null : searchQuery;
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     searchDebounce?.cancel();
//     super.dispose();
//   }
// }

// class SearchGroupModelProvider extends InheritedNotifier {
//   final SearchGroupModel model;

//   const SearchGroupModelProvider({
//     Key? key,
//     required this.model,
//     required Widget child,
//   }) : super(notifier: model, child: child);

//   static SearchGroupModelProvider? watch(BuildContext context) {
//     return context
//         .dependOnInheritedWidgetOfExactType<SearchGroupModelProvider>();
//   }

//   static SearchGroupModelProvider? read(BuildContext context) {
//     final widget = context
//         .getElementForInheritedWidgetOfExactType<SearchGroupModelProvider>()
//         ?.widget;
//     return widget is SearchGroupModelProvider ? widget : null;
//   }

//   @override
//   bool updateShouldNotify(SearchGroupModelProvider oldWidget) {
//     return true;
//   }
// }

// import 'dart:async';
// import 'package:bsuir/domain/entity/groups.dart';
// import 'package:bsuir/ui/widgets/navigation/main_navigation.dart';
// import 'package:flutter/material.dart';
// import 'package:bsuir/domain/api_client/api_client.dart';
// import 'package:bsuir/services/favorite_service.dart';

// class SearchGroupModel extends ChangeNotifier {
//   final apiClient = ApiClient();

//   // Два отдельных списка
//   var _allGroups = <Groups>[];
//   var _favoriteGroups = <Groups>[];
//   var _filteredFavoriteGroups = <Groups>[];
//   var _filteredAllGroups = <Groups>[];

//   var isSearchingGroups = false;
//   Timer? searchDebounce;
//   String? _searchQuery;

//   // Получить объединенный список для отображения
//   List<Groups> get groups {
//     if (_searchQuery != null && _searchQuery!.isNotEmpty) {
//       // При поиске показываем все группы вместе
//       return [..._filteredFavoriteGroups, ..._filteredAllGroups];
//     } else {
//       // Без поиска: сначала избранные, потом все остальные
//       return [..._favoriteGroups, ..._allGroups];
//     }
//   }

//   void onGroupTap(BuildContext context, int index) {
//     final group = groups[index];
//     final groupNumber = int.parse(group.name);
//     Navigator.of(context).pushNamed(
//       MainNavigationRouteNames.mainGroup,
//       arguments: groupNumber,
//     );
//   }

//   Future<void> getAllGroups() async {
//     final groups = await apiClient.getGroups();

//     // Получаем ID избранных групп
//     final favoriteIds = await FavoriteService.getAllFavorites();

//     // Разделяем группы на избранные и все остальные
//     _favoriteGroups = groups.where((g) => favoriteIds.contains(g.name)).toList();
//     _allGroups = groups.where((g) => !favoriteIds.contains(g.name)).toList();

//     // Сортируем каждый список
//     _favoriteGroups.sort((a, b) => a.name.compareTo(b.name));
//     _allGroups.sort((a, b) => a.name.compareTo(b.name));

//     notifyListeners();
//   }

//   Future<void> searchGroup(String text) async {
//     searchDebounce?.cancel();
//     searchDebounce = Timer(const Duration(milliseconds: 150), () {
//       _performSearch(text);
//     });
//   }

//   void _performSearch(String text) {
//     final searchQuery = text.trim();
//     _searchQuery = searchQuery.isEmpty ? null : searchQuery;

//     if (searchQuery.isEmpty) {
//       _filteredFavoriteGroups = [];
//       _filteredAllGroups = [];
//       isSearchingGroups = false;
//     } else {
//       isSearchingGroups = true;

//       // Фильтруем избранные группы
//       _filteredFavoriteGroups = _favoriteGroups.where((group) {
//         return group.name.toLowerCase().contains(searchQuery.toLowerCase());
//       }).toList();

//       // Фильтруем все остальные группы
//       _filteredAllGroups = _allGroups.where((group) {
//         return group.name.toLowerCase().contains(searchQuery.toLowerCase());
//       }).toList();
//     }

//     notifyListeners();
//   }

//   // Добавить/удалить группу из избранного
//   Future<void> toggleGroupFavorite(String groupId) async {
//     await FavoriteService.toggleFavorite(groupId);

//     // Обновляем списки
//     await _updateGroupsAfterFavoriteChange(groupId);
//   }

//   // Обновить списки после изменения избранного
//   Future<void> _updateGroupsAfterFavoriteChange(String groupId) async {
//     // Находим группу
//     Groups? groupToMove;

//     // Ищем в избранных
//     final favoriteIndex = _favoriteGroups.indexWhere((g) => g.name == groupId);
//     if (favoriteIndex != -1) {
//       // Удаляем из избранных, добавляем в общий список
//       groupToMove = _favoriteGroups.removeAt(favoriteIndex);
//       _allGroups.add(groupToMove);
//     } else {
//       // Ищем в общем списке
//       final allIndex = _allGroups.indexWhere((g) => g.name == groupId);
//       if (allIndex != -1) {
//         // Удаляем из общего списка, добавляем в избранные
//         groupToMove = _allGroups.removeAt(allIndex);
//         _favoriteGroups.add(groupToMove);
//       }
//     }

//     // Сортируем списки
//     _favoriteGroups.sort((a, b) => a.name.compareTo(b.name));
//     _allGroups.sort((a, b) => a.name.compareTo(b.name));

//     // Применяем текущий поиск, если он есть
//     if (_searchQuery != null && _searchQuery!.isNotEmpty) {
//       _performSearch(_searchQuery!);
//     }

//     notifyListeners();
//   }

//   // Проверить, избранная ли группа
//   Future<bool> isGroupFavorite(String groupId) async {
//     return await FavoriteService.isFavorite(groupId);
//   }

//   @override
//   void dispose() {
//     searchDebounce?.cancel();
//     super.dispose();
//   }
// }

// import 'dart:async';
// import 'package:bsuir/domain/entity/groups.dart';
// import 'package:bsuir/ui/widgets/navigation/main_navigation.dart';
// import 'package:flutter/material.dart';
// import 'package:bsuir/domain/api_client/api_client.dart';
// import 'package:bsuir/services/favorite_service.dart';

// class SearchGroupModel extends ChangeNotifier {
//   final apiClient = ApiClient();
//   var _allGroups = <Groups>[];
//   var _filteredGroups = <Groups>[];
//   var _favoriteGroups = <Groups>[]; // ДОБАВЛЕНО: отдельный список избранных
//   var isSearchingGroups = false;
//   Timer? searchDebounce;
//   String? _searchQuery;

//   List<Groups> get groups => _filteredGroups;
//   List<Groups> get favoriteGroups => _favoriteGroups; // ДОБАВЛЕНО: геттер для избранных

//   void onGroupTap(BuildContext context, int index) {
//     final groupNumber = int.parse(_filteredGroups[index].name);
//     Navigator.of(context).pushNamed(
//       MainNavigationRouteNames.mainGroup,
//       arguments: groupNumber,
//     );
//   }

//   Future<void> getAllGroups() async {
//     final groups = await apiClient.getGroups();
//     _allGroups = groups;
//     _filteredGroups = groups;

//     // ДОБАВЛЕНО: загружаем избранные группы
//     await _loadFavoriteGroups();

//     notifyListeners();
//   }

//   // ДОБАВЛЕНО: загрузка избранных групп
//   Future<void> _loadFavoriteGroups() async {
//     final favoriteIds = await FavoriteService.getAllFavorites();

//     // Фильтруем избранные группы из общего списка
//     _favoriteGroups = _allGroups.where((group) {
//       return favoriteIds.contains(group.name);
//     }).toList();

//     // Сортируем избранные группы по названию
//     _favoriteGroups.sort((a, b) => a.name.compareTo(b.name));
//   }

//   // ДОБАВЛЕНО: обновить список избранных
//   Future<void> refreshFavorites() async {
//     await _loadFavoriteGroups();
//     notifyListeners();
//   }

//   Future<void> searchGroup(String text) async {
//     searchDebounce?.cancel();
//     searchDebounce = Timer(const Duration(milliseconds: 150), () {
//       _performSearch(text);
//     });
//   }

//   void _performSearch(String text) {
//     final searchQuery = text.trim();

//     if (searchQuery.isEmpty) {
//       _filteredGroups = _allGroups;
//       isSearchingGroups = false;
//     } else {
//       isSearchingGroups = true;
//       _filteredGroups = _allGroups.where((groups) {
//         return groups.name.toLowerCase().contains(searchQuery.toLowerCase());
//       }).toList();
//     }
//     _searchQuery = searchQuery.isEmpty ? null : searchQuery;
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     searchDebounce?.cancel();
//     super.dispose();
//   }
// }

// import 'dart:async';
// import 'package:bsuir/domain/entity/groups.dart';
// import 'package:bsuir/ui/widgets/navigation/main_navigation.dart';
// import 'package:flutter/material.dart';
// import 'package:bsuir/domain/api_client/api_client.dart';
// import 'package:bsuir/services/favorite_service.dart';

// class SearchGroupModel extends ChangeNotifier {
//   final apiClient = ApiClient();
//   var _allGroups = <Groups>[];
//   var _filteredGroups = <Groups>[];
//   var _favoriteGroups = <Groups>[];
//   var isSearchingGroups = false;
//   Timer? searchDebounce;
//   String? _searchQuery;

//   List<Groups> get groups => _filteredGroups;
//   List<Groups> get favoriteGroups => _favoriteGroups;

//   void onGroupTap(BuildContext context, String groupName) {
//     final groupNumber = int.parse(groupName);
//     Navigator.of(context).pushNamed(
//       MainNavigationRouteNames.mainGroup,
//       arguments: groupNumber,
//     ).then((_) {

//       refreshFavorites();
//     });
//   }

//   Future<void> getAllGroups() async {
//     final groups = await apiClient.getGroups();
//     _allGroups = groups;
//     _filteredGroups = groups;

//     await _loadFavoriteGroups();

//     notifyListeners();
//   }

//   Future<void> _loadFavoriteGroups() async {
//     final favoriteIds = await FavoriteService.getAllFavorites();

//     _favoriteGroups = _allGroups.where((group) {
//       return favoriteIds.contains(group.name);
//     }).toList();

//     _favoriteGroups.sort((a, b) => a.name.compareTo(b.name));
//   }

//   Future<void> refreshFavorites() async {
//     await _loadFavoriteGroups();
//     notifyListeners();
//   }

//   Future<void> searchGroup(String text) async {
//     searchDebounce?.cancel();
//     searchDebounce = Timer(const Duration(milliseconds: 150), () {
//       _performSearch(text);
//     });
//   }

//   void _performSearch(String text) {
//     final searchQuery = text.trim();

//     if (searchQuery.isEmpty) {
//       _filteredGroups = _allGroups;
//       isSearchingGroups = false;
//     } else {
//       isSearchingGroups = true;
//       _filteredGroups = _allGroups.where((groups) {
//         return groups.name.toLowerCase().contains(searchQuery.toLowerCase());
//       }).toList();
//     }
//     _searchQuery = searchQuery.isEmpty ? null : searchQuery;
//     notifyListeners();
//   }

//   @override
//   void dispose() {
//     searchDebounce?.cancel();
//     super.dispose();
//   }
// }

import 'dart:async';
import 'package:bsuir/domain/entity/groups.dart';
import 'package:bsuir/ui/widgets/navigation/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:bsuir/domain/api_client/api_client.dart';
import 'package:bsuir/services/favorite_group_service.dart';

class SearchGroupModel extends ChangeNotifier {
  final apiClient = ApiClient();
  var _allGroups = <Groups>[];
  var _filteredGroups = <Groups>[];
  var _favoriteGroups = <Groups>[];
  var isSearchingGroups = false;
  Timer? searchDebounce;
  String? _searchQuery;

  List<Groups> get groups => _filteredGroups;
  List<Groups> get favoriteGroups => _favoriteGroups;

  void onGroupTap(BuildContext context, String groupName) {
    final groupNumber = int.parse(groupName);
    Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.mainGroup, arguments: groupNumber)
        .then((_) {
          // Когда возвращаемся с экрана расписания, обновляем избранное
          refreshFavorites();
        });
  }

  Future<void> getAllGroups() async {
    final groups = await apiClient.getGroups();
    _allGroups = groups;
    _filteredGroups = groups;

    // Загружаем избранные группы с сохранением порядка
    await _loadFavoriteGroups();

    notifyListeners();
  }

  // Загрузка избранных групп с сохранением порядка (последний добавленный - первый)
  Future<void> _loadFavoriteGroups() async {
    try {
      // Получаем ID избранных в порядке добавления (последний - первый)
      final favoriteIds = await FavoriteService.getAllFavorites();

      // Находим группы по ID
      final favoriteGroupsMap = <String, Groups>{};
      for (final group in _allGroups) {
        if (favoriteIds.contains(group.name)) {
          favoriteGroupsMap[group.name] = group;
        }
      }

      // Восстанавливаем порядок избранных
      _favoriteGroups = [];
      for (final id in favoriteIds) {
        final group = favoriteGroupsMap[id];
        if (group != null) {
          _favoriteGroups.add(group);
        }
      }
    } catch (e) {
      print('Ошибка загрузки избранных групп: $e');
      _favoriteGroups = [];
    }
  }

  // Обновить список избранных
  Future<void> refreshFavorites() async {
    await _loadFavoriteGroups();
    notifyListeners();
  }

  Future<void> searchGroup(String text) async {
    searchDebounce?.cancel();
    searchDebounce = Timer(const Duration(milliseconds: 150), () {
      _performSearch(text);
    });
  }

  void _performSearch(String text) {
    final searchQuery = text.trim();

    if (searchQuery.isEmpty) {
      _filteredGroups = _allGroups;
      isSearchingGroups = false;
    } else {
      isSearchingGroups = true;
      _filteredGroups = _allGroups.where((groups) {
        return groups.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    _searchQuery = searchQuery.isEmpty ? null : searchQuery;
    notifyListeners();
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    super.dispose();
  }
}
