class TenderOfferConstants {


  // 防止实例化
  TenderOfferConstants._();
  
  // 布局常量
  static const double defaultSpacing = 8.0;
  static const double defaultPadding = 16.0;
  static const double labelWidth = 80.0;
  static const double buttonHeight = 48.0;
  static var formFieldHeight = 48.0;
  
  // 时间常量
  static const Duration debounceTime = Duration(milliseconds: 500);
  static const Duration mockNetworkDelay = Duration(milliseconds: 1000);

  
  // 表单字段的最大长度限制
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxPriceLength = 10;
  
  // 验证消息
  static const String requiredFieldMessage = '此字段为必填项';
  static const String invalidPriceMessage = '请输入有效的价格';
  static const String invalidNumberMessage = '请输入有效的数字';
  
  // 表单标签
  static const String titleLabel = '标题';
  static const String descriptionLabel = '描述';
  static const String priceLabel = '价格';
  static const String quantityLabel = '数量';

  // Tab标签
  static const String purchaserTabLabel = '要约收购人';
  static const String positionTabLabel = '持仓';

  // 表格列标签 - 要约收购人
  static const List<String> purchaserTableColumns = [
    '收购人代码',
    '收购人名称',
    '证券代码',
    '收购价格',
  ];

  // 表格列标签 - 持仓
  static const List<String> positionTableColumns = [
    '名称/代码',
    '盈亏/盈亏比',
    '持仓/可用',
    '成本/现价',
  ];
} 