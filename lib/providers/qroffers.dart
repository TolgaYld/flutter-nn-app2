import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nownow_customer/models/enviroment.dart';
import '../providers/qroffer.dart';
import '../models/http_exception.dart';

class Qroffers with ChangeNotifier {
  List<Qroffer> _qroffers = [];

  final List<Timer> _timers = [];

  final String? authToken;

  Qroffers(this.authToken, this._qroffers);

  List<Qroffer> get qroffers {
    return [..._qroffers];
  }

  List<Qroffer>? activeQroffers(String addressId) {
    return _qroffers
        .where((qroffer) =>
            (qroffer.isActive == true && qroffer.addressId == addressId))
        .toList();
  }

  Qroffer findById(String id) {
    return _qroffers.firstWhere((qrf) => qrf.id == id);
  }

  List<Qroffer> findByAddressId(String addressId) {
    return _qroffers.where((qrf) => qrf.addressId == addressId).toList();
  }

  List<Qroffer> nowAndFuture(String addressId) {
    return _qroffers
        .where((qroffer) => (qroffer.isDeleted == false &&
            qroffer.addressId == addressId &&
            qroffer.isArchive == false &&
            qroffer.isBanned == false))
        .toList();
  }

  List<Qroffer> future(String addressId) {
    return _qroffers
        .where((qroffer) => (qroffer.isDeleted == false &&
            qroffer.addressId == addressId &&
            qroffer.isArchive == false &&
            qroffer.isActive == false &&
            qroffer.begin!.isAfter(DateTime.now().toUtc()) &&
            qroffer.isBanned == false))
        .toList();
  }

  List<Qroffer> now(String addressId) {
    return _qroffers
        .where((qroffer) => (qroffer.isDeleted == false &&
            qroffer.isActive == true &&
            qroffer.addressId == addressId &&
            qroffer.isBanned == false))
        .toList();
  }

  List<Qroffer> addressId(String addressId) {
    return _qroffers
        .where((qroffer) =>
            (qroffer.addressId == addressId && qroffer.isBanned == false))
        .toList();
  }

  List<Qroffer> deleted(String addressId) {
    return _qroffers
        .where((qroffer) => (qroffer.addressId == addressId &&
            qroffer.isBanned == false &&
            qroffer.isDeleted == true))
        .toList();
  }

  Future<void> fetchQroffers() async {
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    String _myAddressesUrl =
        Enviroment.baseUrl + '/qroffer/findQroffersForCustomer';

    Dio _dio = Dio();
    try {
      Response _responseQroffers = await _dio.get(_myAddressesUrl,
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseQroffers.statusCode == 200) {
        final List _responseData = await _responseQroffers.data;
        final List<Qroffer> _loadedQroffers = [];
        for (var qroffer in _responseData) {
          _loadedQroffers.add(
            Qroffer(
              id: qroffer["id"],
              title: qroffer["title"],
              latitude: qroffer["latitude"],
              longitude: qroffer["longitude"],
              shortDescription: qroffer["short_description"],
              longDescription: qroffer["long_description"],
              price: double.parse(qroffer["price"].toString()),
              taxPrice: double.parse(qroffer["tax_price"].toString()),
              gross: double.parse(qroffer["gross"].toString()),
              type: qroffer["type"],
              media: qroffer["media"],
              begin: qroffer["begin"] != null
                  ? DateTime.parse(qroffer["begin"])
                  : null,
              end: qroffer["end"] != null
                  ? DateTime.parse(qroffer["end"])
                  : null,
              qrValue: int.parse(qroffer["qr_value"].toString()),
              liveQrValue: int.parse(qroffer["live_qr_value"].toString()),
              redeemedQrValue:
                  int.parse(qroffer["redeemed_qr_value"].toString()),
              expiryDate: qroffer["expiry_date"] != null
                  ? DateTime.parse(qroffer["expiry_date"])
                  : null,
              displayRadius: double.parse(qroffer["display_radius"].toString()),
              pushNotificationRadius:
                  double.parse(qroffer["push_notification_radius"].toString()),
              categoryId: qroffer["category_id"],
              subcategoryId: qroffer["subcategory_id"],
              advertiserId: qroffer["advertiser_id"],
              isActive: qroffer["is_active"],
              isBanned: qroffer["is_banned"],
              isDeleted: qroffer["is_deleted"],
              isArchive: qroffer["is_archive"],
              addressId: qroffer["address_id"],
              createdAt: DateTime.parse(qroffer["created_at"]),
              invoiceAddressId: qroffer["invoice_address_id"],
              completelyDeleted: qroffer["completely_deleted"],
              inInvoice: qroffer["in_invoice"],
              invoiceDate: qroffer["invoice_date"] != null
                  ? DateTime.parse(qroffer["invoice_date"])
                  : null,
              invoiceId: qroffer["invoice_id"],
              isEditable: DateTime.parse(qroffer["created_at"])
                          .add(Duration(minutes: 3))
                          .difference(DateTime.now().toUtc())
                          .inSeconds >
                      0
                  ? true
                  : false,
              distance: qroffer["distance"],
            ),
          );
        }
        _qroffers = _loadedQroffers;
        notifyListeners();
        await setQrofferActive();
      }
    } catch (e) {
      print(e);
      throw HttpException(message: "Can not fetch Qroffers.");
    }
  }

  Future<void> setQrofferActive() async {
    if (_timers.isNotEmpty) {
      _timers.forEach((element) => element.cancel());
      _timers.clear();
    }
    _qroffers.forEach((qrf) {
      if (!qrf.isActive!) {
        if (!qrf.isArchive!) {
          if (qrf.begin != null) {
            if (!qrf.isDeleted!) {
              Timer(
                  Duration(
                      seconds: qrf.begin!
                          .difference(DateTime.now().toUtc())
                          .inSeconds), () async {
                String _url =
                    Enviroment.baseUrl + 'address//inPanel/${qrf.addressId}';
                Dio _dio = Dio();
                var response = await _dio.get(_url,
                    options: Options(headers: {
                      "Authorization": "Bearer $authToken",
                      "Permission": Enviroment.permissionKey,
                    }));
                if (response.statusCode == 200) {
                  if (response.data != null) {
                    if (!response.data["active_qroffer"]) {
                      qrf.isActive = true;
                      notifyListeners();
                    }
                  }
                }
              });
            }
          }
        }
      }
    });

    _qroffers.forEach((qrf) {
      if (qrf.isEditable!) {
        if (!qrf.isDeleted!) {
          Timer(
              Duration(
                  seconds: qrf.begin!
                      .add(const Duration(minutes: 3))
                      .difference(DateTime.now().toUtc())
                      .inSeconds), () async {
            qrf.isEditable = false;
            notifyListeners();
          });
        }
      }
    });
  }
}
