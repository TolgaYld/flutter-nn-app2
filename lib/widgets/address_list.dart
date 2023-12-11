import 'package:flutter/material.dart';
import 'advertisement_widget.dart';
import '../providers/addresses.dart';
import 'package:provider/provider.dart';

class AddressList extends StatelessWidget {
  const AddressList({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final addresses = Provider.of<Addresses>(context, listen: true).addressIds;
    return SafeArea(
      top: false,
      bottom: true,
      child: Builder(
        builder: (context) => CustomScrollView(
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.021,
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  return ChangeNotifierProvider.value(
                    value: addresses[i],
                    child: const AdvertisementWidget(),
                  );
                },
                childCount: addresses.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
