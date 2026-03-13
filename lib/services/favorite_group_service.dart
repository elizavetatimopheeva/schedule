import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class FavoriteGroupService {
  static const String _favoritesBox = 'favorites_box';
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

  static Future<void> addToFavorites(String groupId) async {
    await _ensureInitialized();
    final order = await _getFavoriteOrder();
    order.remove(groupId);
    order.insert(0, groupId);
    await _saveFavoriteOrder(order);
    await _favoritesBoxInstance!.put(groupId, groupId);
  }

  static Future<void> removeFromFavorites(String groupId) async {
    await _ensureInitialized();
    final order = await _getFavoriteOrder();
    order.remove(groupId);
    await _saveFavoriteOrder(order);
    await _favoritesBoxInstance!.delete(groupId);
  }

  static Future<bool> isFavoriteGroup(String groupId) async {
    await _ensureInitialized();
    return _favoritesBoxInstance!.containsKey(groupId);
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

  static Future<String?> initialFavoriteGroup() async {
    try {
      await _ensureInitialized();
      final favoriteIds = await getAllFavorites();
      if (favoriteIds.isNotEmpty) {
        return favoriteIds.first;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<void> toggleFavorite(String groupId) async {
    await _ensureInitialized();
    if (await isFavoriteGroup(groupId)) {
      await removeFromFavorites(groupId);
    } else {
      await addToFavorites(groupId);
    }
  }

  static Future<void> close() async {
    if (_isInitialized) {
      await _favoritesBoxInstance!.close();
      _isInitialized = false;
    }
  }
}
