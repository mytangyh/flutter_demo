import 'tender_offer_type.dart';

enum MarketType {
  sh,  // 上证
  sz;  // 深证

  String displayName(TenderOfferType type) {
    final marketName = this == MarketType.sh ? '上海' : '深圳';
    return '$marketName${type.displayName}';
  }

  String get defaultCode => this == MarketType.sh ? '600001' : '000001';
  
  bool get isSh => this == MarketType.sh;
  bool get isSz => this == MarketType.sz;
} 