import 'package:flutter/material.dart';

class IWantItStad with ChangeNotifier {
  String id;
  String stadId;
  String customerId;

  IWantItStad(
      {required this.id, required this.customerId, required this.stadId});
}
