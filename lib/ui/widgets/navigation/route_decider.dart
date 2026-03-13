import 'package:bsuir/services/favorite_group_service.dart';

class RouteDecider {
  static Future<String?> getFirstFavoriteGroup() async {
    try {
      return await FavoriteGroupService.initialFavoriteGroup();
    } catch (e) {
      return null;
    }
  }
}
