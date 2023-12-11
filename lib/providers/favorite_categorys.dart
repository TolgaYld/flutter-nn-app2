import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/enviroment.dart';
import '../providers/favorite_category.dart';
import '../models/http_exception.dart';

class FavoriteCategorys with ChangeNotifier {
  List<FavoriteCategory> _categorys = [];

  final String? authToken;

  FavoriteCategorys(this.authToken, this._categorys);

  List<FavoriteCategory> get categorys {
    return [..._categorys];
  }

  Future<void> createOrDeleteFavoriteCategory(String? categoryId,
      String? subcategoryId, String? subsubcategoryId) async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    String _categorysUrl = Enviroment.baseUrl +
        '/favoriteCategorys/createAndDeleteFavoriteCategory';

    Dio _dio = Dio();
    try {
      Response _responseCategory = await _dio.post(_categorysUrl,
          data: {
            'subsubcategory_id': subsubcategoryId,
            'subcategory_id': subcategoryId,
            'category_id': categoryId,
          },
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseCategory.statusCode == 200) {
        if (_responseCategory.data.length > 0) {
          if (_responseCategory.data[0] != null) {
            if (_responseCategory.data[0]["statusCode"] != null) {
              throw HttpException(
                  message: "${_responseCategory.data[0]["message"]}");
            }
          }
        }
      } else {
        throw HttpException(message: _responseCategory.statusMessage!);
      }
      await fetchAllCategorys();
    } catch (e) {
      print(e);
      throw HttpException(message: e.toString());
    }
  }

  Future<void> fetchAllCategorys() async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    String _categorysUrl = Enviroment.baseUrl + '/favoriteCategorys';
    Dio _dio = Dio();
    try {
      Response _responseCategory = await _dio.get(_categorysUrl,
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseCategory.statusCode == 200) {
        final List<FavoriteCategory> _loadedCategorys = [];
        _categorys.clear();
        for (var category in await _responseCategory.data) {
          _loadedCategorys.add(FavoriteCategory(
            id: category["id"],
            subsubcategoryId: category["subsubcategory_id"],
            subcategoryId: category["subcategory_id"],
            categoryId: category["category_id"],
            isDeleted: category["is_deleted"],
            customerId: category["customer_id"],
          ));
        }

        _categorys = _loadedCategorys;
        notifyListeners();
      } else {
        throw HttpException(message: _responseCategory.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: e.toString());
    }
  }
}
