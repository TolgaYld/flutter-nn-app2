import 'package:flutter/material.dart';

class FavoriteCategory with ChangeNotifier {
  final String? id;
  final String subsubcategoryId;
  final String subcategoryId;
  final String categoryId;
  final String? customerId;
  final bool? isDeleted;

  FavoriteCategory({
    this.id,
    required this.subsubcategoryId,
    required this.subcategoryId,
    required this.categoryId,
    this.customerId,
    this.isDeleted,
  });
}
