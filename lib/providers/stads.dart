import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nownow_customer/models/enviroment.dart';
import '../models/http_exception.dart';
import '../providers/stad.dart';

class Stads with ChangeNotifier {
  List<Stad> _stads = [];

  final List<Timer> _timers = [];

  final String? authToken;

  Stads(this.authToken, this._stads);

  List<Stad> get stads {
    return [..._stads];
  }

  Stad? activeStad(String addressId) {
    if (_stads.isNotEmpty) {
      List stds = _stads
          .where((element) =>
              element.isActive == true && element.addressId == addressId.trim())
          .toList();
      if (stds.isEmpty) {
        return null;
      } else {
        return stds.first;
      }
    }
    return null;
  }

  List<Stad> nowAndFuture(String addressId) {
    return stads
        .where((std) =>
            std.addressId == addressId &&
            std.isArchive == false &&
            std.isDeleted == false &&
            std.isBanned == false)
        .toList();
  }

  List<Stad> future(String addressId) {
    return stads
        .where((std) =>
            std.addressId == addressId &&
            std.isDeleted == false &&
            std.isArchive == false &&
            std.isActive == false &&
            std.begin!.isAfter(DateTime.now().toUtc()) &&
            std.isBanned == false)
        .toList();
  }

  Stad? now(String addressId) {
    return stads.firstWhere(
      (std) =>
          std.addressId == addressId &&
          std.isActive == true &&
          std.isDeleted == false &&
          std.isBanned == false,
    );
  }

  List<Stad> addressId(String addressId) {
    return stads
        .where((std) => std.addressId == addressId && std.isBanned == false)
        .toList();
  }

  List<Stad> deleted(String addressId) {
    return stads
        .where((std) =>
            std.addressId == addressId &&
            std.isBanned == false &&
            std.isDeleted == true)
        .toList();
  }

  Stad findById(String id) {
    return _stads.firstWhere((stad) => stad.id == id);
  }

  Future<void> fetchStads() async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    String _myAddressesUrl = Enviroment.baseUrl + '/stad/findStadsForCustomer';

    Dio _dio = Dio();
    try {
      Response _responseStad = await _dio.get(_myAddressesUrl,
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseStad.statusCode == 200) {
        final List _responseData = await _responseStad.data;
        final List<Stad> _loadedStads = [];
        for (var stad in _responseData) {
          _loadedStads.add(
            Stad(
              id: stad["id"],
              title: stad["title"],
              latitude: stad["latitude"],
              longitude: stad["longitude"],
              shortDescription: stad["short_description"],
              longDescription: stad["long_description"],
              price: double.parse(stad["price"]),
              taxPrice: double.parse(stad["tax_price"]),
              gross: double.parse(stad["gross"]),
              type: stad["type"],
              media: stad["media"],
              begin:
                  stad["begin"] != null ? DateTime.parse(stad["begin"]) : null,
              end: stad["end"] != null ? DateTime.parse(stad["end"]) : null,
              displayRadius: double.parse(stad["display_radius"].toString()),
              pushNotificationRadius:
                  double.parse(stad["push_notification_radius"].toString()),
              categoryId: stad["category_id"],
              subcategoryId: stad["subcategory_id"],
              advertiserId: stad["advertiser_id"],
              isActive: stad["is_active"],
              isBanned: stad["is_banned"],
              isDeleted: stad["is_deleted"],
              isArchive: stad["is_archive"],
              addressId: stad["address_id"],
              createdAt: DateTime.parse(stad["created_at"]),
              invoiceAddressId: stad["invoice_address_id"],
              completelyDeleted: stad["completely_deleted"],
              inInvoice: stad["in_invoice"],
              invoiceDate: stad["invoice_date"] != null
                  ? DateTime.parse(stad["invoice_date"])
                  : null,
              invoiceId: stad["invoice_id"],
              isEditable: DateTime.parse(stad["created_at"])
                          .add(Duration(minutes: 3))
                          .difference(DateTime.now().toUtc())
                          .inSeconds >
                      0
                  ? true
                  : false,
              distance: stad["distance"],
            ),
          );
        }
        _stads.clear();
        _stads = _loadedStads;
        notifyListeners();
      } else {
        throw HttpException(message: _responseStad.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Stads: " + e.toString());
    }
  }

  // Future<void> setStadActive() async {
  //   if (_timers.isNotEmpty) {
  //     _timers.forEach((element) => element.cancel());
  //     _timers.clear();
  //   }
  //   _stads.forEach((std) {
  //     if (!std.isActive!) {
  //       if (!std.isArchive!) {
  //         if (std.begin != null) {
  //           if (!std.isDeleted!) {
  //             Timer(
  //                 Duration(
  //                     seconds: std.begin!
  //                         .difference(DateTime.now().toUtc())
  //                         .inSeconds), () async {
  //               String _url =
  //                   Enviroment.baseUrl + '/address//inPanel/${std.addressId}';
  //               Dio _dio = Dio();
  //               var response = await _dio.get(_url,
  //                   options: Options(headers: {
  //                     "Authorization": "Bearer $authToken",
  //                     "Permission": Enviroment.permissionKey,
  //                   }));
  //               if (response.statusCode == 200) {
  //                 if (response.data != null) {
  //                   if (!response.data["active_stad"]) {
  //                     std.isActive = true;
  //                     notifyListeners();
  //                   }
  //                 }
  //               }
  //             });
  //           }
  //         }
  //       }
  //     }
  //   });

  //   _stads.forEach((std) {
  //     if (std.isEditable!) {
  //       if (!std.isDeleted!) {
  //         Timer(
  //             Duration(
  //                 seconds: std.begin!
  //                     .add(const Duration(minutes: 3))
  //                     .difference(DateTime.now().toUtc())
  //                     .inSeconds), () async {
  //           std.isEditable = false;
  //           notifyListeners();
  //         });
  //       }
  //     }
  //   });
  // }
}
