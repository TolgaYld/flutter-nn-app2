import 'package:flutter/material.dart';

class Advertiser with ChangeNotifier {
  String? id;
  String? email;
  String? password;
  String? gender;
  String? firstname;
  String? lastname;
  DateTime? birthDate;
  String? phone;
  String? companyRegistrationNumber;
  bool? official;
  bool? isBanned;
  bool? autoPlay;
  bool? isDeleted;

  Advertiser({
    this.id,
    this.email,
    this.password,
    this.gender,
    this.firstname,
    this.lastname,
    this.birthDate,
    this.phone,
    this.official,
    this.isBanned,
    this.autoPlay,
    this.isDeleted,
  });
}
