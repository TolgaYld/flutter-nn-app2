import 'package:flutter/material.dart';

class IWantItQroffer with ChangeNotifier {
  String id;
  String qrofferId;
  String customerId;

  IWantItQroffer(
      {required this.id, required this.customerId, required this.qrofferId});
}
