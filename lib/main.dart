import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nownow_customer/providers/address.dart';
import 'package:nownow_customer/providers/favorite_categorys.dart';
import 'package:nownow_customer/providers/i_want_it_qroffers.dart';
import 'package:nownow_customer/providers/i_want_it_stads.dart';
import './models/enviroment.dart';
import './providers/addresses.dart';
import './providers/categorys.dart';
import './providers/customer.dart';
import './providers/opening_hours.dart';
import './providers/qroffers.dart';
import './providers/stads.dart';
import './providers/subcategorys.dart';
import './providers/subsubcategorys.dart';
import './providers/wallets.dart';
import './screens/main_screen.dart';
import './screens/splash.dart';
import 'package:provider/provider.dart';
import './screens/auth_screen.dart';

Map<int, Color> nowNowGreen = {
  50: const Color.fromRGBO(112, 184, 73, .1),
  100: const Color.fromRGBO(112, 184, 73, .2),
  200: const Color.fromRGBO(112, 184, 73, .3),
  300: const Color.fromRGBO(112, 184, 73, .4),
  400: const Color.fromRGBO(112, 184, 73, .5),
  500: const Color.fromRGBO(112, 184, 73, .6),
  600: const Color.fromRGBO(112, 184, 73, .7),
  700: const Color.fromRGBO(112, 184, 73, .8),
  800: const Color.fromRGBO(112, 184, 73, .9),
  900: const Color.fromRGBO(112, 184, 73, 1.0),
};

Map<int, Color> nowNowYellow = {
  50: const Color.fromRGBO(245, 231, 62, .1),
  100: const Color.fromRGBO(245, 231, 62, .2),
  200: const Color.fromRGBO(245, 231, 62, .3),
  300: const Color.fromRGBO(245, 231, 62, .4),
  400: const Color.fromRGBO(245, 231, 62, .5),
  500: const Color.fromRGBO(245, 231, 62, .6),
  600: const Color.fromRGBO(245, 231, 62, .7),
  700: const Color.fromRGBO(245, 231, 62, .8),
  800: const Color.fromRGBO(245, 231, 62, .9),
  900: const Color.fromRGBO(245, 231, 62, 1.0),
};

Map<int, Color> nowNowOrange = {
  50: const Color.fromRGBO(253, 166, 41, .1),
  100: const Color.fromRGBO(253, 166, 41, .2),
  200: const Color.fromRGBO(253, 166, 41, .3),
  300: const Color.fromRGBO(253, 166, 41, .4),
  400: const Color.fromRGBO(253, 166, 41, .5),
  500: const Color.fromRGBO(253, 166, 41, .6),
  600: const Color.fromRGBO(253, 166, 41, .7),
  700: const Color.fromRGBO(253, 166, 41, .8),
  800: const Color.fromRGBO(253, 166, 41, .9),
  900: const Color.fromRGBO(253, 166, 41, 1.0),
};

MaterialColor nowNowGreenColor = MaterialColor(0xFF70B849, nowNowGreen);
MaterialColor nowNowOrangeColor = MaterialColor(0xFFFDA629, nowNowOrange);
MaterialColor nowNowYellowColor = MaterialColor(0xFFf5e73e, nowNowYellow);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: Enviroment.fileName);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Customer(),
        ),
        ChangeNotifierProxyProvider<Customer, Addresses>(
          create: (ctx) => Addresses(null, []),
          update: (ctx, customer, previousAddresses) => Addresses(
            customer.token,
            previousAddresses!.addresses,
          ),
        ),
        ChangeNotifierProxyProvider<Customer, Stads>(
          create: (ctx) => Stads(null, []),
          update: (ctx, customer, previousStads) => Stads(
            customer.token,
            previousStads!.stads,
          ),
        ),
        ChangeNotifierProxyProvider<Customer, Qroffers>(
          create: (ctx) => Qroffers(null, []),
          update: (ctx, customer, previousQroffers) => Qroffers(
            customer.token,
            previousQroffers!.qroffers,
          ),
        ),
        ChangeNotifierProxyProvider<Customer, Wallets>(
          create: (ctx) => Wallets(null, []),
          update: (ctx, customer, previousWallets) => Wallets(
            customer.token,
            previousWallets!.wallets,
          ),
        ),
        ChangeNotifierProxyProvider<Customer, OpeningHours>(
          create: (ctx) => OpeningHours(null, []),
          update: (ctx, advertiser, previousOpeningHour) => OpeningHours(
            advertiser.token,
            previousOpeningHour!.openingHours,
          ),
        ),
        ChangeNotifierProxyProvider<Customer, FavoriteCategorys>(
          create: (ctx) => FavoriteCategorys(null, []),
          update: (ctx, customer, previousOpeningHour) => FavoriteCategorys(
            customer.token,
            previousOpeningHour!.categorys,
          ),
        ),
        ChangeNotifierProvider.value(
          value: Categorys(),
        ),
        ChangeNotifierProvider.value(
          value: Subcategorys(),
        ),
        ChangeNotifierProvider.value(
          value: Subsubcategorys(),
        ),
        ChangeNotifierProvider.value(
          value: IWantItStads(),
        ),
        ChangeNotifierProvider.value(
          value: IWantItQroffers(),
        ),
      ],
      child: Consumer<Customer>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            primaryColor: nowNowGreenColor,
            accentColor: nowNowOrangeColor,
            colorScheme: ColorScheme(
              primary: nowNowGreenColor,
              secondary: nowNowOrangeColor,
              surface: nowNowGreenColor,
              background: Colors.white,
              error: Colors.red,
              onPrimary: Colors.white,
              onSecondary: nowNowOrangeColor,
              onSurface: nowNowGreenColor,
              onBackground: Colors.white,
              onError: Colors.red,
              brightness: Brightness.light,
            ),
          ),
          home: auth.isAuth
              ? const MainScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? Splash()
                          : authResultSnapshot.data == true
                              ? const MainScreen()
                              : const AuthScreen(),
                ),
        ),
      ),
    );
  }
}
