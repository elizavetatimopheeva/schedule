import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

class FavoriteTeacherService {
  static const String _favoritesBox = 'favorite_teachers_box';
  static const String _orderKey = 'favorite_order';
  static Box<String>? _favoritesBoxInstance;
  static bool _isInitialized = false;

  // Инициализация Hive
  static Future<void> initHive() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  // Инициализация
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _favoritesBoxInstance = await Hive.openBox<String>(_favoritesBox);
      _isInitialized = true;
    }
  }

  // Получить порядок избранных (последний добавленный - первый)
  static Future<List<String>> _getFavoriteOrder() async {
    await _ensureInitialized();
    final order = _favoritesBoxInstance!.get(_orderKey);
    return order != null ? order.split(',') : [];
  }

  // Сохранить порядок избранных
  static Future<void> _saveFavoriteOrder(List<String> order) async {
    await _ensureInitialized();
    await _favoritesBoxInstance!.put(_orderKey, order.join(','));
  }

  // Добавить преподавателя в избранное (в начало списка)
  static Future<void> addToFavorites(String teacherId) async {
    await _ensureInitialized();
    
    // Получаем текущий порядок
    final order = await _getFavoriteOrder();
    
    // Удаляем если уже есть (чтобы переместить в начало)
    order.remove(teacherId);
    
    // Добавляем в начало (стек: последний добавленный - первый)
    order.insert(0, teacherId);
    
    // Сохраняем порядок
    await _saveFavoriteOrder(order);
    
    // Сохраняем самого преподавателя
    await _favoritesBoxInstance!.put(teacherId, teacherId);
  }

  // Удалить преподавателя из избранного
  static Future<void> removeFromFavorites(String teacherId) async {
    await _ensureInitialized();
    
    // Получаем текущий порядок
    final order = await _getFavoriteOrder();
    
    // Удаляем из порядка
    order.remove(teacherId);
    
    // Сохраняем обновленный порядок
    await _saveFavoriteOrder(order);
    
    // Удаляем самого преподавателя
    await _favoritesBoxInstance!.delete(teacherId);
  }

  // Проверить, есть ли преподаватель в избранном
  static Future<bool> isFavorite(String teacherId) async {
    await _ensureInitialized();
    return _favoritesBoxInstance!.containsKey(teacherId);
  }

  // Получить всех избранных преподавателей в правильном порядке
  static Future<List<String>> getAllFavorites() async {
    await _ensureInitialized();
    
    // Получаем порядок
    final order = await _getFavoriteOrder();
    
    // Фильтруем только существующих преподавателей
    final validOrder = order.where((id) => _favoritesBoxInstance!.containsKey(id)).toList();
    
    // Если порядок не совпадает с реальными данными, обновляем
    if (validOrder.length != order.length) {
      await _saveFavoriteOrder(validOrder);
    }
    
    return validOrder;
  }

  // Переключить состояние избранного
  static Future<void> toggleFavorite(String teacherId) async {
    await _ensureInitialized();
    if (await isFavorite(teacherId)) {
      await removeFromFavorites(teacherId);
    } else {
      await addToFavorites(teacherId);
    }
  }

  // Закрыть коробку
  static Future<void> close() async {
    if (_isInitialized) {
      await _favoritesBoxInstance!.close();
      _isInitialized = false;
    }
  }
}