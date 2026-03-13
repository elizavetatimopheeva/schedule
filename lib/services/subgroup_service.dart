import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

enum SubgroupType { all, first, second }

extension SubgroupFilterExtension on SubgroupType {
  String get displayName {
    switch (this) {
      case SubgroupType.all:
        return 'Вся группа';
      case SubgroupType.first:
        return '1 подгруппа';
      case SubgroupType.second:
        return '2 подгруппа';
    }
  }

  int? get subgroupNumber {
    switch (this) {
      case SubgroupType.first:
        return 1;
      case SubgroupType.second:
        return 2;
      case SubgroupType.all:
        return null;
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

  static Future<void> setSubgroupFilter(
    String groupId,
    SubgroupType filter,
  ) async {
    await _ensureInitialized();
    final key = 'subgroup_$groupId';
    await _subgroupBoxInstance!.put(key, filter.toString());
  }

  static Future<SubgroupType> getSubgroupFilter(String groupId) async {
    await _ensureInitialized();
    final key = 'subgroup_$groupId';
    final value = _subgroupBoxInstance!.get(key);

    if (value != null) {
      switch (value) {
        case 'SubgroupFilter.first':
          return SubgroupType.first;
        case 'SubgroupFilter.second':
          return SubgroupType.second;
        default:
          return SubgroupType.all;
      }
    }
    return SubgroupType.all; 
  }

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
