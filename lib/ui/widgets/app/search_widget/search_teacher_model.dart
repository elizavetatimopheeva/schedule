import 'dart:async';
import 'package:bsuir/domain/entity/groups.dart';
import 'package:bsuir/domain/entity/teachers.dart';
import 'package:bsuir/ui/widgets/navigation/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:bsuir/domain/api_client/api_client.dart';
import 'package:bsuir/services/favorite_teacher_service.dart';

class SearchTeacherModel extends ChangeNotifier {
  final apiClient = ApiClient();
  var _allTeachers = <Teachers>[];
  var _filteredTeachers = <Teachers>[];
  var _favoriteTeachers = <Teachers>[]; 
  var isSearchingTeachers = false;
  Timer? searchDebounce;
  String? _searchQuery;
  
  List<Teachers> get teachers => _filteredTeachers;
  List<Teachers> get favoriteTeachers => _favoriteTeachers;

  Future<void> getAllTeachers() async {
    final teachers = await apiClient.getTeachers();
    _allTeachers = teachers;
    _filteredTeachers = teachers;
    
    await _loadFavoriteTeachers();
    
    notifyListeners();
  }

  // Загрузка избранных преподавателей
  Future<void> _loadFavoriteTeachers() async {
    try {
      // Получаем ID избранных в порядке добавления (последний - первый)
      final favoriteIds = await FavoriteTeacherService.getAllFavorites();
      
      // Находим преподавателей по ID
      final favoriteTeachersMap = <String, Teachers>{};
      for (final teacher in _allTeachers) {
        if (favoriteIds.contains(teacher.urlId)) {
          favoriteTeachersMap[teacher.urlId] = teacher;
        }
      }
      
      // Восстанавливаем порядок избранных
      _favoriteTeachers = [];
      for (final id in favoriteIds) {
        final teacher = favoriteTeachersMap[id];
        if (teacher != null) {
          _favoriteTeachers.add(teacher);
        }
      }
    } catch (e) {
      print('Ошибка загрузки избранных преподавателей: $e');
      _favoriteTeachers = [];
    }
  }

  // Обновить список избранных
  Future<void> refreshFavorites() async {
    await _loadFavoriteTeachers();
    notifyListeners();
  }

  // Проверка избранного
  Future<bool> isTeacherFavorite(String teacherId) async {
    return await FavoriteTeacherService.isFavorite(teacherId);
  }

  // Переключить избранное
  Future<void> toggleTeacherFavorite(String teacherId) async {
    await FavoriteTeacherService.toggleFavorite(teacherId);
    await refreshFavorites();
  }

  void onTeacherTap(BuildContext context, String teacherId) {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.mainTeacher,
      arguments: teacherId,
    ).then((_) {
      refreshFavorites();
    });
  }

  Future<void> searchTeacher(String text) async {
    searchDebounce?.cancel();
    searchDebounce = Timer(const Duration(milliseconds: 250), (){ 
      _performSearch(text);
    });
  }

  void _performSearch(String text) {
    final searchQuery = text.trim();

    if (searchQuery.isEmpty) {
      _filteredTeachers = _allTeachers;
      isSearchingTeachers = false;
    } else {
      isSearchingTeachers = true;
      _filteredTeachers = _allTeachers.where((teacher) {
        return teacher.firstName.toLowerCase().contains(searchQuery.toLowerCase()) ||
               teacher.lastName.toLowerCase().contains(searchQuery.toLowerCase())  ?? false;
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
