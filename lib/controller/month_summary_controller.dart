import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradget/model/monthly_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';

class MonthlyController extends GetxController {
  Future<List<MonthSummary>> getAllMonth() async {
    var months = <MonthSummary>[];
    CollectionReference monthsRef = FirebaseFirestore.instance.collection(
        '${FirebaseAuth.instance.currentUser!.uid}/summary/monthly');
    await monthsRef
        .where('completed', isEqualTo: true)
        .get()
        .then((value) async {
      for (var month in value.docs) {
        var ref = monthsRef.doc(month.id).collection('Transaction');
        await ref.get().then((value) {
          double income = 0;
          double spending = 0;
          for (var t in value.docs) {
            if (!t['description'].toString().contains('Fund Transfer')) {
              if (t['type'] == 'Debit') {
                income += t['amount'];
              } else {
                spending += t['amount'];
              }
            }
          }
          months.add(MonthSummary(month.id, income, spending));
        });
      }
    });
    return sort(months);
  }

  static Future<void> checkNewMonth() async {
    String lastMonth = Jiffy().subtract(months: 1).format('MMMM yyyy');

    var ref = FirebaseFirestore.instance.collection(
        '${FirebaseAuth.instance.currentUser!.uid}/summary/monthly');
    await ref.doc(lastMonth).get().then((value) async {
      if (value.exists && !value['completed']) {
        ref.doc(lastMonth).update({'completed': true});
      }
      var pref = await SharedPreferences.getInstance();
      pref.remove('lastIncome');
      pref.remove('lastSpending');
    });
  }

  List<MonthSummary> sort(List<MonthSummary> months) {
    months.sort((a, b) {
      return b.getDateTime().compareTo(a.getDateTime());
    });
    return months;
  }
}
