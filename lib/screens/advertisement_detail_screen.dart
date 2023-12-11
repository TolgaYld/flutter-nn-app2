import 'dart:io';

import 'package:bordered_text/bordered_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:nownow_customer/providers/customer.dart';
import 'package:nownow_customer/providers/i_want_it_qroffer.dart';
import 'package:nownow_customer/providers/i_want_it_qroffers.dart';
import 'package:nownow_customer/providers/i_want_it_stad.dart';
import 'package:nownow_customer/providers/i_want_it_stads.dart';
import '../providers/address.dart';
import '../providers/addresses.dart';
import '../providers/qroffer.dart';
import '../providers/qroffers.dart';
import '../providers/stad.dart';
import '../providers/stads.dart';
import 'package:provider/provider.dart';

import '../widgets/network_player_widget.dart';

class AdvertisementDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    final String addressId =
        ModalRoute.of(context)!.settings.arguments as String;
    final Address address =
        Provider.of<Addresses>(context, listen: true).findById(addressId);
    final stad = Provider.of<Stads>(context, listen: true).now(addressId);
    final List<Qroffer> qroffers =
        Provider.of<Qroffers>(context, listen: true).addressId(addressId);
    final List<IWantItStad> iWantItStads =
        Provider.of<IWantItStads>(context, listen: true)
            .findByStadId(stad!.id!);
    final Customer me = Provider.of<Customer>(context, listen: true).me;
    return Scaffold(
      appBar: AppBar(
        title: Text(address.name!),
      ),
      body: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.height * 0.273,
              aspectRatio: 2 / 1.53,
              autoPlay: false,
              enableInfiniteScroll: true,
              viewportFraction: 0.8,
              enlargeStrategy: CenterPageEnlargeStrategy.height,
            ),
            items: stad != null
                ? stad.media.map((i) {
                    Widget _mediaCheck(String mediaLink) {
                      String? mime = lookupMimeType(mediaLink);
                      var fileType = mime!.split('/');
                      if (fileType.contains("video")) {
                        return NetworkPlayerWidget(url: mediaLink);
                      }
                      return Image.network(
                        mediaLink,
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
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    )
                                  : const CupertinoActivityIndicator(),
                            ),
                          );
                        },
                      );
                    }

                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(color: Colors.amber),
                          child: _mediaCheck(i),
                        );
                      },
                    );
                  }).toList()
                : address.media!.map((i) {
                    Widget _mediaCheck(String mediaLink) {
                      String? mime = lookupMimeType(mediaLink);
                      var fileType = mime!.split('/');
                      if (fileType.contains("video")) {
                        return NetworkPlayerWidget(url: mediaLink);
                      }
                      return Image.network(
                        mediaLink,
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
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    )
                                  : const CupertinoActivityIndicator(),
                            ),
                          );
                        },
                      );
                    }

                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(color: Colors.amber),
                          child: _mediaCheck(i),
                        );
                      },
                    );
                  }).toList(),
          ),
          SizedBox(
            height: _height * 0.012,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  onPressed: () async {
                    await Provider.of<IWantItStads>(context, listen: false)
                        .createAndDelete(stad.id!);
                  },
                  child: BorderedText(
                    strokeWidth: 3,
                    strokeColor: Theme.of(context).primaryColor,
                    child: Text(
                      "I Want It".toUpperCase(),
                      style: TextStyle(
                          fontSize: 40,
                          inherit: true,
                          color: iWantItStads
                                  .where(
                                      (element) => element.customerId == me.id)
                                  .isNotEmpty
                              ? Theme.of(context).primaryColor
                              : Colors.white),
                    ),
                  ),
                ),
                Text(
                  iWantItStads.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
