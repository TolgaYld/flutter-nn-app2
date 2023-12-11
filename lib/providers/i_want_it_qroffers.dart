import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nownow_customer/providers/i_want_it_qroffer.dart';
import '../models/http_exception.dart';
import '../providers/i_want_it_stad.dart';

import '../models/enviroment.dart';

class IWantItQroffers with ChangeNotifier {
  List<IWantItQroffer> _iWantIts = [];

  List<IWantItQroffer> get iWantItsQroffer {
    return [..._iWantIts];
  }

  List<IWantItQroffer> findByQrofferId(String id) {
    return _iWantIts.where((iwis) => iwis.qrofferId == id).toList();
  }

  bool findMe(String id) {
    final iwantIt = _iWantIts.firstWhere((iwi) => iwi.customerId == id);

    if (iwantIt == null) {
      return false;
    }
    return true;
  }

  Future<void> fetchIwantItQroffersAll() async {
    _iWantIts.clear();
    String _iWantItsUrl = Enviroment.baseUrl + '/iWantItQroffer/all';
    Dio _dio = Dio();
    try {
      FlutterSecureStorage _secure = FlutterSecureStorage();
      String? _tkn = await _secure.read(key: "token");
      Response _responseAddress = await _dio.get(
        _iWantItsUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey
          },
        ),
      );

      if (_responseAddress.statusCode == 200) {
        List _responseData = await _responseAddress.data;
        if (_responseData.isNotEmpty) {
          if (_responseAddress.data[0] != null) {
            if (_responseAddress.data[0]["statusCode"] != null) {
              throw HttpException(
                  message: "${_responseAddress.data[0]["message"]}");
            }
          }

          final List<IWantItQroffer> _loadedIWantIts = [];

          for (var address in _responseData) {
            _loadedIWantIts.add(
              IWantItQroffer(
                id: address["id"],
                customerId: address["customer_id"],
                qrofferId: address["qroffer_id"],
              ),
            );
          }

          _iWantIts = _loadedIWantIts;

          notifyListeners();
        }
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Addresses: " + e.toString());
    }
  }

  Future<void> fetchIwantItQroffers({required String qrofferId}) async {
    _iWantIts.clear();
    String _iWantItsUrl =
        Enviroment.baseUrl + '/iWantItQroffer/all/' + qrofferId;
    Dio _dio = Dio();
    try {
      FlutterSecureStorage _secure = FlutterSecureStorage();
      String? _tkn = await _secure.read(key: "token");
      Response _responseAddress = await _dio.get(
        _iWantItsUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey
          },
        ),
      );

      if (_responseAddress.statusCode == 200) {
        List _responseData = await _responseAddress.data;
        if (_responseData.isNotEmpty) {
          if (_responseAddress.data[0] != null) {
            if (_responseAddress.data[0]["statusCode"] != null) {
              throw HttpException(
                  message: "${_responseAddress.data[0]["message"]}");
            }
          }

          final List<IWantItQroffer> _loadedIWantIts = [];

          for (var address in _responseData) {
            _loadedIWantIts.add(
              IWantItQroffer(
                id: address["id"],
                customerId: address["customer_id"],
                qrofferId: address["qroffer_id"],
              ),
            );
          }

          _iWantIts = _loadedIWantIts;

          notifyListeners();
        }
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Addresses: " + e.toString());
    }
  }

  Future<void> createAndDelete(String qrofferId) async {
    String _iWantItQrofferCD =
        Enviroment.baseUrl + '/iWantItQroffer/createAndDelete';
    Dio _dio = Dio();
    try {
      FlutterSecureStorage _secure = FlutterSecureStorage();
      String? _tkn = await _secure.read(key: "token");
      Response _responseAddress = await _dio.post(
        _iWantItQrofferCD,
        data: {
          'qroffer_id': qrofferId,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey
          },
        ),
      );

      if (_responseAddress.statusCode == 200) {
        List _responseData = await _responseAddress.data;
        if (_responseData.isNotEmpty) {
          if (_responseAddress.data[0] != null) {
            if (_responseAddress.data[0]["statusCode"] != null) {
              throw HttpException(
                  message: "${_responseAddress.data[0]["message"]}");
            }
          }

          await fetchIwantItQroffers(qrofferId: qrofferId);
        }
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Addresses: " + e.toString());
    }
  }
}
