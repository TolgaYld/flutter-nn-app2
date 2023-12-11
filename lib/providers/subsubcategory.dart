import 'package:flutter/material.dart';

class Subsubcategory with ChangeNotifier {
  final String? id;
  final String name;
  final String? color;
  final String categoryId;
  final String subcategoryId;

  Subsubcategory({
    this.id,
    required this.name,
    this.color,
    required this.categoryId,
    required this.subcategoryId,
  });
}
