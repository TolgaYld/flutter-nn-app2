import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nownow_customer/providers/addresses.dart';
import 'package:nownow_customer/providers/categorys.dart';
import 'package:nownow_customer/providers/customer.dart';
import 'package:nownow_customer/providers/i_want_it_qroffers.dart';
import 'package:nownow_customer/providers/i_want_it_stads.dart';
import 'package:nownow_customer/providers/opening_hours.dart';
import 'package:nownow_customer/providers/qroffers.dart';
import 'package:nownow_customer/providers/stads.dart';
import 'package:nownow_customer/providers/subcategorys.dart';
import 'package:nownow_customer/providers/subsubcategorys.dart';
import 'package:provider/provider.dart';
import '../widgets/address_list.dart';
import '../widgets/advertisement_widget.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({Key? key}) : super(key: key);

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  var _isInit = true;
  var _isLoading = false;

  Future<void> _refreshScreen(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      Provider.of<Customer>(context, listen: false).getMe().then((_) {
        Provider.of<Categorys>(context, listen: false)
            .fetchAllCategorys()
            .then((_) {
          Provider.of<Subcategorys>(context, listen: false)
              .fetchAllSubcategorys()
              .then((_) {
            Provider.of<Subsubcategorys>(context, listen: false)
                .fetchAllSubsubcategorys()
                .then((_) {
              _determinePosition().then((position) {
                Provider.of<Addresses>(context, listen: false)
                    .fetchAddressIds(
                        latitude: position.latitude,
                        longitude: position.longitude)
                    .then((_) {
                  Provider.of<Addresses>(context, listen: false)
                      .fetchAddresses()
                      .then((_) {
                    Provider.of<Stads>(context, listen: false)
                        .fetchStads()
                        .then((_) {
                      Provider.of<Qroffers>(context, listen: false)
                          .fetchQroffers()
                          .then((_) {
                        Provider.of<IWantItStads>(context, listen: false)
                            .fetchIwantItStadsAll()
                            .then((_) {
                          Provider.of<IWantItQroffers>(context, listen: false)
                              .fetchIwantItQroffersAll()
                              .then((_) {
                            setState(() {
                              _isLoading = false;
                              _isInit = false;
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.lowest,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      // FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
      // _secureStorage.deleteAll();
      setState(() {
        _isLoading = true;
      });
      Provider.of<Customer>(context, listen: false).getMe().then((_) {
        Provider.of<Categorys>(context, listen: false)
            .fetchAllCategorys()
            .then((_) {
          Provider.of<Subcategorys>(context, listen: false)
              .fetchAllSubcategorys()
              .then((_) {
            Provider.of<Subsubcategorys>(context, listen: false)
                .fetchAllSubsubcategorys()
                .then((_) {
              _determinePosition().then((position) {
                Provider.of<Addresses>(context, listen: false)
                    .fetchAddressIds(
                  latitude: position.latitude,
                  longitude: position.longitude,
                )
                    .then((_) {
                  Provider.of<Addresses>(context, listen: false)
                      .fetchAddresses()
                      .then((_) {
                    Provider.of<Stads>(context, listen: false)
                        .fetchStads()
                        .then((_) {
                      Provider.of<Qroffers>(context, listen: false)
                          .fetchQroffers()
                          .then((_) {
                        Provider.of<IWantItStads>(context, listen: false)
                            .fetchIwantItStadsAll()
                            .then((_) {
                          Provider.of<IWantItQroffers>(context, listen: false)
                              .fetchIwantItQroffersAll()
                              .then((_) {
                            setState(() {
                              _isLoading = false;
                              _isInit = false;
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverSafeArea(
                top: false,
                bottom: false,
                sliver: SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: true,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                  // collapsedHeight: MediaQuery.of(context).size.height * 0.061,
                  toolbarHeight: MediaQuery.of(context).size.height * 0.06,

                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(0),
                    child: Container(),
                  ),
                  leading: null,
                  title: const Text('My Stores',
                      style: TextStyle(color: Colors.white)),
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color.fromRGBO(107, 176, 62, 1.0),
                          Color.fromRGBO(153, 199, 58, 1.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ];
        },
        body: _isLoading
            ? Center(
                child: Platform.isAndroid
                    ? const CircularProgressIndicator()
                    : const CupertinoActivityIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshScreen(context),
                child: const AddressList(),
              ),
      ),
    );
  }
}
