import 'market_type.dart';

class FormFieldConfig {
  final String label;
  final String hint;
  final bool readOnly;
  final bool isCode;
  final FieldType type;

  const FormFieldConfig({
    required this.label,
    required this.hint,
    this.readOnly = false,
    this.isCode = false,
    this.type = FieldType.input,
  });
}

enum FieldType {
  input,
  availableAmount,
}

class FormConfig {
  static List<FormFieldConfig> getFields(MarketType market) {
    return market == MarketType.sh ? _shFields : _szFields;
  }

  static const _shFields = [
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
      type: FieldType.availableAmount,
    ),
  ];

  static const _szFields = [
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
      type: FieldType.availableAmount,
    ),
  ];

  static List<String> getTableColumns(MarketType market) {
    return market == MarketType.sh
        ? ['要约代码', '证券名称', '申报价格', '可用数量']
        : ['证券代码', '证券名称', '收购人代码', '可用数量'];
  }
} 