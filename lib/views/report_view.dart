import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:tradget/controller/report_controller.dart';
import 'package:tradget/model/spending_report.dart';
import 'package:tradget/utils/theme.dart';

var colors = [
  const Color(0xff0293ee),
  const Color(0xfff8b250),
  const Color(0xff845bef),
  const Color(0xff13d38e)
];
var total = 0.0;

class ReportView extends StatelessWidget {
  const ReportView({Key? key, required this.month}) : super(key: key);
  final String month;
  @override
  Widget build(BuildContext context) {
    ReportController rc = ReportController();
    return Scaffold(
        appBar: AppBar(title: Text(month)),
        body: FutureBuilder<List<SpendingReport>>(
            future: rc.getSpendingByCategory(month),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SpinKitHourGlass(color: Colors.white);
              } else {
                total = rc.total;
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              color: BTColor.darkBackground,
                              borderRadius: BorderRadius.circular(16.0)),
                          height: 350,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('$month Spending Summary',
                                  style: BTTextTheme.headline2
                                      .apply(fontSizeFactor: 0.8)),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: PieChartView(
                                            spendings: snapshot.data!)),
                                    Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            buildIndicators(snapshot.data!)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            'Most Frequent Spent Category',
                            style: BTTextTheme.headline2,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        MostFrequentSpend(controller: rc),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            'List of Spendings by Category',
                            style: BTTextTheme.headline2,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: SpendingDetails(controller: rc),
                        )
                      ],
                    ),
                  ),
                );
              }
            }));
  }

  List<Widget> buildIndicators(List<SpendingReport> spendings) {
    List<Widget> children = [];

    for (int i = 0; i < spendings.length; i++) {
      children.add(Indicator(color: colors[i], text: spendings[i].category));
    }

    return children;
  }
}

class PieChartView extends StatefulWidget {
  const PieChartView({Key? key, required this.spendings}) : super(key: key);
  final List<SpendingReport> spendings;
  @override
  _PieChartViewState createState() => _PieChartViewState();
}

class _PieChartViewState extends State<PieChartView> {
  int touchedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
          pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              } else {
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              }
            });
          }),
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: showingSections(widget.spendings)),
    );
  }

  List<PieChartSectionData> showingSections(List<SpendingReport> spendings) {
    List<PieChartSectionData> sections = [];
    for (var i = 0; i < spendings.length; i++) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 130.0 : 100.0;

      sections.add(PieChartSectionData(
          color: colors[i],
          value: spendings[i].getPercentage(total),
          title: isTouched
              ? 'RM' + spendings[i].amount.toStringAsFixed(2)
              : spendings[i].getPercentage(total).toStringAsFixed(2) + '%',
          radius: radius,
          titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black)));
    }
    return sections;
  }
}

class Indicator extends StatelessWidget {
  const Indicator({Key? key, required this.color, required this.text})
      : super(key: key);
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 25,
            height: 25,
            color: color,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(text, style: BTTextTheme.bodyText1),
          )
        ],
      ),
    );
  }
}

class MostFrequentSpend extends StatelessWidget {
  MostFrequentSpend({Key? key, required this.controller}) : super(key: key);
  final ReportController controller;
  final List<List<Color>> colors = [
    [Colors.amber[800]!, Colors.amber[100]!],
    [Colors.grey[800]!, Colors.grey[100]!],
    [const Color(0xff905923), const Color(0xffdca570)],
  ];
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    List<SpendingReport> sortedSpendings = controller.sortMapByCount(false);
    int length = min(3, sortedSpendings.length);
    for (int i = 0; i < length; i++) {
      if (sortedSpendings[i].count != null) {
        children.add(_buildContainer(
            category: sortedSpendings[i].category,
            count: sortedSpendings[i].count!,
            colors: colors[i]));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }

  Widget _buildContainer(
      {required String category,
      required int count,
      required List<Color> colors}) {
    return Container(
      width: 140,
      height: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
              colors: colors,
              begin: const Alignment(-1, -1),
              end: const Alignment(1, 1))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(category,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
          Text(count.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600))
        ],
      ),
    );
  }
}

class SpendingDetails extends StatefulWidget {
  const SpendingDetails({Key? key, required this.controller}) : super(key: key);
  final ReportController controller;
  @override
  State<SpendingDetails> createState() => _SpendingDetailsState();
}

class _SpendingDetailsState extends State<SpendingDetails> {
  bool sortByAmountAsc = false;
  bool sortByCountAsc = false;
  List<SpendingReport> list = [];

  @override
  void initState() {
    list = widget.controller.sortMapByAmount(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        0: const FlexColumnWidth(3),
        1: const FlexColumnWidth(2),
        2: const FlexColumnWidth(2)
      },
      border: TableBorder.all(color: BTColor.darkBlue, width: 1.0),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: _buildRow(['Category', 'Amount', 'Count'], true)),
        for (var sr in list)
          TableRow(
              children: _buildRow([
            sr.category,
            sr.amount.toStringAsFixed(2),
            sr.count.toString()
          ], false))
      ],
    );
  }

  List<Widget> _buildRow(List<String> contents, bool header) {
    List<Widget> cells = [];
    EdgeInsetsGeometry cellPadding = const EdgeInsets.symmetric(vertical: 8.0);

    if (header) {
      cells.add(Padding(
        padding: cellPadding,
        child: Text(
          contents[0],
          textAlign: TextAlign.center,
          style: BTTextTheme.bodyText2.apply(fontSizeFactor: 1.4),
        ),
      ));
      cells.add(Padding(
        padding: cellPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              contents[1],
              style: BTTextTheme.bodyText2.apply(fontSizeFactor: 1.4),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    sortByAmountAsc = !sortByAmountAsc;
                    list = widget.controller.sortMapByAmount(sortByAmountAsc);
                  });
                },
                child: Row(
                  children: [
                    RotatedBox(
                      quarterTurns: sortByAmountAsc ? 2 : 0,
                      child: const Icon(
                        Icons.sort_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ));
      cells.add(Padding(
        padding: cellPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              contents[2],
              style: BTTextTheme.bodyText2.apply(fontSizeFactor: 1.4),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    sortByCountAsc = !sortByCountAsc;
                    list = widget.controller.sortMapByCount(sortByCountAsc);
                  });
                },
                child: RotatedBox(
                  quarterTurns: sortByCountAsc ? 2 : 0,
                  child: const Icon(
                    Icons.sort_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ));
    } else {
      for (int i = 0; i < contents.length; i++) {
        cells.add(Padding(
          padding: cellPadding,
          child: Text(
            contents[i],
            textAlign: TextAlign.center,
            style: BTTextTheme.bodyText1.apply(fontSizeFactor: 1.2),
          ),
        ));
      }
    }
    return cells;
  }
}
