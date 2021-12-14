import 'package:tradget/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSummary {
  String month;
  double income;
  double expenses;
  double diff = 0;

  MonthSummary(this.month, this.income, this.expenses) {
    diff = income - expenses;
  }

  Widget buildCard() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(Icons.stacked_line_chart_rounded,
              size: 36, color: BTColor.normal),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(month, style: BTTextTheme.headline2),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: getFormattedDiff(diff),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Text('+RM${income.toStringAsFixed(2)}',
                    style: BTTextTheme.headline2.apply(
                        color: BTColor.brighterGreen, fontSizeFactor: 0.8)),
                Text('-RM${expenses.toStringAsFixed(2)}',
                    style: BTTextTheme.headline2.apply(
                        color: BTColor.brighterRed, fontSizeFactor: 0.8)),
              ])
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Icon(Icons.chevron_right_rounded,
              size: 36, color: BTColor.normal),
        )
      ],
    );
  }

  Widget getFormattedDiff(double value) {
    String s = (value != 0)
        ? (value > 0)
            ? '+'
            : '-'
        : '';

    s += 'RM' + value.abs().toStringAsFixed(2);
    Color color = (value != 0)
        ? (value > 0)
            ? BTColor.brighterGreen
            : BTColor.brighterRed
        : Colors.grey;
    return Text(s,
        style: BTTextTheme.headline2
            .apply(color: color, fontSizeFactor: 1.2, fontWeightDelta: 1));
  }

  DateTime getDateTime() {
    DateFormat format = DateFormat('MMMM y');
    return format.parse(month);
  }
}
