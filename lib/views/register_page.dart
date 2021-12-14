import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradget/controller/registration_controller.dart';
import 'package:tradget/utils/show_dialog.dart';
import 'package:tradget/utils/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isRegister = true;
  @override
  Widget build(BuildContext context) {
    FlipCardController flipController = FlipCardController();
    ViewController vc = Get.put(ViewController());
    return Scaffold(
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    '../assets/images/tradget.png',
                    width: 300,
                    height: 250,
                  ),
                  Center(
                    child: FlipCard(
                        controller: flipController,
                        flipOnTouch: false,
                        back: Container(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            decoration: BoxDecoration(
                                color: BTColor.darkBackground,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  const BoxShadow(
                                      color: Colors.white54,
                                      blurRadius: 3.0,
                                      spreadRadius: 3.0,
                                      offset: Offset(0, 0))
                                ]),
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Obx(() => vc._buildBack(flipController))),
                        direction: FlipDirection.HORIZONTAL,
                        front: LoginView(flipController: flipController)),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

class LoginView extends StatelessWidget {
  LoginView({Key? key, required this.flipController}) : super(key: key);
  final FlipCardController flipController;
  static final _loginKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    RegistrationController rc = Get.find();
    ViewController vc = Get.find();
    return Form(
      key: _loginKey,
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          decoration: BoxDecoration(
              color: BTColor.darkBackground,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                const BoxShadow(
                    color: Colors.white54,
                    blurRadius: 3.0,
                    spreadRadius: 3.0,
                    offset: Offset(0, 0))
              ]),
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const EmailTextField(),
              const PasswordTextField(),
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 0),
                  child: TextButton(
                      style: const ButtonStyle(),
                      child: const Text('Forget Password?',
                          style:
                              TextStyle(decoration: TextDecoration.underline)),
                      onPressed: () {
                        vc.label.value = 'forgot';
                        flipController.toggleCard();
                      })),
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 0),
                  child: Stack(children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                            color: BTColor.darkBlue,
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Text('LOG IN',
                            textAlign: TextAlign.center,
                            style: BTTextTheme.headline3.apply(
                                color: Colors.black,
                                fontWeightDelta: 2,
                                fontSizeFactor: 1.1))),
                    Positioned.fill(
                        child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                                borderRadius: BorderRadius.circular(12.0),
                                onTap: () {
                                  if (_loginKey.currentState!.validate()) {
                                    showProgressDialog(
                                        proceedLogin: true,
                                        loadingText: 'Logging In...',
                                        completedText:
                                            'Login Successfully.\nYou will be redirected shortly.',
                                        future: rc.authLogin());
                                  }
                                })))
                  ])),
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 0),
                  child: TextButton(
                      style: const ButtonStyle(),
                      child:
                          const Text('SIGN UP', style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        vc.label.value = 'signup';
                        flipController.toggleCard();
                      })),
            ],
          )),
    );
  }
}

class EmailTextField extends StatelessWidget {
  const EmailTextField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegistrationController rc = Get.find();
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Empty email';
          } else if (!GetUtils.isEmail(value)) {
            return 'Invalid email format';
          }
          return null;
        },
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) {
          rc.email.value = value;
        },
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
            filled: true,
            fillColor: Colors.white60,
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.email_rounded, color: Colors.white60, size: 24),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            label: Text('Email', style: BTTextTheme.subtitle2),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0))),
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({Key? key, this.confirmPass}) : super(key: key);
  final bool? confirmPass;
  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool obscure = true;
  IconData icon = Icons.visibility_off_rounded;
  @override
  Widget build(BuildContext context) {
    RegistrationController rc = Get.find();
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 0),
      child: TextFormField(
        validator: (value) {
          if (widget.confirmPass ?? false) {
            if (value != rc.pass()) {
              return 'Passwords are not the same.';
            }
          }
          if (value == null || value.isEmpty) {
            return 'Password cannot be empty.';
          } else if (value.length < 6) {
            return 'Password must be 6 characters or more.';
          }
          return null;
        },
        onChanged: (value) {
          if (!(widget.confirmPass ?? false)) {
            rc.pass.value = value;
          }
        },
        obscureText: obscure,
        decoration: InputDecoration(
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                  onTap: () {
                    setState(() {
                      obscure = !obscure;
                      icon = (obscure)
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded;
                    });
                  },
                  child: Icon(icon, color: Colors.white60, size: 24)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
            filled: true,
            fillColor: Colors.white60,
            prefixIcon: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.lock_outlined, color: Colors.white60, size: 24),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            label: Text(
                (widget.confirmPass ?? false) ? 'Re-type password' : 'Password',
                style: BTTextTheme.subtitle2),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0))),
      ),
    );
  }
}

class ViewController extends GetxController {
  var label = 'signup'.obs;
  static final _forgotKey = GlobalKey<FormState>();
  static final _signUpKey = GlobalKey<FormState>();
  Widget _buildBack(FlipCardController fcc) {
    List<Widget> children = [];
    RegistrationController rc = Get.find();
    if (label.value == 'signup') {
      children.add(const EmailTextField());
      children.add(const PasswordTextField());
      children.add(const PasswordTextField(confirmPass: true));
      children.add(_buildButton(
        onTap: () async {
          if (_signUpKey.currentState!.validate()) {
            showProgressDialog(
                fcc: fcc,
                loadingText: 'Signing Up...',
                completedText: 'Successfully Signed Up.',
                future: rc.register());
          }
        },
        text: 'Sign Up',
      ));
      children.add(_buildTextButton(text: 'Back', controller: fcc));
    } else {
      children.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: EmailTextField(),
      ));
      children.add(_buildButton(
          onTap: () {
            if (_forgotKey.currentState!.validate()) {
              showProgressDialog(
                  fcc: fcc,
                  loadingText: 'Sending Email...',
                  completedText: 'Reset Password\nEmail Sent.',
                  future: rc.recoverPassword());
            }
          },
          text: 'Send Password\nReset Email'));
      children.add(_buildTextButton(text: 'Back', controller: fcc));
    }

    return Form(
      key: (label.value == 'signup') ? _signUpKey : _forgotKey,
      child: Column(
        mainAxisAlignment: (label.value == 'signup')
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceAround,
        children: children,
      ),
    );
  }

  Widget _buildButton({required VoidCallback onTap, required String text}) {
    return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 0),
        child: Stack(children: [
          Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
              decoration: BoxDecoration(
                  color: BTColor.darkBlue,
                  borderRadius: BorderRadius.circular(12.0)),
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: BTTextTheme.headline3.apply(
                      color: Colors.black,
                      fontWeightDelta: 2,
                      fontSizeFactor: 1.1))),
          Positioned.fill(
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      borderRadius: BorderRadius.circular(12.0), onTap: onTap)))
        ]));
  }

  Widget _buildTextButton(
      {required String text, required FlipCardController controller}) {
    return Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 0),
        child: TextButton(
            style: const ButtonStyle(),
            child: Text(text,
                style: const TextStyle(decoration: TextDecoration.underline)),
            onPressed: () => controller.toggleCard()));
  }
}
