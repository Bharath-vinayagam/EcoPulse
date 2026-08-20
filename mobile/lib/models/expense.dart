class Expense {
  final int id;
  final String vendor;
  final double amount;
  final DateTime date;
  final String itemsText;
  final String category;
  final double co2Kg;

  Expense({
    required this.id,
    required this.vendor,
    required this.amount,
    required this.date,
    required this.itemsText,
    required this.category,
    required this.co2Kg,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      vendor: json['vendor'] ?? 'Unknown',
      amount: (json['amount'] ?? 0).toDouble(),
      date: DateTime.parse(json['date']),
      itemsText: json['items_text'] ?? '',
      category: json['category'] ?? 'Other',
      co2Kg: (json['co2_kg'] ?? 0).toDouble(),
    );
  }

  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  String get co2Display => '${co2Kg.toStringAsFixed(3)} kg CO₂';
  String get amountDisplay => '₹${amount.toStringAsFixed(0)}';
}

class Summary {
  final double totalSpend;
  final double totalCo2;
  final List<CategorySummary> byCategory;
  final Map<String, dynamic>? realWorldImpact;

  Summary({
    required this.totalSpend,
    required this.totalCo2,
    required this.byCategory,
    this.realWorldImpact,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    final List<dynamic> categories = json['by_category'] ?? [];
    return Summary(
      totalSpend: (json['total_spend'] ?? 0).toDouble(),
      totalCo2: (json['total_co2'] ?? 0).toDouble(),
      byCategory: categories.map((c) => CategorySummary.fromJson(c)).toList(),
      realWorldImpact: json['real_world_impact'],
    );
  }

  String get totalSpendDisplay => '₹${totalSpend.toStringAsFixed(0)}';
  String get totalCo2Display => '${totalCo2.toStringAsFixed(2)} kg';
}

class CategorySummary {
  final String category;
  final double spend;
  final double co2;

  CategorySummary({
    required this.category,
    required this.spend,
    required this.co2,
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      category: json['category'] ?? 'Other',
      spend: (json['spend'] ?? 0).toDouble(),
      co2: (json['co2'] ?? 0).toDouble(),
    );
  }
}
