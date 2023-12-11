import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Enviroment {
  static String get fileName {
    if (kReleaseMode) {
      return '.env.production';
    }
    return '.env.development';
  }

  static String get baseUrl {
    return dotenv.get("BASE_URL");
  }

  static String get baseUrlWithoutApi {
    return dotenv.get("BASE_URL_WITHOUT_API");
  }

  static String get permissionKey {
    return dotenv.get("PERMISSION_KEY");
  }
}
