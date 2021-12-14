import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddWalletController extends GetxController {
  var card = 0.0.obs;
  var tng = 0.0.obs;
  var boost = 0.0.obs;
  var grab = 0.0.obs;
  var cash = 0.0.obs;
  var other = 0.0.obs;

  Future<void> addToDatabase() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    FirebaseAuth user = FirebaseAuth.instance;
    await db
        .collection(user.currentUser!.uid)
        .doc('wallets')
        .set(toJson())
        .catchError((error, stackTrace) {
      print(error.toString());
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'card': card(),
      'tng': tng(),
      'boost': boost(),
      'grab': grab(),
      'cash': cash(),
      'other': other()
    };
  }

  // Testing
  @override
  String toString() {
    return '${card()}, ${tng()}, ${boost()}, ${grab()}, ${cash()}, ${other()}';
  }
}
