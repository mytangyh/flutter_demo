class PurchaserRecord {
  final String purchaserCode;
  final String purchaserName;
  final String code;
  final String price;

  const PurchaserRecord({
    required this.purchaserCode,
    required this.purchaserName,
    required this.code,
    required this.price,
  });

  factory PurchaserRecord.fromJson(Map<String, dynamic> json) {
    return PurchaserRecord(
      purchaserCode: json['purchaserCode'] as String,
      purchaserName: json['purchaserName'] as String,
      code: json['code'] as String,
      price: json['price'] as String,
    );
  }
} 