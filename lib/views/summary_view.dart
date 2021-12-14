import 'package:animations/animations.dart';
import 'package:tradget/controller/month_summary_controller.dart';
import 'package:tradget/model/monthly_report.dart';
import 'package:tradget/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:tradget/views/report_view.dart';

class SummaryView extends StatelessWidget {
  SummaryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MonthlyController controller = Get.put(MonthlyController());
    return FutureBuilder<List<MonthSummary>>(
        future: controller.getAllMonth(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return SafeArea(
                  child: Center(
                      child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    'No monthly report to be viewed.\nMonthly report will only be generated during the start of a new month.',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: BTTextTheme.bodyText2.apply(fontSizeFactor: 1.2)),
              )));
            }
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: OpenContainer(
                          closedColor: BTColor.background,
                          closedBuilder: (context, action) {
                            return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                width: MediaQuery.of(context).size.width * 0.92,
                                height: 150,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    color: BTColor.darkBackground),
                                child: snapshot.data![index].buildCard());
                          },
                          openBuilder: (context, action) {
                            return ReportView(
                                month: snapshot.data![index].month);
                          }),
                    );
                  },
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(snapshot.error.toString(),
                    style: const TextStyle(color: Colors.white)));
          } else {
            return const Center(child: SpinKitHourGlass(color: Colors.white));
          }
        });
  }
}
