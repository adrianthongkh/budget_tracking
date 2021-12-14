import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tradget/controller/registration_controller.dart';
import 'package:tradget/firebase_options.dart';
import 'package:tradget/utils/show_dialog.dart';
import 'package:tradget/utils/theme.dart';
import 'package:tradget/views/add_transaction.dart';
import 'package:tradget/views/history_view.dart';
import 'package:tradget/views/missing_info_view.dart';
import 'package:tradget/views/onboard_view.dart';
import 'package:tradget/views/register_page.dart';
import 'package:tradget/views/summary_view.dart';
import 'package:tradget/views/wallets_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    RegistrationController rc = Get.put(RegistrationController());
    return OKToast(
      child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: GoogleFonts.lexendDeca().fontFamily,
            appBarTheme: AppBarTheme(
                backgroundColor: BTColor.background,
                elevation: 0,
                centerTitle: true,
                titleTextStyle:
                    BTTextTheme.headline1.apply(letterSpacingFactor: 1.5)),
            backgroundColor: BTColor.background,
            scaffoldBackgroundColor: BTColor.background,
            primaryColor: const Color(0xFFa5e6ff),
          ),
          // Redirect between login / redirect
          home: FutureBuilder<bool>(
            future: rc.checkLogin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(
                        child: SpinKitHourGlass(
                  color: Colors.white,
                )));
              } else if (snapshot.data!) {
                return const RedirectView();
              } else {
                return const LoginPage();
              }
            },
          )),
    );
  }
}

/// Redirect between onboard / homepage
class RedirectView extends StatelessWidget {
  const RedirectView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegistrationController rc = Get.find();
    return FutureBuilder<bool>(
        future: rc.checkOnBoarding(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: SpinKitHourGlass(
              color: Colors.white,
            ));
          } else if (snapshot.data!) {
            return FutureBuilder<bool>(
                future: rc.checkExistAccount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                        body: SpinKitHourGlass(
                      color: Colors.white,
                    ));
                  } else if (snapshot.data!) {
                    return FutureBuilder<bool>(
                        future: rc.checkRejectKey(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Scaffold(
                                body: SpinKitHourGlass(
                              color: Colors.white,
                            ));
                          } else if (snapshot.data!) {
                            return const HomePage();
                          } else {
                            return const MissingInfoView();
                          }
                        });
                  } else {
                    return const OnBoardingView();
                  }
                });
          } else {
            return const HomePage();
          }
        });
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> pageList = [const WalletView(), SummaryView()];
  int index = 0;
  @override
  Widget build(BuildContext context) {
    RegistrationController rc = Get.find();
    return Scaffold(
        appBar: AppBar(
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
            },
          ),
          title: Text('Tradget', style: BTTextTheme.headline1),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.history_rounded),
              color: Colors.white,
              iconSize: 28,
              onPressed: () {
                Get.to(() => const HistoryView(), transition: Transition.zoom);
              },
            ),
          ],
        ),
        body: PageTransitionSwitcher(
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return FadeThroughTransition(
              fillColor: BTColor.background,
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
          child: pageList[index],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: OpenContainer(
          closedShape: const CircleBorder(side: BorderSide.none),
          closedColor: Colors.transparent,
          openBuilder: (context, action) => const AddTransaction(),
          closedBuilder: (context, action) => Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: BTColor.successGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.post_add_rounded,
                color: BTColor.background, size: 28),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            elevation: 2.0,
            color: BTColor.darkBackground,
            shape: const CircularNotchedRectangle(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                        borderRadius: BorderRadius.circular(48.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.credit_card_rounded,
                                size: 28, color: BTColor.successGreen),
                            Text('Wallets',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: BTColor.successGreen))
                          ],
                        ),
                        onTap: () => setState(() {
                              index = 0;
                            })),
                    InkWell(
                        borderRadius: BorderRadius.circular(48.0),
                        radius: 70,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.insert_chart_outlined_rounded,
                                size: 28, color: BTColor.successGreen),
                            Text('Summary',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: BTColor.successGreen))
                          ],
                        ),
                        onTap: () => setState(() {
                              index = 1;
                            })),
                  ]),
            )));
  }
}
