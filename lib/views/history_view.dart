import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:tradget/controller/history_controller.dart';
import 'package:tradget/utils/show_dialog.dart';
import 'package:tradget/utils/theme.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HistoryController hc = Get.put(HistoryController());
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: SafeArea(
        child: Center(
            child: FutureBuilder<void>(
          future: hc.getHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SpinKitHourGlass(color: Colors.white);
            } else {
              if (hc.historyList.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'No transaction history was recorded.\nYou can create one at the home page.',
                    textAlign: TextAlign.center,
                    style: BTTextTheme.bodyText2.apply(fontSizeFactor: 1.2),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                itemCount: hc.historyList.length,
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
                },
              );
            }
          },
        )),
      ),
    );
  }
}
