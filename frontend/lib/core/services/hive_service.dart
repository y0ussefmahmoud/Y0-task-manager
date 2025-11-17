import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../models/user.dart';

class HiveService {
  static const String tasksBoxName = 'tasks';
  static const String categoriesBoxName = 'categories';
  static const String userBoxName = 'user';
  static const String settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserAdapter());
    }
  }

  static Future<Box<Task>> get tasksBox async {
    return await Hive.openBox<Task>(tasksBoxName);
  }

  static Future<Box<Category>> get categoriesBox async {
    return await Hive.openBox<Category>(categoriesBoxName);
  }

  static Future<Box<User>> get userBox async {
    return await Hive.openBox<User>(userBoxName);
  }

  static Future<Box> get settingsBox async {
    return await Hive.openBox(settingsBoxName);
  }

  static Future<void> clearAllData() async {
    await Hive.deleteBoxFromDisk(tasksBoxName);
    await Hive.deleteBoxFromDisk(categoriesBoxName);
    await Hive.deleteBoxFromDisk(userBoxName);
    await Hive.deleteBoxFromDisk(settingsBoxName);
  }
}
