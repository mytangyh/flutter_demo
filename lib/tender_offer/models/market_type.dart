import 'tender_offer_type.dart';

// 市场类型枚举
enum MarketType {
  sh,  // 上海证券交易所
  sz;  // 深圳证券交易所

  // 获取市场显示名称
  String displayName(TenderOfferType type) {
    final marketName = this == MarketType.sh ? '上海' : '深圳';
    return '$marketName${type.displayName}';
  }

  // 获取默认证券代码
  String get defaultCode => this == MarketType.sh ? '600001' : '000001';
  
  // 便捷判断方法
  bool get isSh => this == MarketType.sh;
  bool get isSz => this == MarketType.sz;
} 