import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/exchange_bloc.dart';
import 'models/exchange_record.dart';
import 'models/exchange_types.dart';
import 'models/market_types.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '预约收购',
      home: AppointmentPage(),
      routes: {
        '/reserve': (context) => ExchangePage(
              title: '预受预约',
              type: ExchangeType.reserve,
            ),
        '/cancel': (context) => ExchangePage(
              title: '解除预约',
              type: ExchangeType.cancel,
            ),
      },
    );
  }
}

class AppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('预约收购', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('预受预约'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/reserve');
            },
          ),
          Divider(height: 1, color: Colors.grey[300]),
          ListTile(
            title: Text('解除预约'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/cancel');
            },
          ),
          Divider(height: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }
}

class ExchangePage extends StatelessWidget {
  final String title;
  final ExchangeType type;

  const ExchangePage({
    Key? key,
    required this.title,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExchangeBloc(),
      child: DefaultTabController(
        length: MarketType.values.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            bottom: TabBar(
              tabs: MarketType.values
                  .map((market) => Tab(text: market.displayName(type)))
                  .toList(),
            ),
          ),
          body: TabBarView(
            children: MarketType.values
                .map(
                  (market) => ExchangeFormView(
                    exchangeType: type,
                    market: market,
                    showSubTabs: market == MarketType.sz,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class ExchangeFormView extends StatefulWidget {
  final ExchangeType exchangeType;
  final MarketType market;
  final bool showSubTabs;

  const ExchangeFormView({
    Key? key,
    required this.exchangeType,
    required this.market,
    required this.showSubTabs,
  }) : super(key: key);

  @override
  State<ExchangeFormView> createState() => _ExchangeFormViewState();
}

class _ExchangeFormViewState extends State<ExchangeFormView> {
  final _codeController = TextEditingController();
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();
  final _availableAmountController = TextEditingController();
  final _purchaserCodeController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupCodeListener();
  }

  void _loadData() {
    context.read<ExchangeBloc>().add(
          LoadExchangeData(
            market: widget.market,
            type: widget.exchangeType,
          ),
        );
  }

  void _setupCodeListener() {
    _codeController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 500), () {
        final code = _codeController.text;
        if (code.length == 6) {
          context.read<ExchangeBloc>().add(
                QuerySecurityInfo(
                  code: code,
                  market: widget.market,
                ),
              );
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _codeController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    _availableAmountController.dispose();
    _purchaserCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormSection(),
          SizedBox(height: 20),
          _buildSubmitButton(),
          SizedBox(height: 20),
          if (widget.showSubTabs) _buildSubTabs() else _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<ExchangeBloc, ExchangeState>(
      builder: (context, state) {
        final buttonColor = widget.exchangeType == ExchangeType.reserve
            ? Colors.red
            : Colors.blue;
            
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: state is ExchangeSubmitting
                ? null
                : () => _handleSubmit(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: state is ExchangeSubmitting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.exchangeType == ExchangeType.reserve ? '预受要约' : '解除要约',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  void _handleSubmit(BuildContext context) {
    context.read<ExchangeBloc>().add(
          SubmitExchangeForm(
            code: _codeController.text,
            name: '',
            amount: _amountController.text,
            price: widget.market == '上证' ? _priceController.text : '',
            purchaserCode: widget.market == '深证' ? _purchaserCodeController.text : '',
            market: widget.market,
            type: widget.exchangeType,
          ),
        );
  }

  Widget _buildFormSection() {
    if (widget.market == MarketType.sh) {
      return Column(
        children: [
          _buildFormField('要约代码', _codeController),
          _buildFormField('申报价格', _priceController),
          _buildFormField('预收数量', _amountController),
          _buildFormField('可用数量', _availableAmountController, readOnly: true),
        ],
      );
    } else {
      return Column(
        children: [
          _buildFormField('证券代码', _codeController),
          _buildFormField('收购人代码', _purchaserCodeController),
          _buildFormField('预收数量', _amountController),
          _buildFormField('可用数量', _availableAmountController, readOnly: true),
        ],
      );
    }
  }

  Widget _buildFormField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    String hintText = '';
    
    if (widget.market == MarketType.sh) {
      switch (label) {
        case '要约代码':
          hintText = '请输入6位要约代码';
          break;
        case '申报价格':
          hintText = '请输入申报价格';
          break;
        case '预收数量':
          hintText = '请输入预收数量';
          break;
        case '可用数量':
          hintText = '自动计算可用数量';
          break;
      }
    } else {
      switch (label) {
        case '证券代码':
          hintText = '请输入6位证券代码';
          break;
        case '收购人代码':
          hintText = '请输入收购人代码';
          break;
        case '预收数量':
          hintText = '请输入预收数量';
          break;
        case '可用数量':
          hintText = '自动计算可用数量';
          break;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                filled: true,
                fillColor: readOnly ? Colors.grey[100] : Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: '人'),
              Tab(text: '事件'),
            ],
            labelColor: Colors.blue,
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                _buildDataTable(),
                _buildDataTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return BlocConsumer<ExchangeBloc, ExchangeState>(
      listener: (context, state) {
        if (state is SecurityInfoLoaded) {
          _availableAmountController.text = state.availableAmount;
        }
      },
      builder: (context, state) {
        if (state is ExchangeLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is ExchangeError) {
          return Center(child: Text(state.message));
        }

        final records = state is ExchangeLoaded ? state.records : <ExchangeRecord>[];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: widget.market == MarketType.sh
                ? [
                    '要约代码',
                    '证券名称',
                    '申报价格',
                    '可用数量',
                  ].map((label) => DataColumn(label: Text(label))).toList()
                : [
                    '证券代码',
                    '证券名称',
                    '收购人代码',
                    '可用数量',
                  ].map((label) => DataColumn(label: Text(label))).toList(),
            rows: records.map((record) {
              return DataRow(
                cells: widget.market == MarketType.sh
                    ? [
                        DataCell(
                          Text(record.code),
                          onTap: () => _fillFormFromRecord(record),
                        ),
                        DataCell(Text(record.name)),
                        DataCell(Text(record.price)),
                        DataCell(Text(record.availableAmount)),
                      ]
                    : [
                        DataCell(
                          Text(record.code),
                          onTap: () => _fillFormFromRecord(record),
                        ),
                        DataCell(Text(record.name)),
                        DataCell(Text(record.purchaserCode)),
                        DataCell(Text(record.availableAmount)),
                      ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _fillFormFromRecord(ExchangeRecord record) {
    _codeController.text = record.code;
    _availableAmountController.text = record.availableAmount;
    if (widget.market == '上证') {
      _priceController.text = record.price;
    } else {
      _purchaserCodeController.text = record.purchaserCode;
    }
  }
}
