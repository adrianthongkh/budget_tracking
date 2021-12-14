import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardController extends GetxController {
  var cardNum = ''.obs;
  //var cardNum = '4200 5410 9846 1347'.obs;
  var amount = 0.0.obs;
  var expiry = ''.obs;
  var rejectCard = false.obs;

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cardNum.value = prefs.getString('card_num') ?? '0000 0000 0000 0000';
    expiry.value = prefs.getString('expiry') ?? '00/00';
  }

  String toObscureText() {
    String s = cardNum();
    if (s.isEmpty) return '';
    if (s.length <= 14) {
      String temp = '';
      for (int i = 1; i <= s.length; i++) {
        if (i % 5 == 0) {
          temp += ' ';
        } else {
          temp += '*';
        }
      }
      return temp;
    } else {
      s = s.replaceRange(0, 4, '****');
      s = s.replaceRange(5, 9, '****');
      s = s.replaceRange(10, 14, '****');
    }
    return s;
  }

  Widget getCardImage() {
    String src;
    if (cardNum.isEmpty) {
      return const SizedBox.shrink();
    } else {
      if (cardNum.value[0] == '5') {
        src = '../assets/images/mastercard.png';
      } else {
        src = '../assets/images/visa.png';
      }
    }

    return Image.asset(src, width: 50, height: 50, fit: BoxFit.contain);
  }

  String getFormatted(double? value) {
    if (value == 0) {
      return 'RM';
    }
    return 'RM' + NumberFormat().format(value);
  }

  Future<void> addToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!rejectCard()) {
      prefs.setString('card_num', cardNum());
      prefs.setString('expiry', expiry());
      prefs.setBool('rejectCard', false);
    } else {
      prefs.setBool('rejectCard', true);
    }
  }
}
