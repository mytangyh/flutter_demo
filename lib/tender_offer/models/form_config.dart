import 'market_type.dart';

// 表单字段配置类
class FormFieldConfig {
  final String label;    // 字段标签
  final String hint;     // 提示文本
  final bool readOnly;   // 是否只读
  final bool isCode;     // 是否为证券代码字段
  final FieldType type;  // 字段类型

  const FormFieldConfig({
    required this.label,
    required this.hint,
    this.readOnly = false,
    this.isCode = false,
    this.type = FieldType.input,
  });
}

// 字段类型枚举
enum FieldType {
  input,           // 普通输入框
  availableAmount, // 可用数量字段
}

// 表单配置类
class FormConfig {
  // 获取指定市场的表单字段配置
  static List<FormFieldConfig> getFields(MarketType market) {
    return market == MarketType.sh ? _shFields : _szFields;
  }

  // 上海市场表单字段配置
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

  // 深圳市场表单字段配置
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