import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secure;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:nownow_customer/models/enviroment.dart';
import '../models/http_exception.dart';

class Customer with ChangeNotifier {
  String? id;
  String? email;
  String? password;
  String? gender;
  String? firstname;
  String? lastname;
  bool? isBanned;
  bool? autoPlay;
  bool? isDeleted;
  double? displayRadius;
  double? notificationRadius;
  String? providerId;
  String? _token;
  String? _refreshToken;
  DateTime? _expiryDate;
  Timer? _authTimer;
  final int _expiryDateMinusinMinutes = 60;

  Customer({
    this.id,
    this.email,
    this.password,
    this.gender,
    this.firstname,
    this.lastname,
    this.isBanned,
    this.autoPlay,
    this.isDeleted,
    this.displayRadius,
    this.notificationRadius,
    this.providerId,
  });

  bool get isAuth {
    return _token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now().toUtc()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Customer? _me;
  Customer get me {
    return _me!;
  }

  Future<Customer?> getMe() async {
    String _url = Enviroment.baseUrl + '/customer/me';
    Dio _dio = Dio();

    secure.FlutterSecureStorage _storage = secure.FlutterSecureStorage();
    String? tkn = await _storage.read(key: "token");
    String? rfrshTkn = await _storage.read(key: "refreshToken");

    try {
      Response _response = await _dio.get(_url,
          options: Options(
            headers: {
              "Authorization": "Bearer $tkn",
              "Refresh": "Bearer $rfrshTkn",
              "Permission": Enviroment.permissionKey,
            },
          ));

      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }

        final _responseData = await _response.data;

        final customerData = _responseData["customer"];
        _me = Customer(
          id: customerData["id"],
          firstname: customerData["firstname"],
          gender: customerData["gender"],
          lastname: customerData["lastname"],
          email: customerData["email"],
          isBanned: customerData["is_banned"],
          autoPlay: customerData["autoplay"],
          isDeleted: customerData["autoplay"],
          displayRadius: customerData["display_radius"],
          notificationRadius: customerData["push_notification_radius"],
        );

        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(
            key: 'token', value: await _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: await _responseData['refreshToken']);
        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];

        _expiryDate = JwtDecoder.getExpirationDate(_token.toString())
            .toUtc()
            .subtract(Duration(
              minutes: _expiryDateMinusinMinutes,
            ));
        await _secureStorage.write(
            key: 'expiryDate', value: _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();

        return _me;
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: 'fetch Me failed!: ' + e.toString());
    }
  }

  Future<void> signUp({
    required Customer customer,
    String provider = 'Local',
  }) async {
    final String _url = Enviroment.baseUrl + '/customer/createCustomer';
    Dio _dio = Dio();
    try {
      Response _response = await _dio.post(_url,
          data: json.encode({
            'email': customer.email!.trim().toLowerCase(),
            'password': customer.password,
            'gender': customer.gender,
            'firstname': customer.firstname,
            'lastname': customer.lastname,
            'provider': provider,
            'provider_id': customer.providerId,
          }),
          options: Options(
            headers: {
              "Permission": Enviroment.permissionKey,
            },
          ));

      if (_response.statusCode == 200) {
        final _responseData = await _response.data;

        if (_responseData[0] != null) {
          if (_responseData[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
        final customerData = _responseData["customer"];
        _me = Customer(
          id: customerData["id"],
          firstname: customerData["firstname"],
          gender: customerData["gender"],
          lastname: customerData["lastname"],
          email: customerData["email"],
          isBanned: customerData["is_banned"],
          autoPlay: customerData["autoplay"],
          isDeleted: customerData["autoplay"],
          displayRadius: customerData["display_radius"],
          notificationRadius: customerData["push_notification_radius"],
        );
        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(
            key: 'token', value: await _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: await _responseData['refreshToken']);
        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        _expiryDate = JwtDecoder.getExpirationDate(_token.toString())
            .toUtc()
            .subtract(Duration(
              minutes: _expiryDateMinusinMinutes,
            ));
        await _secureStorage.write(
            key: 'expiryDate', value: _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: 'Authentication failed!: ' + e.toString());
    }
  }

  Future<void> update({
    required Customer customer,
  }) async {
    final String _url = Enviroment.baseUrl + '/customer/updateCustomer';
    Dio _dio = Dio();
    try {
      Response? _response;

      if (customer.password == null) {
        _response = await _dio.patch(_url,
            data: {
              'email': customer.email!.trim().toLowerCase(),
              'gender': customer.gender,
              'firstname': customer.firstname,
              'lastname': customer.lastname,
              'push_notification_radius': customer.notificationRadius,
              'display_radius': customer.displayRadius,
            },
            options: Options(headers: {
              "Authorization": "Bearer $_token",
              "Permission": Enviroment.permissionKey,
            }));
      } else {
        _response = await _dio.patch(_url,
            data: {
              'email': customer.email!.trim().toLowerCase(),
              'password': customer.password,
              'gender': customer.gender,
              'firstname': customer.firstname,
              'lastname': customer.lastname,
              'push_notification_radius': customer.notificationRadius,
              'display_radius': customer.displayRadius,
            },
            options: Options(headers: {
              "Authorization": "Bearer $_token",
              "Permission": Enviroment.permissionKey,
            }));
      }

      if (_response.statusCode == 200) {
        final _responseData = await _response.data;
        if (_responseData[0] != null) {
          if (_responseData[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
        final customerData = _responseData["customer"];
        _me = Customer(
          id: customerData["id"],
          firstname: customerData["firstname"],
          gender: customerData["gender"],
          lastname: customerData["lastname"],
          email: customerData["email"],
          isBanned: customerData["is_banned"],
          autoPlay: customerData["autoplay"],
          isDeleted: customerData["autoplay"],
          displayRadius: customerData["display_radius"],
          notificationRadius: customerData["push_notification_radius"],
        );
        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(key: 'token', value: _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: _responseData['refreshToken']);
        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        _expiryDate = JwtDecoder.getExpirationDate(_token.toString())
            .toUtc()
            .subtract(Duration(
              minutes: _expiryDateMinusinMinutes,
            ));
        await _secureStorage.write(
            key: 'expiryDate', value: _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: 'Authentication failed!: ' + e.toString());
    }
  }

  Future<void> delete() async {
    final String _url = Enviroment.baseUrl + '/customer/updateCustomer';
    Dio _dio = Dio();
    try {
      Response _response = await _dio.patch(_url,
          data: json.encode({
            'is_deleted': true,
          }),
          options: Options(headers: {
            "Authorization": "Bearer $_token",
            "Permission": Enviroment.permissionKey,
          }));

      if (_response.statusCode == 200) {
        final _responseData = await _response.data;
        if (_responseData[0] != null) {
          if (_responseData[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
        final customerData = _responseData["customer"];
        _me = Customer(
          id: customerData["id"],
          firstname: customerData["firstname"],
          gender: customerData["gender"],
          lastname: customerData["lastname"],
          email: customerData["email"],
          isBanned: customerData["is_banned"],
          autoPlay: customerData["autoplay"],
          isDeleted: customerData["autoplay"],
          displayRadius: customerData["display_radius"],
          notificationRadius: customerData["push_notification_radius"],
        );
        await logout();
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: 'Authentication failed!: ' + e.toString());
    }
  }

  Future<void> updateAcceptingTerms({
    required bool isTermAccepted,
  }) async {
    final String _url = Enviroment.baseUrl + '/customer/updateCustomer';
    Dio _dio = Dio();
    try {
      Response _response = await _dio.patch(_url,
          data: json.encode({
            'terms_accepted': isTermAccepted,
          }),
          options: Options(headers: {
            "Authorization": "Bearer $_token",
            "Permission": Enviroment.permissionKey,
          }));

      if (_response.statusCode == 200) {
        final _responseData = await _response.data;
        if (_responseData[0] != null) {
          if (_responseData[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }
        final customerData = _responseData["customer"];
        _me = Customer(
          id: customerData["id"],
          firstname: customerData["firstname"],
          gender: customerData["gender"],
          lastname: customerData["lastname"],
          email: customerData["email"],
          isBanned: customerData["is_banned"],
          autoPlay: customerData["autoplay"],
          isDeleted: customerData["autoplay"],
          displayRadius: customerData["display_radius"],
          notificationRadius: customerData["push_notification_radius"],
        );
        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(key: 'token', value: _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: _responseData['refreshToken']);
        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        _expiryDate = JwtDecoder.getExpirationDate(_token.toString())
            .toUtc()
            .subtract(Duration(
              minutes: _expiryDateMinusinMinutes,
            ));
        await _secureStorage.write(
            key: 'expiryDate', value: _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: 'Authentication failed!: ' + e.toString());
    }
  }

  Future<Customer?> signIn({
    required String email,
    required String password,
    String provider = 'Local',
  }) async {
    final String _url = Enviroment.baseUrl + '/customer/signInCustomer';
    Dio _dio = Dio();
    try {
      Response _response = await _dio.post(_url,
          data: json.encode({
            'email': email.trim().toLowerCase(),
            'password': password,
            'provider': provider,
          }),
          options: Options(headers: {
            "Permission": Enviroment.permissionKey,
          }));

      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            throw HttpException(message: "${_response.data[0]["message"]}");
          }
        }

        final _responseData = await _response.data;
        final customerData = _responseData["customer"];
        _me = Customer(
          id: customerData["id"],
          firstname: customerData["firstname"],
          gender: customerData["gender"],
          lastname: customerData["lastname"],
          email: customerData["email"],
          isBanned: customerData["is_banned"],
          autoPlay: customerData["autoplay"],
          isDeleted: customerData["autoplay"],
          displayRadius: customerData["display_radius"],
          notificationRadius: customerData["push_notification_radius"],
        );
        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(key: 'token', value: _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: _responseData['refreshToken']);

        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        print(token);
        _expiryDate = JwtDecoder.getExpirationDate(_token.toString())
            .toUtc()
            .subtract(Duration(
              minutes: _expiryDateMinusinMinutes,
            ));

        await _secureStorage.write(
            key: 'expiryDate', value: _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();
        return _me;
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      print(e);
      throw HttpException(message: 'Login failed!: ' + e.toString());
    }
  }

  Future<bool> resetPassword({
    required String email,
  }) async {
    final String _url = Enviroment.baseUrl + '/customer/resetPassword';
    Dio _dio = Dio();
    try {
      Response _response = await _dio.post(_url,
          data: json.encode({
            'email': email.trim().toLowerCase(),
          }),
          options: Options(headers: {
            "Permission": Enviroment.permissionKey,
          }));
      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            return false;
          }
        }
      }
      return true;
    } catch (e) {
      throw HttpException(message: 'Reset Password Failed');
    }
  }

  Future<bool> findEmail({
    required String email,
  }) async {
    final String _url = Enviroment.baseUrl + '/customer/email';
    Dio _dio = Dio();
    try {
      var _response = await _dio.post(_url,
          data: json.encode({
            'email': email.trim().toLowerCase(),
          }),
          options: Options(headers: {
            "Permission": Enviroment.permissionKey,
          }));

      if (_response.statusCode == 200) {
        if (_response.data != null) {
          if (_response.data[0] != null) {
            return true;
          }
          return false;
        }
      }
      return true;
    } catch (e) {
      throw HttpException(message: 'Not found Email');
    }
  }

  Future<void> tokenService() async {
    final String _url = Enviroment.baseUrlWithoutApi + '/refresh';
    Dio _dio = Dio();

    secure.FlutterSecureStorage _storage = secure.FlutterSecureStorage();
    String? tkn = await _storage.read(key: "token");
    String? rfrshTkn = await _storage.read(key: "refreshToken");

    try {
      Response _response = await _dio.get(_url,
          options: Options(
            headers: {
              "Authorization": "Bearer $tkn",
              "Refresh": "Bearer $rfrshTkn",
              "Permission": Enviroment.permissionKey,
            },
          ));

      if (_response.statusCode == 200) {
        if (_response.data[0] != null) {
          if (_response.data[0]["statusCode"] != null) {
            await logout();
          }
        }

        final _responseData = await _response.data;

        secure.FlutterSecureStorage _secureStorage =
            secure.FlutterSecureStorage();

        await _secureStorage.deleteAll();

        await _secureStorage.write(
            key: 'token', value: await _responseData['token']);
        await _secureStorage.write(
            key: 'refreshToken', value: await _responseData['refreshToken']);
        _token = await _responseData['token'];
        _refreshToken = await _responseData['refreshToken'];
        _expiryDate = JwtDecoder.getExpirationDate(_token.toString())
            .toUtc()
            .subtract(Duration(
              minutes: _expiryDateMinusinMinutes,
            ));
        await _secureStorage.write(
            key: 'expiryDate', value: _expiryDate!.toIso8601String());
        _autoLogout();
        notifyListeners();
      } else {
        throw HttpException(message: _response.statusMessage!);
      }
    } catch (e) {
      throw HttpException(message: 'fetch tokens failed!: ' + e.toString());
    }
  }

  Future<bool> tryAutoLogin() async {
    secure.FlutterSecureStorage _secureStorage = secure.FlutterSecureStorage();
    String? _token = await _secureStorage.read(key: "token");

    if (_token == null || _token == "") {
      return false;
    }
    String? _expiryDateString = await _secureStorage.read(key: 'expiryDate');
    final _expiryDate = DateTime.parse(_expiryDateString.toString()).toUtc();

    if (_expiryDate.isBefore(DateTime.now().toUtc())) {
      try {
        await tokenService();
      } catch (e) {
        await logout();
        return false;
      }
    }

    return true;
  }

  // Future<void> destroy() async {
  //    String _url =
  //       Enviroment.baseUrl+'/customer/destroyAdvertiserSelf';
  //   Dio _dio = Dio();

  //   try {
  //     Response _response = await _dio.delete(_url,
  //         options: Options(headers: {
  //           "Authorization": "Bearer $_token",
  //           "Permission": Enviroment.permissionKey,
  //         }));

  //     await logout();
  //   } catch (e) {
  //     HttpException(message: "Advertiser delete failed: " + e.toString());
  //   }
  // }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    secure.FlutterSecureStorage _secureStorage = secure.FlutterSecureStorage();
    await _secureStorage.deleteAll();
    _me = null;
    notifyListeners();
  }

  void _autoLogout() async {
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    final timeToExpiry =
        _expiryDate!.toUtc().difference(DateTime.now().toUtc()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), () async {
      try {
        await tokenService();
      } catch (e) {
        await logout();
      }
    });
  }
}
