import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:linkorize/models/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoSuchKey implements Exception {
  final String cause;

  NoSuchKey(this.cause);
}

class MemoryDataManager extends ChangeNotifier {
  static Future<List<Category>> getAllCategories() async {
    final inst = await SharedPreferences.getInstance();
    final allCategoriesId = inst.getKeys();
    final allCategories = <Category>[];

    for (String categoryId in allCategoriesId) {
      allCategories.add(
        Category.fromJson(
          jsonDecode(inst.getString(categoryId)!),
        ),
      );
    }

    return allCategories;
  }

  static Future<Category> getCategory(String id) async {
    final inst = await SharedPreferences.getInstance();
    if (!inst.getKeys().contains(id)) {
      throw NoSuchKey("Category $id is not saved");
    }

    return Category.fromJson(jsonDecode(inst.getString(id)!));
  }

  static Future<void> addNewCategory(Category newCategory) async {
    final inst = await SharedPreferences.getInstance();

    if (inst.getKeys().contains(newCategory.id)) {
      throw Exception(
        "[ERROR WHILE ADDING NEW CATEGORY] Category ${newCategory.id} already exists, try to CHANGE it",
      );
    }

    inst.setString(newCategory.id, jsonEncode(newCategory.toJson()));
  }

  static Future<void> changeCategory(
    String id,
    Category changedCategory,
  ) async {
    final inst = await SharedPreferences.getInstance();

    if (!inst.getKeys().contains(id)) {
      throw NoSuchKey("Category $id is not saved");
    }

    inst.setString(id, jsonEncode(changedCategory.toJson()));
  }

  static Future<void> removeCategory(String id) async {
    final inst = await SharedPreferences.getInstance();

    if (!inst.getKeys().contains(id)) {
      throw NoSuchKey(
        "Category $id is not saved and therefor cannot be deleted",
      );
    }

    await inst.remove(id);
  }
}
