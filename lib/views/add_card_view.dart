import 'package:tradget/controller/card_controller.dart';
import 'package:tradget/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';

class AddCardView extends StatelessWidget {
  const AddCardView({Key? key, required this.formKey}) : super(key: key);
  final GlobalKey<FormState> formKey;
  @override
  Widget build(BuildContext context) {
    CardController cc = Get.put(CardController());
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(children: [
            Container(
                width: MediaQuery.of(context).size.width * 0.92,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 6,
                      color: Color(0x4B1A1F24),
                      offset: Offset(0, 2),
                    )
                  ],
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00968A), Color(0xFFF2A384)],
                    stops: [0, 1],
                    begin: AlignmentDirectional(0.94, -1),
                    end: AlignmentDirectional(-0.94, 1),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildCard()),
            Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.92,
                  child: Obx(() => buildTextFormField(
                      enabled: !cc.rejectCard(),
                      initialValue: cc.cardNum(),
                      label: 'Card Number',
                      onChanged: (value) {
                        cc.cardNum.value = value;
                      },
                      formatter: CreditCardNumberInputFormatter()))),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 1,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.44,
                      child: Obx(() => buildTextFormField(
                          enabled: !cc.rejectCard(),
                          initialValue: cc.expiry(),
                          label: 'Expiry',
                          onChanged: (value) {
                            cc.expiry.value = value;
                          },
                          formatter: CreditCardExpirationDateFormatter())),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.44,
                      child: buildTextFormField(
                          initialValue:
                              cc.getFormatted(cc.amount()).substring(2),
                          label: 'Amount',
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              cc.amount.value = double.parse(value);
                            }
                          },
                          formatter: FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'))),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.92,
                  child: Theme(
                    data: ThemeData(
                      primarySwatch: Colors.blue,
                      unselectedWidgetColor: Colors.white,
                    ),
                    child: Obx(() => CheckboxListTile(
                          onChanged: (value) {
                            cc.rejectCard.value = value ?? false;
                          },
                          value: cc.rejectCard(),
                          title: Text(
                              'Proceed without entering card information.',
                              style: BTTextTheme.bodyText2),
                          controlAffinity: ListTileControlAffinity.leading,
                        )),
                  )),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildCard() {
    CardController cc = Get.find();
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
          child: Obx(() => cc.getCardImage()),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('Balance',
                  style: BTTextTheme.bodyText1.apply(color: Colors.white)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Obx(() => Text(cc.getFormatted(cc.amount()),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 28,
                      letterSpacing: 1.0)))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 20, 16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(cc.toObscureText(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto Mono',
                      fontSize: 22,
                      letterSpacing: 1.0))),
              Obx(() => Text(cc.expiry(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto Mono',
                      fontSize: 22,
                      letterSpacing: 1.0)))
            ],
          ),
        )
      ],
    );
  }

  Widget buildTextFormField(
      {required String label,
      required ValueSetter<String> onChanged,
      required TextInputFormatter formatter,
      required String initialValue,
      bool? enabled}) {
    return TextFormField(
      enabled: enabled ?? true,
      validator: (value) {
        if (enabled ?? true) {
          if (label == 'Card Number' && value!.length != 19) {
            return 'Invalid Card Number Format';
          }
          if (value == null || value.isEmpty) {
            return 'Please enter your ' + label + '.';
          }
        }
        return null;
      },
      maxLength: (label == 'Card Number') ? 19 : null,
      keyboardType: (label == 'Amount')
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [formatter],
      onChanged: onChanged,
      initialValue: initialValue,
      style: BTTextTheme.headline2.apply(color: BTColor.successGreen),
      decoration: InputDecoration(
          filled: true,
          fillColor: (enabled ?? true) ? null : BTColor.darkBackground,
          prefixStyle: (label == 'Amount')
              ? BTTextTheme.headline2.apply(color: BTColor.successGreen)
              : null,
          prefixText: (label == 'Amount') ? 'RM' : null,
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          label: Text(label),
          labelStyle: TextStyle(color: BTColor.normal),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: BTColor.normal))),
    );
  }
}
