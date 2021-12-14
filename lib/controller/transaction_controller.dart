// ignore_for_file: constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradget/controller/main_wallet_controller.dart';
import 'package:tradget/controller/month_summary_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TransactionController extends GetxController {
  var wallet = Wallet.Card.obs;
  var category = Categories.Meal.obs;
  var type = Type.Credit.obs;
  var amount = 0.0.obs;
  var description = ''.obs;
  var date = ''.obs;
  var id = ''.obs;

  void initClass(String w, String category, String type, double amount,
      String description, String id) {
    wallet.value = EnumToString.fromString(Wallet.values, w)!;
    this.category.value = EnumToString.fromString(Categories.values, category)!;
    this.type.value = EnumToString.fromString(Type.values, type)!;
    this.amount.value = amount;
    this.description.value = description;
    date.value = DateFormat('dd MMM, HH:mm')
        .format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(id));
    this.id.value = id;
  }

  @override
  String toString() {
    return '${wallet()}, ${category()}, ${type()}, ${amount()}, ${description()}, ${date()}';
  }

  Future<void> addTransaction(bool isTransfer) async {
    String monthYear = DateFormat('MMMM y').format(DateTime.now());
    CollectionReference refMonth = FirebaseFirestore.instance.collection(
        '${FirebaseAuth.instance.currentUser!.uid}/summary/monthly');
    Map<String, dynamic> data = toJson();

    await refMonth.doc(monthYear).get().then((value) async {
      if (!value.exists) {
        await refMonth
            .doc(monthYear)
            .set({'completed': false}).then((value) async {
          await MonthlyController.checkNewMonth();
        });
      }
    }).then((value) async {
      await refMonth
          .doc(monthYear)
          .collection('Transaction')
          .doc(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()))
          .set(data);
    });
  }

  Map<String, dynamic> toJson() => {
        'wallet': EnumToString.convertToString(wallet()),
        'category': EnumToString.convertToString(category()),
        'type': EnumToString.convertToString(type()),
        'amount': amount(),
        'description': description()
      };

  DateTime getDateTime() {
    DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss');
    return format.parse(id());
  }

  Future<void> deleteTransaction() async {
    String monthYear = DateFormat('MMMM y')
        .format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(id()));
    DocumentReference ref = FirebaseFirestore.instance
        .collection(
            '${FirebaseAuth.instance.currentUser!.uid}/summary/monthly/$monthYear/Transaction')
        .doc(id());
    await ref.delete().then((value) async {
      WalletController wc = Get.find();
      type.value = (type() == Type.Debit) ? Type.Credit : Type.Debit;
      await wc.updateWallet(this, false, true);
    });
  }
}

enum Type { Debit, Credit }
enum Wallet { Card, TNG, Boost, Grab, Cash, Other }
enum Categories {
  Meal,
  Grocery,
  Essentials,
  Utilities,
  Borrow,
  Activities,
  Rent,
  Salary,
  Investment,
  Transfer,
  Others
}
