import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradget/model/spending_report.dart';

class ReportController {
  Map<String, Temp> spendings = {};
  double total = 0;

  Future<List<SpendingReport>> getSpendingByCategory(String month) async {
    Map<String, Temp> spendingsTemp = {};
    double totalAmount = 0;
    var cRef = FirebaseFirestore.instance.collection(
        '${FirebaseAuth.instance.currentUser!.uid}/summary/monthly/$month/Transaction');
    await cRef.where('type', isEqualTo: 'Credit').get().then((value) {
      for (var t in value.docs) {
        String desc = t['description'];
        if (!desc.contains('Fund Transfer')) {
          String category = t['category'];
          double amount = t['amount'];
          totalAmount += amount;
          if (spendingsTemp.containsKey(category)) {
            spendingsTemp[category]!.amount =
                spendingsTemp[category]!.amount + amount;
            spendingsTemp[category]!.count++;
          } else {
            spendingsTemp.addAll({category: Temp(amount)});
          }
        }
      }
    });
    spendings = spendingsTemp;
    total = totalAmount;
    if (spendings.isNotEmpty) {
      var sortedMap = sortMapByAmount(false);
      // Subtract top 3 amount, totalAmount = Others
      if (sortedMap.length >= 5) {
        totalAmount = totalAmount -
            sortedMap[0].amount -
            sortedMap[1].amount -
            sortedMap[2].amount;
        return [
          SpendingReport(
              sortedMap[0].category, sortedMap[0].amount, sortedMap[0].count),
          SpendingReport(
              sortedMap[1].category, sortedMap[1].amount, sortedMap[1].count),
          SpendingReport(
              sortedMap[2].category, sortedMap[2].amount, sortedMap[2].count),
          SpendingReport('Others', totalAmount, null)
        ];
      } else {
        List<SpendingReport> list = [];
        for (int i = 0; i < sortedMap.length; i++) {
          list.add(SpendingReport(
              sortedMap[i].category, sortedMap[i].amount, sortedMap[i].count));
        }
        return list;
      }
    } else {
      return [];
    }
  }

  List<SpendingReport> sortMapByAmount(bool asc) {
    List<SpendingReport> list = [];
    var sortedMap = spendings.entries.toList()
      ..sort((e1, e2) {
        var diff = e2.value.amount.compareTo(e1.value.amount);
        return (asc) ? -diff : diff;
      });

    for (int i = 0; i < sortedMap.length; i++) {
      list.add(SpendingReport(sortedMap[i].key, sortedMap[i].value.amount,
          sortedMap[i].value.count));
    }
    return list;
  }

  List<SpendingReport> sortMapByCount(bool asc) {
    var sortedMap = spendings.entries.toList()
      ..sort((e1, e2) {
        var diff = e2.value.count.compareTo(e1.value.count);
        return (asc) ? -diff : diff;
      });
    var list = <SpendingReport>[];
    for (int i = 0; i < sortedMap.length; i++) {
      list.add(SpendingReport(sortedMap[i].key, sortedMap[i].value.amount,
          sortedMap[i].value.count));
    }
    return list;
  }
}

class Temp {
  double amount;
  int count = 1;

  Temp(this.amount);
}
