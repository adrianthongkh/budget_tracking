import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradget/controller/transaction_controller.dart';
import 'package:tradget/utils/theme.dart';

class HistoryController extends GetxController {
  var historyList = <TransactionController>[].obs;

  Widget buildListTile({required TransactionController tc}) {
    return Ink(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: BTColor.darkBackground,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Image.asset(
                getImageSrc(tc.wallet()),
                width: 50,
                height: 50,
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    EnumToString.convertToString(tc.category()),
                    style: BTTextTheme.headline2,
                  ),
                  Text(tc.description(), style: BTTextTheme.subtitle2)
                ],
              ),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  getText(tc.amount(), tc.type()),
                  Text(
                    tc.date(),
                    style: BTTextTheme.subtitle2,
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget getText(double amount, Type type) {
    Color textColor =
        (type == Type.Debit) ? BTColor.brighterGreen : BTColor.brighterRed;
    String s =
        ((type == Type.Debit) ? '+' : '-') + 'RM' + amount.toStringAsFixed(2);
    return Text(s, style: BTTextTheme.subtitle1.apply(color: textColor));
  }

  String getImageSrc(Wallet type) {
    String s = '../assets/images/';
    if (type == Wallet.Card) {
      return s + 'card.png';
    } else if (type == Wallet.TNG) {
      return s + 'tng.png';
    } else if (type == Wallet.Grab) {
      return s + 'grab.png';
    } else if (type == Wallet.Boost) {
      return s + 'boost.png';
    } else if (type == Wallet.Cash) {
      return s + 'cash.png';
    }
    return s + 'asset.png';
  }

  Future<void> getHistory() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference collection = db.collection(
        '${FirebaseAuth.instance.currentUser!.uid}/summary/monthly');
    await collection.get().then((value) async {
      for (var month in value.docs) {
        await collection
            .doc(month.id)
            .collection('Transaction')
            .get()
            .then((value) {
          for (var t in value.docs) {
            TransactionController tc = TransactionController();
            tc.initClass(t['wallet'], t['category'], t['type'], t['amount'],
                t['description'], t.id);
            historyList.add(tc);
          }
        });
      }
      historyList.sort((a, b) {
        return b.getDateTime().compareTo(a.getDateTime());
      });
    });
  }
}
