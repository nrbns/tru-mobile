import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static late Box _mainBox;
  static late Box _listsBox;
  static late Box _itemsBox;

  static Future<void> initialize() async {
    _mainBox = await Hive.openBox('main');
    _listsBox = await Hive.openBox('lists');
    _itemsBox = await Hive.openBox('items');
  }

  static Box get mainBox => _mainBox;
  static Box get listsBox => _listsBox;
  static Box get itemsBox => _itemsBox;

  static Future<void> clearAll() async {
    await _mainBox.clear();
    await _listsBox.clear();
    await _itemsBox.clear();
  }
}
