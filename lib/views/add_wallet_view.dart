import 'package:tradget/controller/add_wallet_controller.dart';
import 'package:tradget/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AddWalletView extends StatelessWidget {
  AddWalletView(
      {Key? key,
      required this.src,
      this.label,
      required this.onChanged,
      required this.formKey})
      : super(key: key);
  final String src;
  final String? label;
  final ValueSetter<String> onChanged;
  final GlobalKey<FormState> formKey;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(src, width: 150, height: 150, fit: BoxFit.cover),
          (label != null)
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(label!, style: BTTextTheme.headline1))
              : const SizedBox.shrink(),
          Form(
            key: formKey,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount.';
                  }
                  return null;
                },
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                onChanged: onChanged,
                initialValue: getInitialValue(),
                style: BTTextTheme.headline2.apply(color: BTColor.successGreen),
                decoration: InputDecoration(
                    prefixStyle: BTTextTheme.headline2
                        .apply(color: BTColor.successGreen),
                    prefixText: 'RM',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 28.0),
                    label: const Text('Amount'),
                    labelStyle: TextStyle(color: BTColor.normal),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: BTColor.normal))),
              ),
            ),
          )
        ],
      ),
    );
  }

  String getInitialValue() {
    AddWalletController awc = Get.find();
    if (label!.contains('Touch')) {
      return (awc.tng() != 0) ? awc.tng().toStringAsFixed(2) : '';
    } else if (label!.contains('Boost')) {
      return (awc.boost() != 0) ? awc.boost().toStringAsFixed(2) : '';
    } else if (label!.contains('Grab')) {
      return (awc.grab() != 0) ? awc.grab().toStringAsFixed(2) : '';
    } else if (label!.contains('Cash')) {
      return (awc.cash() != 0) ? awc.cash().toStringAsFixed(2) : '';
    } else {
      return (awc.other() != 0) ? awc.other().toStringAsFixed(2) : '';
    }
  }
}
