import 'package:animations/animations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tradget/controller/card_controller.dart';
import 'package:tradget/controller/main_wallet_controller.dart';
import 'package:tradget/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradget/views/wallet_details_view.dart';

class WalletView extends StatefulWidget {
  const WalletView({Key? key}) : super(key: key);

  @override
  _WalletViewState createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WalletController controller = Get.put(WalletController());

    return SafeArea(
      child: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildIncomeExpenses(),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Stack(children: [
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
                Positioned.fill(
                    child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () {
                      Get.to(
                          () => const DetailedWalletView(
                              src: '../assets/images/card.png'),
                          transition: Transition.zoom);
                    },
                  ),
                ))
              ]),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Obx(() => _buildWallet(
                      '../assets/images/tng.png',
                      controller.tng.value.toStringAsFixed(2),
                      const Color(0xFF3E3CA7),
                      const Color(0xFF011c50))),
                  Obx(() => _buildWallet(
                      '../assets/images/boost.png',
                      controller.boost.value.toStringAsFixed(2),
                      const Color(0xFFA73B3D),
                      const Color(0xFFB30000))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Obx(() => _buildWallet(
                      '../assets/images/grab.png',
                      controller.grab.value.toStringAsFixed(2),
                      const Color(0xFF95d93d),
                      const Color(0xFF559104))),
                  Obx(() => _buildWallet(
                      '../assets/images/cash.png',
                      controller.cash.value.toStringAsFixed(2),
                      const Color(0xFFb6a93e),
                      const Color(0xFF747407))),
                ],
              ),
            ),
            _buildOther(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    CardController cardController = Get.put(CardController());
    WalletController walletController = Get.find();
    return FutureBuilder(
        future: cardController.init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [cardController.getCardImage()],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text('Balance',
                          style:
                              BTTextTheme.bodyText1.apply(color: Colors.white)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Obx(() => Text(
                          walletController
                              .getFormatted(walletController.card()),
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
                      Text(cardController.toObscureText(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto Mono',
                              fontSize: 22,
                              letterSpacing: 1.0)),
                      Obx(() => Text(cardController.expiry(),
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
          } else {
            return const Center(child: SpinKitHourGlass(color: Colors.white));
          }
        });
  }

  Widget _buildWallet(String src, String balance, Color color1, Color color2) {
    return OpenContainer(
      closedColor: Colors.transparent,
      openBuilder: (context, action) {
        return DetailedWalletView(src: src);
      },
      closedBuilder: (context, action) => Container(
        width: MediaQuery.of(context).size.width * 0.44,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: LinearGradient(
            colors: [color1, color2],
            stops: [0, 1],
            begin: const AlignmentDirectional(1, 0),
            end: const AlignmentDirectional(-1, 0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Image.asset(
                src,
                width: 75,
                height: 75,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: customText('RM' + balance, 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildOther() {
    WalletController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: OpenContainer(
        openBuilder: (context, action) {
          return const DetailedWalletView(src: '../assets/images/asset.png');
        },
        closedColor: Colors.transparent,
        closedBuilder: (context, action) => Container(
            width: MediaQuery.of(context).size.width * 0.92,
            height: 130,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                gradient: const LinearGradient(
                    colors: [Color(0xFFc1d647), Color(0xFF65cabc)],
                    stops: [0, 1],
                    begin: AlignmentDirectional(1, 0),
                    end: AlignmentDirectional(-1, 0))),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(children: [
                Expanded(
                    flex: 1, child: Image.asset('../assets/images/asset.png')),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Other\nAssets',
                    style: BTTextTheme.headline2.apply(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Obx(() => Center(
                      child: customText(
                          'RM' + controller.other.value.toStringAsFixed(2),
                          1.5))),
                )
              ]),
            )),
      ),
    );
  }

  Widget customText(String text, double factor) {
    return Stack(
      children: <Widget>[
        // Stroked text as border.
        Text(
          text,
          style: TextStyle(
            fontSize: 22 * factor,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.black26,
          ),
        ),
        // Solid text as fill.
        Text(
          text,
          style: TextStyle(
            fontSize: 22 * factor,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeExpenses() {
    WalletController controller = Get.find();
    controller.init();
    return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(() => _buildBudgetBox(
                'Income',
                controller.getFormattedIndicator(controller.income.value, true),
                controller.incomeDiff.value,
                true)),
            Obx(() => _buildBudgetBox(
                'Spending',
                controller.getFormattedIndicator(
                    controller.spending.value, false),
                controller.spendingDiff.value,
                false)),
          ],
        ));
  }

  Widget _buildBudgetBox(
      String title, String amount, double diff, bool income) {
    Color boxColor = (diff > 0)
        ? BTColor.darkerSuccessGreen
        : (diff == 0)
            ? Colors.grey[800]!
            : BTColor.darkerErrorRed;
    Color textColorBig = (income) ? BTColor.successGreen : BTColor.errorRed;
    Color textColorSmall = (diff > 0)
        ? BTColor.successGreen
        : (diff == 0)
            ? BTColor.normal
            : BTColor.errorRed;
    IconData icon =
        (diff > 0) ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    return Container(
        width: MediaQuery.of(context).size.width * 0.44,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: BTColor.darkBackground,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: BTTextTheme.bodyText1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(amount,
                      style: BTTextTheme.headline1.apply(color: textColorBig)),
                ),
                Container(
                    width: 100,
                    height: 28,
                    decoration: BoxDecoration(
                        color: boxColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(diff.toStringAsFixed(1) + '%',
                              style: BTTextTheme.bodyText1
                                  .apply(color: textColorSmall)),
                          Icon(icon, color: textColorSmall)
                        ]))
              ]),
        ));
  }
}
