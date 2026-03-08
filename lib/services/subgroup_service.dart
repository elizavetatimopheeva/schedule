import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

enum SubgroupFilter {
  all,      // обе подгруппы (по умолчанию)
  first,    // только первая подгруппа
  second,   // только вторая подгруппа
}

extension SubgroupFilterExtension on SubgroupFilter {
  String get displayName {
    switch (this) {
      case SubgroupFilter.all:
        return 'Вся группа';
      case SubgroupFilter.first:
        return '1 подгруппа';
      case SubgroupFilter.second:
        return '2 подгруппа';
    }
  }

  int? get subgroupNumber {
    switch (this) {
      case SubgroupFilter.first:
        return 1;
      case SubgroupFilter.second:
        return 2;
      case SubgroupFilter.all:
        return null; // null означает все подгруппы
    }
  }
}

class SubgroupService {
  static const String _subgroupBox = 'subgroup_box';
  static Box<String>? _subgroupBoxInstance;
  static bool _isInitialized = false;

 static Future<void> initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _subgroupBoxInstance = await Hive.openBox<String>(_subgroupBox);
      _isInitialized = true;
    }
  }

  // Сохранить выбор подгруппы для конкретной группы
  static Future<void> setSubgroupFilter(String groupId, SubgroupFilter filter) async {
    await _ensureInitialized();
    final key = 'subgroup_$groupId';
    await _subgroupBoxInstance!.put(key, filter.toString());
  }

  // Получить выбор подгруппы для конкретной группы
  static Future<SubgroupFilter> getSubgroupFilter(String groupId) async {
    await _ensureInitialized();
    final key = 'subgroup_$groupId';
    final value = _subgroupBoxInstance!.get(key);
    
    if (value != null) {
      switch (value) {
        case 'SubgroupFilter.first':
          return SubgroupFilter.first;
        case 'SubgroupFilter.second':
          return SubgroupFilter.second;
        default:
          return SubgroupFilter.all;
      }
    }
    return SubgroupFilter.all; // по умолчанию
  }

  // Очистить выбор подгруппы (вернуть на all)
  static Future<void> resetSubgroupFilter(String groupId) async {
    await _ensureInitialized();
    final key = 'subgroup_$groupId';
    await _subgroupBoxInstance!.delete(key);
  }

  static Future<void> close() async {
    if (_isInitialized) {
      await _subgroupBoxInstance!.close();
      _isInitialized = false;
    }
  }
}