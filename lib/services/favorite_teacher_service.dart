import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class FavoriteTeacherService {
  static const String _favoritesBox = 'favorite_teachers_box';
  static const String _orderKey = 'favorite_order';
  static Box<String>? _favoritesBoxInstance;
  static bool _isInitialized = false;

  static Future<void> initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _favoritesBoxInstance = await Hive.openBox<String>(_favoritesBox);
      _isInitialized = true;
    }
  }

  static Future<List<String>> _getFavoriteOrder() async {
    await _ensureInitialized();
    final order = _favoritesBoxInstance!.get(_orderKey);
    return order != null ? order.split(',') : [];
  }

  static Future<void> _saveFavoriteOrder(List<String> order) async {
    await _ensureInitialized();
    await _favoritesBoxInstance!.put(_orderKey, order.join(','));
  }

  static Future<void> addToFavorites(String teacherId) async {
    await _ensureInitialized();

    final order = await _getFavoriteOrder();
    order.remove(teacherId);

    order.insert(0, teacherId);

    await _saveFavoriteOrder(order);

    await _favoritesBoxInstance!.put(teacherId, teacherId);
  }

  static Future<void> removeFromFavorites(String teacherId) async {
    await _ensureInitialized();

    final order = await _getFavoriteOrder();

    order.remove(teacherId);
    await _saveFavoriteOrder(order);

    await _favoritesBoxInstance!.delete(teacherId);
  }

  static Future<bool> isFavorite(String teacherId) async {
    await _ensureInitialized();
    return _favoritesBoxInstance!.containsKey(teacherId);
  }

  static Future<List<String>> getAllFavorites() async {
    await _ensureInitialized();

    final order = await _getFavoriteOrder();

    final validOrder = order
        .where((id) => _favoritesBoxInstance!.containsKey(id))
        .toList();

    if (validOrder.length != order.length) {
      await _saveFavoriteOrder(validOrder);
    }

    return validOrder;
  }

  static Future<void> toggleFavorite(String teacherId) async {
    await _ensureInitialized();
    if (await isFavorite(teacherId)) {
      await removeFromFavorites(teacherId);
    } else {
      await addToFavorites(teacherId);
    }
  }

  static Future<void> close() async {
    if (_isInitialized) {
      await _favoritesBoxInstance!.close();
      _isInitialized = false;
    }
  }
}
