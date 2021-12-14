import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:tradget/controller/history_controller.dart';
import 'package:tradget/controller/wallet_detail_controller.dart';
import 'package:tradget/utils/show_dialog.dart';
import 'package:tradget/utils/theme.dart';

class DetailedWalletView extends StatelessWidget {
  const DetailedWalletView({Key? key, required this.src}) : super(key: key);
  final String src;
  @override
  Widget build(BuildContext context) {
    SpecificWalletController swc = Get.put(SpecificWalletController());
    swc.getWallet(src);
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet Details')),
      body: SafeArea(
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: FutureBuilder<void>(
                future: swc.initHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SpinKitHourGlass(color: Colors.white);
                  } else {
                    return DetailsView(src: src);
                  }
                },
              ))),
    );
  }
}

class DetailsView extends StatelessWidget {
  const DetailsView({Key? key, required this.src}) : super(key: key);
  final String src;
  @override
  Widget build(BuildContext context) {
    SpecificWalletController swc = Get.find();
    HistoryController hc = HistoryController();
    hc.historyList = swc.transactions;

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
                child: Image.asset(src, width: 100, height: 100),
              ),
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  height: 100,
                  width: MediaQuery.of(context).size.width * 0.44,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.transparent),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('Balance', style: BTTextTheme.headline1),
                        Obx(() => Text('RM${swc.balance().toStringAsFixed(2)}',
                            style: BTTextTheme.headline2
                                .apply(color: BTColor.normal)))
                      ]))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    height: 130,
                    width: MediaQuery.of(context).size.width * 0.40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: BTColor.darkBackground),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          customText('Debit', 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Obx(() => Text(
                                'RM${swc.income().toStringAsFixed(2)}',
                                style: BTTextTheme.headline2.apply(
                                    color: BTColor.brighterGreen,
                                    fontSizeFactor: 1.2))),
                          )
                        ])),
                Container(
                    height: 130,
                    width: MediaQuery.of(context).size.width * 0.40,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: BTColor.darkBackground),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          customText('Credit', 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Obx(() => Text(
                                '-RM${swc.spending().toStringAsFixed(2)}',
                                style: BTTextTheme.headline2.apply(
                                    color: BTColor.brighterRed,
                                    fontSizeFactor: 1.2))),
                          )
                        ])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                const Icon(Icons.history_rounded,
                    size: 30, color: Colors.white),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'Transaction History',
                    style: BTTextTheme.bodyText2.apply(fontSizeFactor: 1.2),
                  ),
                )
              ],
            ),
          ),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: swc.transactions().length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Dismissible(
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          var tc = hc.historyList[index];
                          await tc.deleteTransaction().then((value) =>
                              Fluttertoast.showToast(
                                  msg: 'Transaction deleted'));
                        },
                        confirmDismiss: (direction) async {
                          var flag = false;
                          await getConfirmationDialog(
                              message:
                                  'Are you sure to delete this transaction?',
                              onConfirmed: () {
                                flag = true;
                                Get.back();
                              });
                          return flag;
                        },
                        key: ValueKey(index),
                        background: Container(
                          padding: const EdgeInsets.only(right: 24.0),
                          color: BTColor.brighterRed,
                          child: const Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.delete_rounded)),
                        ),
                        child: hc.buildListTile(tc: hc.historyList[index])),
                  ),
                );
              })
        ],
      ),
    );
  }
}

Widget customText(String text, double factor) {
  return Stack(
    children: <Widget>[
      // Stroked text as border.
      Text(
        text,
        style: TextStyle(
          fontSize: 22 * factor,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6
            ..color = Colors.black26,
        ),
      ),
      // Solid text as fill.
      Text(
        text,
        style: TextStyle(
          fontSize: 22 * factor,
          color: Colors.white,
        ),
      ),
    ],
  );
}
