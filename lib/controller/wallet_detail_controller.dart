import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tradget/controller/main_wallet_controller.dart';
import 'package:tradget/controller/transaction_controller.dart';

class SpecificWalletController extends GetxController {
  var balance = 0.0.obs;
  var income = 0.0.obs;
  var spending = 0.0.obs;
  var wallet = ''.obs;
  var transactions = <TransactionController>[].obs;

  void getWallet(String src) {
    WalletController wc = Get.find();
    if (src.contains('card')) {
      wallet.value = 'Card';
      balance = wc.card;
    } else if (src.contains('asset.png')) {
      wallet.value = 'Other';
      balance = wc.other;
    } else if (src.contains('tng.png')) {
      wallet.value = 'TNG';
      balance = wc.tng;
    } else if (src.contains('grab.png')) {
      wallet.value = 'Grab';
      balance = wc.grab;
    } else if (src.contains('boost.png')) {
      wallet.value = 'Boost';
      balance = wc.boost;
    } else if (src.contains('cash.png')) {
      wallet.value = 'Cash';
      balance = wc.cash;
    }
  }

  Future<void> initHistory() async {
    double income = 0;
    double spending = 0;
    List<TransactionController> trans = [];

    CollectionReference ref = FirebaseFirestore.instance.collection(
        '${FirebaseAuth.instance.currentUser!.uid}/summary/monthly');

    await ref.get().then((value) async {
      for (var e in value.docs) {
        await ref
            .doc(e.id)
            .collection('Transaction')
            .where('wallet', isEqualTo: wallet())
            .get()
            .then((transactions) {
          for (var t in transactions.docs) {
            TransactionController tc = TransactionController();

            tc.initClass(t['wallet'], t['category'], t['type'], t['amount'],
                t['description'], t.id);
            trans.add(tc);
            if (t['type'] == 'Debit') {
              income += t['amount'];
            } else {
              spending += t['amount'];
            }
          }
        }).catchError((error, stackTrace) {
          print(error.toString());
        });
      }
    });
    this.income.value = income;
    this.spending.value = spending;
    trans.sort((a, b) {
      return b.getDateTime().compareTo(a.getDateTime());
    });
    transactions.value = trans;
  }
}
