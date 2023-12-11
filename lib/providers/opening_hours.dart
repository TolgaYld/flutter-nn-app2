import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nownow_customer/models/enviroment.dart';
import '../models/http_exception.dart';
import '../providers/opening_hour.dart';

class OpeningHours with ChangeNotifier {
  List<OpeningHour> _openingHours = [];

  final String? authToken;

  OpeningHours(this.authToken, this._openingHours);

  List<OpeningHour> get openingHours {
    return [..._openingHours];
  }

  List<OpeningHour> findByAddressId(String addressId) {
    return _openingHours
        .where((opnghrs) => opnghrs.addressId == addressId)
        .toList();
  }

  Future<void> fetchOpeningHours(String addressId) async {
    final String _url = Enviroment.baseUrl + '/openingHour/my';
    FlutterSecureStorage _secure = FlutterSecureStorage();
    String? _tkn = await _secure.read(key: "token");
    Dio _dio = Dio();
    try {
      Response _responseOpeningHours = await _dio.get(_url,
          options: Options(headers: {
            "Authorization": "Bearer $_tkn",
            "Permission": Enviroment.permissionKey,
          }));

      if (_responseOpeningHours.statusCode == 200) {
        final List _responseData = await _responseOpeningHours.data;
        if (_responseData.isNotEmpty) {
          if (_responseOpeningHours.data[0]["statusCode"] != null) {
            throw HttpException(
                message: _responseOpeningHours.data[0]["message"]);
          }

          final List<OpeningHour> _loadedOpeningHour = [];
          for (var openingHour in _responseData) {
            _loadedOpeningHour.add(
              OpeningHour(
                id: openingHour["id"],
                addressId: openingHour["address_id"],
                day: openingHour["day"],
                dayFrom: openingHour["day_from"],
                duration: openingHour["time_to_duration"],
                dayTo: openingHour["day_to"],
                advertiserId: openingHour["advertiser_id"],
                isDeleted: openingHour["is_deleted"],
                timeFrom: TimeOfDay(
                    hour: int.parse(openingHour["time_from"].split(":")[0]),
                    minute: int.parse(openingHour["time_from"].split(":")[1])),
              ),
            );
          }
          _openingHours = _loadedOpeningHour;
          notifyListeners();
        }
      } else {
        throw HttpException(message: _responseOpeningHours.statusMessage!);
      }
    } catch (e) {
      throw HttpException(
          message: "Can not fetch Opening Hours: " + e.toString());
    }
  }

  String? formatTimeOfDay(TimeOfDay timeOfDay,
      {bool alwaysUse24HourFormat = true}) {
    // Not using intl.DateFormat for two reasons:
    //
    // - DateFormat supports more formats than our material time picker does,
    //   and we want to be consistent across time picker format and the string
    //   formatting of the time of day.
    // - DateFormat operates on DateTime, which is sensitive to time eras and
    //   time zones, while here we want to format hour and minute within one day
    //   no matter what date the day falls on.
    final StringBuffer buffer = StringBuffer();

    // Add hour:minute.
    buffer
      ..write(
          formatHour(timeOfDay, alwaysUse24HourFormat: alwaysUse24HourFormat))
      ..write(':')
      ..write(formatMinute(timeOfDay));

    if (alwaysUse24HourFormat) {
      // There's no AM/PM indicator in 24-hour format.
      return '$buffer';
    }
    return null;
  }

  Object formatHour(TimeOfDay timeOfDay, {bool? alwaysUse24HourFormat}) {
    return timeOfDay.hour.toString().padLeft(2, '0');
  }

  Object formatMinute(TimeOfDay timeOfDay) {
    return timeOfDay.minute.toString().padLeft(2, '0');
  }
}
