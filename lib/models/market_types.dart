import 'exchange_types.dart';

enum MarketType {
  sh,  // 上证
  sz;  // 深证

  String displayName(ExchangeType type) {
    final marketName = this == MarketType.sh ? '上海' : '深圳';
    final actionName = type == ExchangeType.reserve ? '预受要约' : '解除要约';
    return '$marketName$actionName';
  }

  String get code {
    switch (this) {
      case MarketType.sh:
        return '600001'; // 示例代码
      case MarketType.sz:
        return '000001'; // 示例代码
    }
  }
} 