import 'package:firebase_auth/firebase_auth.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradget/controller/month_summary_controller.dart';
import 'package:tradget/controller/transaction_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalletController extends GetxController {
  var card = 0.0.obs;
  var tng = 0.0.obs;
  var boost = 0.0.obs;
  var grab = 0.0.obs;
  var cash = 0.0.obs;
  var other = 0.0.obs;
  var income = 0.0.obs;
  var spending = 0.0.obs;
  var incomeDiff = 4.5.obs;
  var spendingDiff = (-4.5).obs;

  WalletController() {
    DocumentReference doc = FirebaseFirestore.instance
        .doc('${FirebaseAuth.instance.currentUser!.uid}/wallets');
    doc.get().then((value) {
      card.value = value['card'];
      tng.value = value['tng'];
      boost.value = value['boost'];
      grab.value = value['grab'];
      cash.value = value['cash'];
      other.value = value['other'];
    });
  }

  Future<void> init() async {
    CollectionReference ref = FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.uid);
    String monthYear = DateFormat('MMMM y').format(DateTime.now());

    await ref.doc('summary').get().then((value) async {
      if (!value.exists) {
        await ref.doc('summary').set({'dummy': 'dummy'}).then((value) {
          ref
              .doc('summary')
              .collection('monthly')
              .doc(monthYear)
              .set({'completed': false});
          income.value = 0.0;
          spending.value = 0.0;
        });
      } else {
        double income = 0;
        double spending = 0;
        await ref
            .doc('summary')
            .collection('monthly')
            .doc(monthYear)
            .collection('Transaction')
            .get()
            .then((value) async {
          for (var t in value.docs) {
            if (!t['description'].toString().contains('Fund Transfer')) {
              if (t['type'] == 'Debit') {
                income += t['amount'];
              } else {
                spending += t['amount'];
              }
            }
          }
          await MonthlyController.checkNewMonth();
          this.income.value = income;
          this.spending.value = spending;
          await initPercentageDiff();
        });
      }
    });
  }

  Future<void> initPercentageDiff() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove('lastIncome');
    pref.remove('lastSpending');
    String lastIncome = pref.getString('lastIncome') ?? '';
    String lastSpending = pref.getString('lastSpending') ?? '';

    if (lastIncome == '' && lastSpending == '') {
      String lastMonth = Jiffy().subtract(months: 1).format('MMMM yyyy');
      var ref = FirebaseFirestore.instance.collection(
          '${FirebaseAuth.instance.currentUser!.uid}/summary/monthly');
      await ref.doc(lastMonth).get().then((value) async {
        if (!value.exists) {
          incomeDiff.value = 0.0;
          spendingDiff.value = 0.0;
        } else {
          double prevIncome = 0;
          double prevSpending = 0;
          await ref
              .doc(lastMonth)
              .collection('Transaction')
              .get()
              .then((value) async {
            for (var t in value.docs) {
              if (!t['description'].toString().contains('Fund Transfer')) {
                if (t['type'] == 'Debit') {
                  prevIncome += t['amount'];
                } else {
                  prevSpending += t['amount'];
                }
              }
            }
          });
          if (prevIncome != 0) {
            double percentage = ((income() - prevIncome) / prevIncome) * 100;
            incomeDiff.value = percentage;
            pref.setString('lastIncome', income().toStringAsFixed(2));
          } else {
            incomeDiff.value = 0.0;
          }
          if (prevSpending != 0) {
            spendingDiff.value =
                -((spending() - prevSpending) / prevSpending * 100);
            pref.setString('lastSpending ', spending().toStringAsFixed(2));
          } else {
            spendingDiff.value = 0.0;
          }
        }
      });
    } else {
      incomeDiff.value =
          (income - double.parse(lastIncome)) / double.parse(lastIncome) * 100;
      spendingDiff.value = (spending - double.parse(lastSpending)) /
          double.parse(lastSpending) *
          -100;
    }
  }

  Future<void> updateWallet(
      TransactionController tc, bool isTransfer, bool rollback) async {
    bool isIncome = tc.type() == Type.Debit;
    double amount = (isIncome) ? tc.amount() : -tc.amount();
    amount = double.parse(amount.toStringAsFixed(2));
    String wallet = EnumToString.convertToString(tc.wallet()).toLowerCase();
    DocumentReference doc = FirebaseFirestore.instance
        .doc('${FirebaseAuth.instance.currentUser!.uid}/wallets');
    if (isTransfer) {
      await doc.update({wallet: getAmount(tc.wallet()) + amount});
    } else {
      await doc.update({wallet: getAmount(tc.wallet()) + amount});
    }
    updateField(wallet, amount, isTransfer, rollback);
  }

  void updateField(String w, double a, bool isTransfer, bool rollback) {
    switch (w) {
      case 'card':
        card.value += a;
        break;
      case 'tng':
        tng.value += a;
        break;
      case 'boost':
        boost.value += a;
        break;
      case 'grab':
        grab.value += a;
        break;
      case 'cash':
        cash.value += a;
        break;
      default:
        other.value += a;
    }
    if (!isTransfer) {
      if (a > 0) {
        if (rollback) {
          spending.value -= a;
        } else {
          income.value += a;
        }
      } else {
        if (rollback) {
          income.value += a;
        } else {
          spending.value -= a;
        }
      }
    }
  }

  double getAmount(Wallet wallet) {
    if (wallet == Wallet.Card) {
      return card();
    } else if (wallet == Wallet.TNG) {
      return tng();
    } else if (wallet == Wallet.Boost) {
      return boost();
    } else if (wallet == Wallet.Grab) {
      return grab();
    } else if (wallet == Wallet.Cash) {
      return cash();
    } else {
      return other();
    }
  }

  String getFormatted(double value) {
    var formatter = NumberFormat('###,###.00');
    return 'RM' + formatter.format(value);
  }

  String getFormattedIndicator(double value, bool income) {
    if (income) {
      return '+' + getFormatted(value);
    } else {
      return '-' + getFormatted(value);
    }
  }
}
