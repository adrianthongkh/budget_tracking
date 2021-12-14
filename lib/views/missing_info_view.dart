import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradget/controller/card_controller.dart';
import 'package:tradget/utils/theme.dart';

import '../main.dart';

class MissingInfoView extends StatelessWidget {
  const MissingInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    CardController cc = CardController();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                '../assets/images/logo.png',
                width: 150,
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                    'We could not locate your card information.\n'
                    'Due to the fact that we do not store user\'s card information on our database, we save it locally on user\'s device.\n'
                    'You will be prompted to re-enter your card information (CVV number will not be asked).',
                    textAlign: TextAlign.center,
                    style: BTTextTheme.bodyText1.apply(fontSizeFactor: 1.2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18.0),
                  onTap: () {
                    Get.dialog(Dialog(
                      backgroundColor: BTColor.background,
                      insetPadding:
                          const EdgeInsets.symmetric(horizontal: 56.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24.0, horizontal: 12.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: BuildTextFormField(
                                  label: 'Card Number',
                                  onChanged: (s) {
                                    cc.cardNum.value = s;
                                  },
                                  formatter: CreditCardNumberInputFormatter(),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: BuildTextFormField(
                                  label: 'Expiry',
                                  onChanged: (s) {
                                    cc.expiry.value = s;
                                  },
                                  formatter:
                                      CreditCardExpirationDateFormatter(),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                    child: FloatingActionButton(
                                        backgroundColor: BTColor.brighterGreen,
                                        foregroundColor: BTColor.darkBackground,
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            await cc.addToSharedPreferences();
                                            Get.offAll(
                                                () => const RedirectView());
                                          }
                                        },
                                        child: const Icon(Icons.check_rounded,
                                            size: 30))),
                              )
                            ],
                          ),
                        ),
                      ),
                    ));
                  },
                  child: Ink(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [BTColor.darkBlue, BTColor.normal],
                            stops: [0, 1],
                            begin: const AlignmentDirectional(1, 0),
                            end: const AlignmentDirectional(-1, 0)),
                        borderRadius: BorderRadius.circular(18.0)),
                    child: const Center(
                      child: Text('I understand',
                          style: TextStyle(fontSize: 18.0)),
                    ),
                  ),
                ),
              ),
              TextButton(
                  style: const ButtonStyle(),
                  child: const Text(
                      'Proceed without entering card\'s information',
                      style: TextStyle(fontSize: 16)),
                  onPressed: () async {
                    SharedPreferences pref =
                        await SharedPreferences.getInstance();
                    pref.setBool('rejectCard', true);
                    Get.offAll(() => const RedirectView(),
                        transition: Transition.zoom);
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class BuildTextFormField extends StatelessWidget {
  const BuildTextFormField({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.formatter,
  }) : super(key: key);
  final String label;
  final ValueSetter<String> onChanged;
  final TextInputFormatter formatter;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: BTColor.successGreen),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Empty field.';
        }
        return null;
      },
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [formatter],
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: BTColor.normal)),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          label: Text(
            label,
            style: BTTextTheme.bodyText1.apply(color: BTColor.normal),
          )),
    );
  }
}
