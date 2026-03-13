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
          refreshFavorites();
        });
  }

  Future<void> getAllGroups() async {
    final groups = await apiClient.getGroups();
    _allGroups = groups;
    _filteredGroups = groups;

    await _loadFavoriteGroups();

    notifyListeners();
  }

  Future<void> _loadFavoriteGroups() async {
    try {
      final favoriteIds = await FavoriteGroupService.getAllFavorites();

      final favoriteGroupsMap = <String, Groups>{};
      for (final group in _allGroups) {
        if (favoriteIds.contains(group.name)) {
          favoriteGroupsMap[group.name] = group;
        }
      }

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
