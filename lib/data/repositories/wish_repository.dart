import 'package:hive/hive.dart';

import '../models/wish_item.dart';

abstract class WishRepository {
  List<WishItem> loadAll();

  Future<void> upsert(WishItem item);

  Future<void> upsertAll(Iterable<WishItem> items);

  Future<void> delete(String id);
}

class HiveWishRepository implements WishRepository {
  HiveWishRepository(this._box);

  static const boxName = 'wish_items';

  final Box<String> _box;

  @override
  List<WishItem> loadAll() {
    final items = <WishItem>[];
    for (final raw in _box.values) {
      try {
        items.add(WishItem.fromJson(raw));
      } on Object {
        continue;
      }
    }
    return items;
  }

  @override
  Future<void> upsert(WishItem item) => _box.put(item.id, item.toJson());

  @override
  Future<void> upsertAll(Iterable<WishItem> items) {
    return _box.putAll({for (final item in items) item.id: item.toJson()});
  }

  @override
  Future<void> delete(String id) => _box.delete(id);
}
