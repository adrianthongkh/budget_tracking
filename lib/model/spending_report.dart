class SpendingReport {
  String category;
  double amount;
  int? count;

  SpendingReport(this.category, this.amount, this.count);

  double getPercentage(double total) {
    return (amount / total) * 100;
  }
}
