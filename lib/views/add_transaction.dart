import 'package:tradget/controller/transaction_controller.dart';
import 'package:tradget/controller/main_wallet_controller.dart';
import 'package:tradget/utils/show_dialog.dart';
import 'package:tradget/utils/theme.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:toggle_switch/toggle_switch.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({Key? key}) : super(key: key);

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: Text('Add Transaction', style: BTTextTheme.headline1),
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FutureBuilder<Widget>(
          future: buildFAB(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.data!;
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        body: FutureBuilder<Widget>(
          future: buildBody(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.data!;
            } else {
              return const Center(child: SpinKitDualRing(color: Colors.white));
            }
          },
        ));
  }

  Future<FloatingActionButton> buildFAB() async {
    final TransactionController transactionController =
        Get.put(TransactionController());
    final TempController temp = Get.put(TempController());
    temp.toWallet.value = Wallet.TNG;
    temp.selected.value = false;
    transactionController.type.value = Type.Credit;
    return Future.delayed(
        const Duration(milliseconds: 1500),
        () => FloatingActionButton(
            backgroundColor: BTColor.brighterGreen,
            child: const Icon(Icons.send_rounded),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (temp.selected() == true &&
                    temp.toWallet.value == transactionController.wallet.value) {
                  Fluttertoast.showToast(
                      msg:
                          'Invalid Transaction: Wallets being transferred are the same.',
                      gravity: ToastGravity.BOTTOM,
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2);
                } else {
                  getConfirmationDialog(
                      message: 'Confirm to add transaction?',
                      onConfirmed: () {
                        WalletController wc = Get.find();
                        if (temp.selected() == true) {
                          TransactionController c = TransactionController();
                          transactionController.category.value =
                              Categories.Transfer;
                          transactionController.description.value =
                              'Fund Transfer to ' +
                                  EnumToString.convertToString(
                                      temp.toWallet.value);
                          transactionController.type.value = Type.Credit;
                          c.description.value = 'Fund Transfer from ' +
                              EnumToString.convertToString(c.wallet.value);
                          c.wallet.value = temp.toWallet.value;
                          c.amount = transactionController.amount;
                          c.category = transactionController.category;
                          c.type.value = Type.Debit;
                          Future.delayed(const Duration(seconds: 1), () {
                            c.addTransaction(true).then(
                                (value) => wc.updateWallet(c, true, false));
                          });
                        }
                        transactionController
                            .addTransaction(temp.selected())
                            .then((value) {
                          wc
                              .updateWallet(
                                  transactionController, temp.selected(), false)
                              .then((value) {
                            Get.back();
                            Fluttertoast.showToast(
                                msg: 'Transaction Added',
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIosWeb: 2);
                            Get.back();
                          });
                        }).catchError((error, stackTrace) {
                          print(error.toString());
                        });
                      });
                }
              }
            }));
  }

  Future<Widget> buildBody(BuildContext context) async {
    return Future.delayed(const Duration(milliseconds: 1500), () {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 44, 0, 8),
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Form(key: _formKey, child: const TransactionForm()),
          ),
        ),
      );
    });
  }
}

class TransactionForm extends StatefulWidget {
  const TransactionForm({Key? key}) : super(key: key);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  TransactionController transactionController = Get.find();
  TempController temp = Get.find();
  String src = '../assets/images/';
  bool transfer = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Theme(
          data: ThemeData(
            primarySwatch: Colors.blue,
            unselectedWidgetColor: Colors.white,
          ),
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text('Fund Transfer among Wallets',
                style: BTTextTheme.headline2),
            value: transfer,
            onChanged: (value) {
              setState(() {
                transfer = value!;
                temp.selected.value = value;
              });
            },
          ),
        ),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 100,
            child: TextFormField(
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  transactionController.amount.value =
                      double.parse(double.parse(value).toStringAsFixed(2));
                }
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
              obscureText: false,
              decoration: InputDecoration(
                  hintText: 'Amount',
                  hintStyle: BTTextTheme.headline1.apply(
                      fontWeightDelta: 2, color: BTColor.darkerSuccessGreen),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: BTColor.normal,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: BTColor.normal,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(24),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text('RM',
                        style:
                            BTTextTheme.headline1.apply(color: Colors.white)),
                  )),
              style: BTTextTheme.headline1,
              textAlign: TextAlign.center,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter an amount';
                }
                return null;
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 24, 12, 0),
          child: buildDropDownMenu(
              choices: EnumToString.toList(Wallet.values),
              src: [
                src + 'card.png',
                src + 'tng.png',
                src + 'boost.png',
                src + 'grab.png',
                src + 'cash.png',
                src + 'asset.png',
              ],
              label: (transfer) ? 'From Wallet' : 'Wallet',
              labelHint: 'Affected Wallet',
              onChanged: (value) {
                transactionController.wallet.value =
                    EnumToString.fromString(Wallet.values, value!)!;
              }),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 24, 12, 0),
          child: (transfer)
              ? buildDropDownMenu(
                  transfer: true,
                  choices: EnumToString.toList(Wallet.values),
                  src: [
                    src + 'card.png',
                    src + 'tng.png',
                    src + 'boost.png',
                    src + 'grab.png',
                    src + 'cash.png',
                    src + 'asset.png',
                  ],
                  label: 'To Wallet',
                  labelHint: 'Affected Wallet',
                  onChanged: (value) {
                    temp.toWallet.value =
                        EnumToString.fromString(Wallet.values, value!)!;
                  })
              : buildDropDownMenu(
                  choices: EnumToString.toList(Categories.values),
                  label: 'Category',
                  labelHint: 'Source of Transaction',
                  onChanged: (value) {
                    transactionController.category.value =
                        EnumToString.fromString(Categories.values, value!)!;
                  }),
        ),
        (transfer)
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 24, 12, 0),
                child: TextFormField(
                  onChanged: (value) {
                    transactionController.description.value = value;
                  },
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  style: BTTextTheme.headline3,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 20),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: BTColor.normal)),
                    labelText: 'Description',
                    labelStyle: BTTextTheme.headline2,
                    border: const OutlineInputBorder(),
                    hintText: 'Describe the transaction',
                    hintStyle: BTTextTheme.headline3.apply(
                        fontSizeFactor: 0.9,
                        fontWeightDelta: -2,
                        color: const Color(0xAA4971ff)),
                  ),
                )),
        (transfer)
            ? const SizedBox.shrink()
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: TypeToggleSwitch())
      ],
    );
  }
}

