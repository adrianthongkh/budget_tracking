import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationController extends GetxController {
  var email = ''.obs;
  var pass = ''.obs;

  Future<String?> authLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.value, password: pass.value)
          .then((value) {
        putInSharedPreferences();
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return ('Wrong email or\nwrong password');
      } else {
        return ('Unknown Error Occurred: ${e.toString()}');
      }
    }
  }

  Future<String?> recoverPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return ('User not found\nwith that email.');
      }
      return ('Unknown Error Occured: ${e.toString()}');
    }
  }

  Future<String?> register() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email(), password: pass());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return ('Email already in use.\nTry logging in.');
      } else {
        return ('Unexpected Error Occured');
      }
    }
  }

  void putInSharedPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('email', email());
    pref.setString('pass', pass());
  }

  Future<bool> checkLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String email = pref.getString('email') ?? '';
    String pass = pref.getString('pass') ?? '';
    bool success = false;
    if (email == '') {
      success = false;
    } else {
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth
          .signInWithEmailAndPassword(email: email, password: pass)
          .then((value) => success = true);
    }
    return success;
  }

  Future<bool> checkOnBoarding() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return !pref.containsKey('card_num');
  }

  // check whether user has account (onboarded before) in firebase
  Future<bool> checkExistAccount() async {
    bool exist = false;
    await FirebaseFirestore.instance
        .collection(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        exist = false;
      } else {
        exist = true;
      }
    }).catchError((error, stackTrace) {
      exist = false;
    });
    return exist;
  }

  Future<void> removeEmailAndPass() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }

  Future<bool> checkRejectKey() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.containsKey('rejectCard');
  }
}
