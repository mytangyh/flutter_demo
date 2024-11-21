import '../models/market_types.dart';

class FormConfig {
  static const double labelWidth = 80.0;
  static const double fieldSpacing = 8.0;
  static const double buttonHeight = 44.0;

  static List<FormFieldConfig> getFields(MarketType market) {
    final fields = {
      MarketType.sh: [
        FormFieldConfig(
          label: '要约代码',
          hint: '请输入6位要约代码',
          isCode: true,
        ),
        FormFieldConfig(
          label: '申报价格',
          hint: '请输入申报价格',
        ),
        FormFieldConfig(
          label: '预收数量',
          hint: '请输入预收数量',
        ),
        FormFieldConfig(
          label: '可用数量',
          hint: '自动计算可用数量',
          readOnly: true,
        ),
      ],
      MarketType.sz: [
        FormFieldConfig(
          label: '证券代码',
          hint: '请输入6位证券代码',
          isCode: true,
        ),
        FormFieldConfig(
          label: '收购人代码',
          hint: '请输入收购人代码',
        ),
        FormFieldConfig(
          label: '预收数量',
          hint: '请输入预收数量',
        ),
        FormFieldConfig(
          label: '可用数量',
          hint: '自动计算可用数量',
          readOnly: true,
        ),
      ],
    };
    return fields[market]!;
  }

  static List<String> getTableColumns(MarketType market) {
    return market == MarketType.sh
        ? ['要约代码', '证券名称', '申报价格', '可用数量']
        : ['证券代码', '证券名称', '收购人代码', '可用数量'];
  }
}

class FormFieldConfig {
  final String label;
  final String hint;
  final bool readOnly;
  final bool isCode;

  const FormFieldConfig({
    required this.label,
    required this.hint,
    this.readOnly = false,
    this.isCode = false,
  });
} 