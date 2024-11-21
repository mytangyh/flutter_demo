class PositionRecord {
  final String name;
  final String code;
  final String profit;
  final String profitRatio;
  final String position;
  final String available;
  final String cost;
  final String currentPrice;

  const PositionRecord({
    required this.name,
    required this.code,
    required this.profit,
    required this.profitRatio,
    required this.position,
    required this.available,
    required this.cost,
    required this.currentPrice,
  });

  factory PositionRecord.fromJson(Map<String, dynamic> json) {
    return PositionRecord(
      name: json['name'] as String,
      code: json['code'] as String,
      profit: json['profit'] as String,
      profitRatio: json['profitRatio'] as String,
      position: json['position'] as String,
      available: json['available'] as String,
      cost: json['cost'] as String,
      currentPrice: json['currentPrice'] as String,
    );
  }
} 