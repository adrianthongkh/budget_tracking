import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tradget/main.dart';
import 'package:tradget/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> getConfirmationDialog(
    {required String message, required VoidCallback onConfirmed}) async {
  await Get.dialog(Dialog(
      backgroundColor: BTColor.darkBackground,
      child: SizedBox(
        width: 200,
        height: 150,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: 2, color: BTColor.background))),
                    child: Center(
                      child: Text(message,
                          textAlign: TextAlign.center,
                          softWrap: true,
                          style: BTTextTheme.bodyText2),
                    )),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(
                                  width: 2, color: BTColor.background))),
                      child: InkWell(
                        onTap: () => Get.back(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Text('Cancel',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    )),
                Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: onConfirmed,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text('Confirm',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)),
                      ),
                    ))
              ])
            ]),
      )));
}

void showProgressDialog(
    {FlipCardController? fcc,
    bool? proceedLogin,
    required String loadingText,
    required String completedText,
    required Future<String?> future}) {
  Get.dialog(Dialog(
    elevation: 8.0,
    backgroundColor: BTColor.darkBackground,
    child: FutureBuilder<String?>(
      future: future,
      builder: (context, snapshot) {
        Widget indicator;
        String text = '';
        // after finished future && null returned --> no error
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data == null) {
          indicator = Icon(Icons.check_circle_outline_rounded,
              size: 64, color: BTColor.brighterGreen);
          text = snapshot.data ?? completedText;
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
            if (fcc != null) {
              fcc.toggleCard();
            }
            if (proceedLogin ?? false) {
              Get.offAll(() => const RedirectView(),
                  transition: Transition.fade);
            }
          });
        } else if (snapshot.hasData) {
          indicator =
              Icon(Icons.close_rounded, size: 64, color: BTColor.brighterRed);
          text = snapshot.data!;
          Future.delayed(const Duration(milliseconds: 1500), () {
            Get.back();
            if (fcc != null) {
              fcc.toggleCard();
            }
          });
        } else {
          indicator = const SpinKitHourGlass(color: Colors.white);
          text = loadingText;
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 32.0), child: indicator),
            Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 32.0, horizontal: 12.0),
                child: Text(
                  text,
                  style: BTTextTheme.bodyText2,
                  textAlign: TextAlign.center,
                )),
          ],
        );
      },
    ),
  ));
}