class TypeToggleSwitch extends StatefulWidget {
  const TypeToggleSwitch({Key? key}) : super(key: key);

  @override
  _TypeToggleSwitchState createState() => _TypeToggleSwitchState();
}

class _TypeToggleSwitchState extends State<TypeToggleSwitch> {
  TransactionController transactionController = Get.find();
  int index = 1;
  @override
  Widget build(BuildContext context) {
    return ToggleSwitch(
      borderColor: [
        Colors.green[800]!,
        Colors.green,
        Colors.red,
        Colors.red[800]!
      ],
      borderWidth: 3,
      cornerRadius: 40.0,
      minWidth: 150.0,
      minHeight: 70.0,
      totalSwitches: 2,
      activeBgColors: [
        [BTColor.successGreen, BTColor.brighterGreen],
        [BTColor.brighterRed, BTColor.errorRed]
      ],
      initialLabelIndex: index,
      activeFgColor: BTColor.darkBackground,
      inactiveBgColor: BTColor.background,
      inactiveFgColor: BTColor.darkBackground,
      labels: ['Income', 'Expenses'],
      customTextStyles: [
        BTTextTheme.headline2.apply(
            fontWeightDelta: 1,
            color:
                (index == 0) ? BTColor.darkBackground : BTColor.brighterGreen),
        BTTextTheme.headline2.apply(
            fontWeightDelta: 1,
            color: (index == 1) ? BTColor.darkBackground : BTColor.brighterRed)
      ],
      onToggle: (idx) {
        setState(() {
          index = idx;
          if (idx == 0) {
            transactionController.type.value = Type.Debit;
          } else {
            transactionController.type.value = Type.Credit;
          }
        });
      },
    );
  }
}

Widget buildDropDownMenu(
    {required List<String> choices,
    List<String>? src,
    required String label,
    required String labelHint,
    required ValueSetter<String?> onChanged,
    bool? transfer}) {
  List<DropdownMenuItem<String>> item = [];
  for (int i = 0; i < choices.length; i++) {
    if (src != null) {
      item.add(DropdownMenuItem<String>(
          value: choices[i],
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 24, 8),
                child: Image.asset(src[i],
                    fit: BoxFit.contain, height: 50, width: 50),
              ),
              Text(choices[i], style: BTTextTheme.headline3)
            ],
          )));
    } else {
      item.add(DropdownMenuItem<String>(
          value: choices[i],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(choices[i], style: BTTextTheme.headline3),
          )));
    }
  }

  //return Future.delayed(Duration(seconds: 1), () {
  return DropdownButtonFormField<String>(
    value: (transfer ?? false) ? choices[1] : choices[0],
    validator: (value) {
      if (value == null) {
        return 'Please select a ' + label + '.';
      }
      return null;
    },
    iconSize: 70.0,
    dropdownColor: BTColor.darkBackground,
    hint: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(labelHint,
          style: BTTextTheme.headline3.apply(
              fontSizeFactor: 0.9,
              fontWeightDelta: -2,
              color: const Color(0xAA4971ff))),
    ),
    decoration: InputDecoration(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: BTColor.normal)),
        labelText: label,
        labelStyle: BTTextTheme.headline2,
        border: const OutlineInputBorder()),
    items: item,
    onChanged: onChanged,
  );
}

class TempController extends GetxController {
  var toWallet = Wallet.TNG.obs;
  var selected = false.obs;
}
