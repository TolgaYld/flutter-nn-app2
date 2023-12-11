import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/favorite_category.dart';
import '../providers/favorite_categorys.dart';
import '../providers/category.dart';
import '../providers/categorys.dart';
import '../providers/subcategory.dart';
import '../providers/subcategorys.dart';
import '../providers/subsubcategory.dart';
import '../providers/subsubcategorys.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  List<Category> _categorys = [];
  List<Subcategory> _subcategorys = [];
  List<Subsubcategory> _subsubcategorys = [];
  List<FavoriteCategory> _favoriteCategorys = [];

  final Color _starColor = Colors.orangeAccent;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
      // _secureStorage.deleteAll();
      setState(() {
        _isLoading = true;
      });
      Provider.of<Categorys>(context, listen: false)
          .fetchAllCategorys()
          .then((_) {
        Provider.of<Subcategorys>(context, listen: false)
            .fetchAllSubcategorys()
            .then((_) {
          Provider.of<Subsubcategorys>(context, listen: false)
              .fetchAllSubsubcategorys()
              .then((_) {
            Provider.of<FavoriteCategorys>(context, listen: false)
                .fetchAllCategorys()
                .then((value) async {
              setState(() {
                _isLoading = false;
                _isInit = false;
              });
            });
          });
        });
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _categorys = Provider.of<Categorys>(context, listen: true).categorys;
    _subcategorys =
        Provider.of<Subcategorys>(context, listen: true).subcategorys;
    _subsubcategorys =
        Provider.of<Subsubcategorys>(context, listen: true).subsubcategorys;
    _favoriteCategorys =
        Provider.of<FavoriteCategorys>(context, listen: true).categorys;
    return _isLoading
        ? Center(
            child: Platform.isAndroid
                ? const CircularProgressIndicator()
                : const CupertinoActivityIndicator(),
          )
        : Scaffold(
            body: ListView(
              children: _categorys.map((category) {
                List<Subcategory> _filteredSubcategorys = _subcategorys
                    .where((element) => element.categoryId == category.id)
                    .toList();
                return ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.081,
                          ),
                          child: IconButton(
                            onPressed: () async {
                              try {
                                await Provider.of<FavoriteCategorys>(context,
                                        listen: false)
                                    .createOrDeleteFavoriteCategory(
                                        category.id, null, null);
                              } catch (e) {
                                print(e);
                              }
                            },
                            icon: _favoriteCategorys
                                        .where((element) =>
                                            element.categoryId == category.id)
                                        .toList()
                                        .length ==
                                    _subsubcategorys
                                        .where((element) =>
                                            element.categoryId == category.id)
                                        .toList()
                                        .length
                                ? Icon(
                                    FontAwesomeIcons.solidStar,
                                    color: _starColor,
                                  )
                                : _favoriteCategorys
                                                .where((element) =>
                                                    element.categoryId ==
                                                    category.id)
                                                .toList()
                                                .length <
                                            _subsubcategorys
                                                .where((element) =>
                                                    element.categoryId ==
                                                    category.id)
                                                .toList()
                                                .length &&
                                        _favoriteCategorys
                                            .where((element) =>
                                                element.categoryId ==
                                                category.id)
                                            .toList()
                                            .isNotEmpty
                                    ? Icon(
                                        FontAwesomeIcons.starHalfAlt,
                                        color: _starColor,
                                      )
                                    : _favoriteCategorys
                                            .where((element) =>
                                                element.categoryId ==
                                                category.id)
                                            .toList()
                                            .isEmpty
                                        ? Icon(
                                            FontAwesomeIcons.star,
                                            color: _starColor,
                                          )
                                        : const Icon(
                                            Icons.ac_unit,
                                            color: Colors.transparent,
                                          ),
                          ),
                        ),
                      ],
                    ),
                    children: _filteredSubcategorys.map((subcategory) {
                      List<Subsubcategory> _filteredSubsubcategorys =
                          _subsubcategorys
                              .where((element) =>
                                  element.categoryId == category.id &&
                                  element.subcategoryId == subcategory.id)
                              .toList();
                      return Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.0333,
                        ),
                        child: ExpansionTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  subcategory.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                IconButton(
                                  onPressed: () async {
                                    try {
                                      await Provider.of<FavoriteCategorys>(
                                              context,
                                              listen: false)
                                          .createOrDeleteFavoriteCategory(
                                              null, subcategory.id, null);
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  icon: _favoriteCategorys
                                              .where((element) =>
                                                  element.subcategoryId ==
                                                  subcategory.id)
                                              .toList()
                                              .length ==
                                          _subsubcategorys
                                              .where((element) =>
                                                  element.subcategoryId ==
                                                  subcategory.id)
                                              .toList()
                                              .length
                                      ? Icon(
                                          FontAwesomeIcons.solidStar,
                                          color: _starColor,
                                        )
                                      : _favoriteCategorys
                                                      .where((element) =>
                                                          element.subcategoryId ==
                                                          subcategory.id)
                                                      .toList()
                                                      .length <
                                                  _subsubcategorys
                                                      .where((element) =>
                                                          element
                                                              .subcategoryId ==
                                                          subcategory.id)
                                                      .toList()
                                                      .length &&
                                              _favoriteCategorys
                                                  .where((element) =>
                                                      element.subcategoryId ==
                                                      subcategory.id)
                                                  .toList()
                                                  .isNotEmpty
                                          ? Icon(
                                              FontAwesomeIcons.starHalfAlt,
                                              color: _starColor,
                                            )
                                          : _favoriteCategorys
                                                  .where((element) =>
                                                      element.subcategoryId == subcategory.id)
                                                  .toList()
                                                  .isEmpty
                                              ? Icon(
                                                  FontAwesomeIcons.star,
                                                  color: _starColor,
                                                )
                                              : const Icon(
                                                  Icons.ac_unit,
                                                  color: Colors.transparent,
                                                ),
                                ),
                              ],
                            ),
                            children:
                                _filteredSubsubcategorys.map((subsubcategory) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width *
                                      0.0333,
                                ),
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        subsubcategory.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          try {
                                            await Provider.of<
                                                        FavoriteCategorys>(
                                                    context,
                                                    listen: false)
                                                .createOrDeleteFavoriteCategory(
                                                    null,
                                                    null,
                                                    subsubcategory.id);
                                          } catch (e) {
                                            print(e);
                                          }
                                        },
                                        icon: _favoriteCategorys
                                                    .where((element) =>
                                                        element
                                                            .subsubcategoryId ==
                                                        subsubcategory.id)
                                                    .toList()
                                                    .length ==
                                                _subsubcategorys
                                                    .where((element) =>
                                                        element.id ==
                                                        subsubcategory.id)
                                                    .toList()
                                                    .length
                                            ? Icon(
                                                FontAwesomeIcons.solidStar,
                                                color: _starColor,
                                              )
                                            : Icon(
                                                FontAwesomeIcons.star,
                                                color: _starColor,
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList()),
                      );
                    }).toList());
              }).toList(),
            ),
          );
  }
}
