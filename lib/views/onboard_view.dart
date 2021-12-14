import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tradget/controller/add_wallet_controller.dart';
import 'package:tradget/controller/card_controller.dart';
import 'package:tradget/controller/registration_controller.dart';
import 'package:tradget/main.dart';
import 'package:tradget/utils/show_dialog.dart';
import 'package:tradget/utils/theme.dart';
import 'package:tradget/views/add_card_view.dart';
import 'package:tradget/views/add_wallet_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradget/views/register_page.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({Key? key}) : super(key: key);

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int index = 0;
  @override
  void initState() {
    tabController = TabController(length: 6, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _cardKey = GlobalKey<FormState>();
    final _tngKey = GlobalKey<FormState>();
    final _boostKey = GlobalKey<FormState>();
    final _grabKey = GlobalKey<FormState>();
    final _otherKey = GlobalKey<FormState>();
    final _cashKey = GlobalKey<FormState>();
    AddWalletController awc = Get.put(AddWalletController());
    RegistrationController rc = Get.find();
    return WillPopScope(
      onWillPop: () async {
        if (index == 0) {
          return true;
        } else {
          tabController.animateTo(--index);
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text('Onboarding', style: BTTextTheme.headline1),
            leading: IconButton(
                icon: const Icon(Icons.logout_rounded),
                color: Colors.white,
                iconSize: 28,
                onPressed: () {
                  getConfirmationDialog(
                      message: 'Are you sure to sign out?',
                      onConfirmed: () {
                        FirebaseAuth.instance.signOut().then((value) {
                          rc.removeEmailAndPass();
                          Get.back();
                          Get.offAll(() => const LoginPage(),
                              transition: Transition.zoom);
                        });
                      });
                })),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (index == 0 && _cardKey.currentState!.validate()) {
              tabController.animateTo(++index);
            } else if (index == 1 && _tngKey.currentState!.validate()) {
              tabController.animateTo(++index);
            } else if (index == 2 && _boostKey.currentState!.validate()) {
              tabController.animateTo(++index);
            } else if (index == 3 && _grabKey.currentState!.validate()) {
              tabController.animateTo(++index);
            } else if (index == 4 && _cashKey.currentState!.validate()) {
              tabController.animateTo(++index);
            } else if (index == 5 && _otherKey.currentState!.validate()) {
              CardController cc = Get.find();
              awc.card.value = cc.amount();
              getConfirmationDialog(
                  message:
                      'Ensure the information is correct before submitting. Wallet\'s amount cannot be changed later on.',
                  onConfirmed: () async {
                    await awc.addToDatabase().then((value) async {
                      await cc.addToSharedPreferences().then((value) {
                        Fluttertoast.showToast(msg: 'Onboarded');
                        Get.back();
                        Get.to(() => const HomePage());
                      });
                    });
                  });
            }
          },
          elevation: 4.0,
          child: const Icon(Icons.arrow_right_alt_rounded),
          backgroundColor: BTColor.brighterGreen,
          foregroundColor: BTColor.darkBackground,
        ),
        body: TabBarView(controller: tabController, children: [
          AddCardView(formKey: _cardKey),
          AddWalletView(
              src: '../assets/images/tng.png',
              onChanged: (value) {
                if (value.isNotEmpty) {
                  awc.tng.value = double.parse(value);
                }
              },
              label: 'Touch\'N Go E-Wallet',
              formKey: _tngKey),
          AddWalletView(
              src: '../assets/images/boost.png',
              onChanged: (value) {
                if (value.isNotEmpty) {
                  awc.boost.value = double.parse(value);
                }
              },
              label: 'Boost Wallet',
              formKey: _boostKey),
          AddWalletView(
              src: '../assets/images/grab.png',
              onChanged: (value) {
                if (value.isNotEmpty) {
                  awc.grab.value = double.parse(value);
                }
              },
              label: 'GrabPay Wallet',
              formKey: _grabKey),
          AddWalletView(
              src: '../assets/images/cash.png',
              onChanged: (value) {
                if (value.isNotEmpty) {
                  awc.cash.value = double.parse(value);
                }
              },
              label: 'Cash',
              formKey: _cashKey),
          AddWalletView(
              src: '../assets/images/asset.png',
              onChanged: (value) {
                if (value.isNotEmpty) {
                  awc.other.value = double.parse(value);
                }
              },
              label: 'Other Assets',
              formKey: _otherKey),
        ]),
      ),
    );
  }
}
