import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/http_exception.dart';
import '../providers/i_want_it_stad.dart';

import '../models/enviroment.dart';

class IWantItStads with ChangeNotifier {
  List<IWantItStad> _iWantIts = [];

  List<IWantItStad> get iWantItsStad {
    return [..._iWantIts];
  }

  List<IWantItStad> findByStadId(String id) {
    return _iWantIts.where((iwis) => iwis.stadId == id).toList();
  }

  bool findMe(String id) {
    final iwantIt = _iWantIts.firstWhere((iwi) => iwi.customerId == id);

    if (iwantIt == null) {
      return false;
    }
    return true;
  }

  Future<void> fetchIwantItStadsAll() async {
    _iWantIts.clear();
    String _iWantItsUrl = Enviroment.baseUrl + '/iWantItStad/all';
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

          final List<IWantItStad> _loadedIWantIts = [];

          for (var address in _responseData) {
            _loadedIWantIts.add(
              IWantItStad(
                id: address["id"],
                customerId: address["customer_id"],
                stadId: address["stad_id"],
              ),
            );
          }

          _iWantIts = _loadedIWantIts;

          notifyListeners();
        }
      }
    } catch (e) {
      throw HttpException(
          message: "Can not fetch I want it stads: " + e.toString());
    }
  }

  Future<void> fetchIwantItStads({required String stadId}) async {
    _iWantIts.clear();
    String _iWantItsUrl = Enviroment.baseUrl + '/iWantItStad/all/' + stadId;
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

          final List<IWantItStad> _loadedIWantIts = [];

          for (var address in _responseData) {
            _loadedIWantIts.add(
              IWantItStad(
                id: address["id"],
                customerId: address["customer_id"],
                stadId: address["stad_id"],
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

  Future<void> createAndDelete(String stadId) async {
    String _iWantItStadCD = Enviroment.baseUrl + '/iWantItStad/createAndDelete';
    Dio _dio = Dio();
    try {
      FlutterSecureStorage _secure = FlutterSecureStorage();
      String? _tkn = await _secure.read(key: "token");
      Response _responseAddress = await _dio.post(
        _iWantItStadCD,
        data: {
          'stad_id': stadId,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey
          },
        ),
      );

      if (_responseAddress.statusCode == 200) {
        final _responseData = await _responseAddress.data;
        if (_responseData != null) {
          if (_responseAddress.data[0] != null) {
            if (_responseAddress.data[0]["statusCode"] != null) {
              throw HttpException(
                  message: "${_responseAddress.data[0]["message"]}");
            }
          }
        }
        await fetchIwantItStads(stadId: stadId);
        notifyListeners();
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Addresses: " + e.toString());
    }
  }
}
