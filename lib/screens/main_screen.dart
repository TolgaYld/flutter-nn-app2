import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nownow_customer/screens/category_screen.dart';
import 'package:nownow_customer/screens/home_feed_screen.dart';
import 'package:nownow_customer/screens/settings_screen.dart';
import 'package:nownow_customer/screens/wallet_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(items: const [
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.home,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.bookOpen,
          ),
          label: 'Categorys',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.qrcode,
          ),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            FontAwesomeIcons.cog,
          ),
          label: 'Settings',
        ),
      ]),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(
              builder: (context) => HomeFeed(),
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => CategoryScreen(),
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => WalletScreen(),
            );
          case 3:
            return CupertinoTabView(
              builder: (context) => SettingsScreen(),
            );
          default:
            return CupertinoTabView(
              builder: (context) => HomeFeed(),
            );
        }
      },
    );
  }
}
