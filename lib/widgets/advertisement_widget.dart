import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mime/mime.dart';
import 'package:nownow_customer/providers/qroffer.dart';
import 'package:nownow_customer/providers/stads.dart';
import '../providers/address.dart';
import '../providers/stad.dart';
import '../widgets/countdown_widget.dart';
import '../screens/advertisement_detail_screen.dart';
import '../providers/addresses.dart';
import '../providers/categorys.dart';
import '../providers/qroffers.dart';
import '../widgets/network_player_widget.dart';
import 'package:provider/provider.dart';

class AdvertisementWidget extends StatefulWidget {
  const AdvertisementWidget({Key? key}) : super(key: key);

  @override
  State<AdvertisementWidget> createState() => _AdvertisementWidgetState();
}

class _AdvertisementWidgetState extends State<AdvertisementWidget>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  bool _isStad = true;

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    EdgeInsets _padding = MediaQuery.of(context).padding;
    EdgeInsets _instets = MediaQuery.of(context).viewInsets;
    double _paddingLeft = _padding.left;
    double _paddingRight = _padding.right;
    double _paddingTop = _padding.top;
    double _paddingBottom = _padding.bottom;

    final addressObject = Provider.of<Address>(context, listen: false);
    final address = Provider.of<Addresses>(context, listen: false)
        .findById(addressObject.id!);
    final stad =
        Provider.of<Stads>(context, listen: true).activeStad(address.id!);
    final qroffers =
        Provider.of<Qroffers>(context, listen: true).now(address.id.toString());
    final categoryOfStore = Provider.of<Categorys>(context, listen: false)
        .findById(address.categoryId!);
    final String _categoryColor = categoryOfStore.color;

    if (stad == null) {
      _isStad = false;
    }

    Color color;

    switch (_categoryColor) {
      case "blue":
        color = Colors.blue;
        break;
      case "red":
        color = Colors.red;
        break;
      case "green":
        color = Colors.green;
        break;
      case "brown":
        color = Colors.brown;
        break;
      case "purple":
        color = Colors.purple;
        break;
      default:
        color = Colors.yellow;
        break;
    }

    Widget _mediaCheck() {
      if (stad != null) {
        String? mime = lookupMimeType(stad.media.first);
        var fileType = mime!.split('/');
        if (fileType.contains("video")) {
          return NetworkPlayerWidget(url: stad.media.first);
        }
      }
      return Image.network(
        address.media![0],
        width: double.infinity,
        height: MediaQuery.of(context).size.width / 4 * 3,
        fit: BoxFit.cover,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: _height * 0.04,
          width: _width * 0.54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1.2,
                blurRadius: 3.33,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashFactory: NoSplash.splashFactory,
                ),
                onPressed: () {
                  if (!_isStad && stad != null) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.ease,
                    );
                    setState(() {
                      _isStad = !_isStad;
                    });
                  }
                },
                child: Text(
                  "STAD",
                  style: TextStyle(
                    fontWeight: _isStad && stad != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: stad == null
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(
                height: _height * 0.021,
                child: const VerticalDivider(),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashFactory: NoSplash.splashFactory,
                ),
                onPressed: () {
                  if (_isStad && qroffers.isNotEmpty) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.ease,
                    );
                    setState(() {
                      _isStad = !_isStad;
                    });
                  }
                },
                child: Text(
                  "QROFFER",
                  style: TextStyle(
                    fontWeight: !_isStad && qroffers.isNotEmpty
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: qroffers.isEmpty
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: _height * 0.5665,
            minHeight: _height * 0.5665,
          ),
          child: Container(
            width: _width,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.6),
                  spreadRadius: 1,
                  blurRadius: 15,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: PageView(
              physics: const ClampingScrollPhysics(),
              children: [
                if (stad != null)
                  stadItem(
                    context: context,
                    address: address,
                    stad: stad,
                  ),
                if (qroffers.isNotEmpty)
                  qrofferItem(
                    context: context,
                    qroffer: qroffers.first,
                    address: address,
                  ),
              ],
              controller: _pageController,
              onPageChanged: (currentPage) {
                if (currentPage == 0) {
                  setState(() {
                    _isStad = true;
                  });
                } else {
                  setState(() {
                    _isStad = false;
                  });
                }
              },
            ),
          ),
        ),
        SizedBox(
          height: _height * 0.0333,
        ),
      ],
    );
  }

  Widget stadItem({
    required BuildContext context,
    required Address address,
    required Stad stad,
  }) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    EdgeInsets _padding = MediaQuery.of(context).padding;
    double _paddingTop = _padding.top;

    Widget _mediaCheck() {
      if (stad != null) {
        String? mime = lookupMimeType(stad.media.first);
        var fileType = mime!.split('/');
        if (fileType.contains("video")) {
          return NetworkPlayerWidget(url: stad.media.first);
        }
      }
      return Image.network(
        stad.media[0],
        width: double.infinity,
        height: MediaQuery.of(context).size.width / 4 * 3,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: _height * 0.346,
            child: Center(
              child: Platform.isAndroid
                  ? CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    )
                  : const CupertinoActivityIndicator(),
            ),
          );
        },
      );
    }

    return SizedBox(
      height: _height * 0.49101,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 1,
        margin: EdgeInsets.only(
          left: _width * 0.01,
          right: _width * 0.01,
        ),
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                settings: RouteSettings(
                  arguments: address.id,
                ),
                builder: (context) => AdvertisementDetailScreen(),
              ),
            );
          }, //selectAdvertisement(context),
          child: Column(
            children: <Widget>[
              // Stack(
              // children: <Widget>[
              ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: _mediaCheck()),
              Container(
                width: double.infinity,
                height: _height * 0.04,
                color: Colors.white,
                child: Text(
                  address.name!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: _width * 0.9,
                  height: _height * 0.002,
                  color: Colors.black12,
                ),
              ),
              SizedBox(
                height: _height * 0.012,
              ),
              SizedBox(
                height: _height * 0.09,
                child: Center(
                  child: Text(
                    stad.shortDescription,
                    // stad != null
                    //     ? stad.shortDescription
                    //     : address.qrofferShortDescription!,
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: 21,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: _paddingTop * 0.3,
                  right: _width * 0.03,
                  left: _width * 0.03,
                ),
                child: Container(
                  color: Colors.black12,
                  width: double.infinity,
                  height: _height * 0.002,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: _height * 0.002),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    color: Colors.purple,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: _height * 0.015, top: _height * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.store,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: _width * 0.015,
                            ),
                            Text(
                              stad.distance.toInt().toString() + " m",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.schedule,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: _width * 0.01,
                            ),

                            CountdownWidget(
                              startTime: DateTime.now().toUtc(),
                              endTime: stad.end!.toUtc(),
                            )

                            // advertisement.remainingTime,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget qrofferItem({
    required BuildContext context,
    required Address address,
    required Qroffer qroffer,
  }) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    EdgeInsets _padding = MediaQuery.of(context).padding;
    double _paddingTop = _padding.top;

    Widget _mediaCheck() {
      String? mime = lookupMimeType(address.media!.first);
      var fileType = mime!.split('/');
      if (fileType.contains("video")) {
        return NetworkPlayerWidget(url: address.media!.first);
      }
      return Image.network(
        address.media!.first,
        width: double.infinity,
        height: MediaQuery.of(context).size.width / 4 * 3,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: _height * 0.346,
            child: Center(
              child: Platform.isAndroid
                  ? CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    )
                  : const CupertinoActivityIndicator(),
            ),
          );
        },
      );
    }

    return SizedBox(
      height: _height * 0.49101,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 1,
        margin: EdgeInsets.only(
          left: _width * 0.01,
          right: _width * 0.01,
        ),
        child: InkWell(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                settings: RouteSettings(
                  arguments: address.id,
                ),
                builder: (context) => AdvertisementDetailScreen(),
              ),
            );
          }, //selectAdvertisement(context),
          child: Column(
            children: <Widget>[
              // Stack(
              // children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.network(
                  address.media!.first,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: _height * 0.346,
                      child: Center(
                        child: Platform.isAndroid
                            ? CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              )
                            : const CupertinoActivityIndicator(),
                      ),
                    );
                  },
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width / 4 * 3,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                width: double.infinity,
                height: _height * 0.04,
                color: Colors.white,
                child: Text(
                  address.name!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: _width * 0.9,
                  height: _height * 0.002,
                  color: Colors.black12,
                ),
              ),
              SizedBox(
                height: _height * 0.012,
              ),
              SizedBox(
                height: _height * 0.09,
                child: Center(
                  child: Text(
                    qroffer.shortDescription,
                    // stad != null
                    //     ? stad.shortDescription
                    //     : address.qrofferShortDescription!,
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                      fontSize: 21,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: _paddingTop * 0.3,
                  right: _width * 0.03,
                  left: _width * 0.03,
                ),
                child: Container(
                  color: Colors.black12,
                  width: double.infinity,
                  height: _height * 0.002,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: _height * 0.002),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    color: Colors.purple,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: _height * 0.015, top: _height * 0.01),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.store,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: _width * 0.015,
                            ),
                            Text(
                              qroffer.distance.toInt().toString() + " m",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.schedule,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: _width * 0.01,
                            ),

                            CountdownWidget(
                              startTime: DateTime.now().toUtc(),
                              endTime: qroffer.end!.toUtc(),
                            )

                            // advertisement.remainingTime,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
