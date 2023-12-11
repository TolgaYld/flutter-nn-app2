import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nownow_customer/models/enviroment.dart';
import '../models/http_exception.dart';
import '../providers/address.dart';

class Addresses with ChangeNotifier {
  List<Address> _addresses = [];

  List<Address> _addressIds = [];

  final String? _authToken;

  Addresses(this._authToken, this._addresses);

  List<Address> get addresses {
    return [..._addresses];
  }

  List<Address> get addressIds {
    return [..._addressIds];
  }

  List<Address> get findAllActiveAddresses {
    return _addresses.where((address) => address.isActive == true).toList();
  }

  List<Address> get notDeleted {
    return _addresses.where((address) => address.isDeleted == false).toList();
  }

  Address findById(String id) {
    return _addresses.firstWhere((address) => address.id == id);
  }

  Future<void> fetchAddressIds(
      {required double latitude, required double longitude}) async {
    String _myAddressesUrl =
        Enviroment.baseUrl + '/address/fetchAddressesForCustomer';
    Dio _dio = Dio();
    try {
      FlutterSecureStorage _secure = FlutterSecureStorage();
      String? _tkn = await _secure.read(key: "token");
      Response _responseAddress = await _dio.patch(
        _myAddressesUrl,
        data: {
          "latitude": latitude,
          "longitude": longitude,
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

          final List<Address> _loadedAddresses = [];

          for (var address in _responseData) {
            _loadedAddresses.add(
              Address(
                id: address["id"],
                latitude: address["latitude"],
                longitude: address["longitude"],
                street: address["street"],
                city: address["city"],
                country: address["country"],
                timezone: address["timezone"],
                countryCode: address["country_code"],
                media: address["media"],
                categoryId: address["category_id"],
                subcategoryId: address["subcategory_id"],
                subsubcategoryId: address["subsubcategory_id"],
                advertiserId: address["advertiser_id"],
                companyName: address["company_name"],
                facebook: address["facebook"],
                vat: address["vat"],
                iban: address["iban"],
                flatrateDateQroffer: address["family_flatrate_qroffer"] != null
                    ? DateTime.parse(address["family_flatrate_qroffer"])
                    : null,
                flatrateDateStad: address["family_flatrate_stad"] != null
                    ? DateTime.parse(address["family_flatrate_stad"])
                    : null,
                floor: address["floor"],
                homepage: address["homepage"],
                instagram: address["instagram"],
                youtube: address["youtube"],
                googleMyBusiness: address["google_my_business"],
                tiktok: address["tiktok"],
                pinterest: address["pinterest"],
                isActive: address["is_active"],
                name: address["name"],
                official: address["official"],
                phone: address["phone"],
                postcode: address["postcode"],
                invoiceAddressId: address["invoice_address_id"],
                createdAt: address["created_at"] != null
                    ? DateTime.parse(address["created_at"])
                    : null,
                activeQroffer: address["active_qroffer"],
                activeStad: address["active_stad"],
                qrofferShortDescription: address["qroffer_short_description"],
                activeQrofferValue: address["active_qroffer_value"],
                isDeleted: address["is_deleted"],
              ),
            );
          }

          _addressIds = _loadedAddresses;

          notifyListeners();
        }
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Addresses: " + e.toString());
    }
  }

  Future<void> fetchAddresses() async {
    String _myAddressesUrl = Enviroment.baseUrl + '/address/activeStadQroffer';
    Dio _dio = Dio();
    try {
      FlutterSecureStorage _secure = FlutterSecureStorage();
      String? _tkn = await _secure.read(key: "token");
      Response _responseAddress = await _dio.get(
        _myAddressesUrl,
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

          final List<Address> _loadedAddresses = [];

          for (var address in _responseData) {
            _loadedAddresses.add(
              Address(
                id: address["id"],
                latitude: address["latitude"],
                longitude: address["longitude"],
                street: address["street"],
                city: address["city"],
                country: address["country"],
                timezone: address["timezone"],
                countryCode: address["country_code"],
                media: address["media"],
                categoryId: address["category_id"],
                subcategoryId: address["subcategory_id"],
                subsubcategoryId: address["subsubcategory_id"],
                advertiserId: address["advertiser_id"],
                companyName: address["company_name"],
                facebook: address["facebook"],
                vat: address["vat"],
                iban: address["iban"],
                flatrateDateQroffer: address["family_flatrate_qroffer"] != null
                    ? DateTime.parse(address["family_flatrate_qroffer"])
                    : null,
                flatrateDateStad: address["family_flatrate_stad"] != null
                    ? DateTime.parse(address["family_flatrate_stad"])
                    : null,
                floor: address["floor"],
                homepage: address["homepage"],
                instagram: address["instagram"],
                youtube: address["youtube"],
                googleMyBusiness: address["google_my_business"],
                tiktok: address["tiktok"],
                pinterest: address["pinterest"],
                isActive: address["is_active"],
                name: address["name"],
                official: address["official"],
                phone: address["phone"],
                postcode: address["postcode"],
                invoiceAddressId: address["invoice_address_id"],
                createdAt: address["created_at"] != null
                    ? DateTime.parse(address["created_at"])
                    : null,
                activeQroffer: address["active_qroffer"],
                activeStad: address["active_stad"],
                qrofferShortDescription: address["qroffer_short_description"],
                activeQrofferValue: address["active_qroffer_value"],
                isDeleted: address["is_deleted"],
              ),
            );
          }

          _addresses = _loadedAddresses;

          notifyListeners();
        }
      }
    } catch (e) {
      throw HttpException(message: "Can not fetch Addresses: " + e.toString());
    }
  }
}
