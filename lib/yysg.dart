import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/exchange_bloc.dart';
import 'models/exchange_record.dart';
import 'models/exchange_types.dart';
import 'models/market_types.dart';
import 'constants/form_config.dart';
import 'widgets/form_field.dart';

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
              labelColor: Colors.red,
              unselectedLabelColor: Colors.black87,
              indicatorColor: Colors.red,
              labelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
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
  final Map<String, TextEditingController> _controllers = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadData();
  }

  void _initControllers() {
    final fields = FormConfig.getFields(widget.market);
    for (var field in fields) {
      _controllers[field.label] = TextEditingController();
      if (field.isCode) {
        _controllers[field.label]!.addListener(_setupCodeListener);
      }
    }
  }

  void _setupCodeListener() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      final codeLabel = widget.market == MarketType.sh ? '要约代码' : '证券代码';
      final code = _getController(codeLabel).text;
      if (code.length == 6) {
        context.read<ExchangeBloc>().add(
              QuerySecurityInfo(
                code: code,
                market: widget.market,
              ),
            );
      }
    });
  }

  TextEditingController _getController(String label) {
    return _controllers[label]!;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controllers.forEach((_, controller) => controller.dispose());
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
            onPressed: state.isSubmitting
                ? null
                : () => _handleSubmit(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: state.isSubmitting
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
    final codeLabel = widget.market == MarketType.sh ? '要约代码' : '证券代码';
    context.read<ExchangeBloc>().add(
          SubmitExchangeForm(
            code: _getController(codeLabel).text,
            name: '',
            amount: _getController('预收数量').text,
            price: widget.market == MarketType.sh ? _getController('申报价格').text : '',
            purchaserCode: widget.market == MarketType.sz ? _getController('收购人代码').text : '',
            market: widget.market,
            type: widget.exchangeType,
          ),
        );
  }

  Widget _buildFormSection() {
    final fields = FormConfig.getFields(widget.market);
    return Column(
      children: fields.map((field) {
        if (field.label == '可用数量') {
          return CustomFormField(
            label: field.label,
            hint: field.hint,
            controller: _getController(field.label),
            readOnly: true,
            isAvailableAmount: true,
          );
        }
        return CustomFormField(
          label: field.label,
          hint: field.hint,
          controller: _getController(field.label),
          readOnly: field.readOnly,
        );
      }).toList(),
    );
  }

  Widget _buildDataTable() {
    return BlocConsumer<ExchangeBloc, ExchangeState>(
      listener: (context, state) {
        if (state.availableAmount != null) {
          _getController('可用数量').text = state.availableAmount!;
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(child: Text(state.error!));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: FormConfig.getTableColumns(widget.market)
                .map((label) => DataColumn(label: Text(label)))
                .toList(),
            rows: _buildTableRows(state.records),
          ),
        );
      },
    );
  }

  List<DataRow> _buildTableRows(List<ExchangeRecord> records) {
    return records.map((record) {
      final cells = widget.market == MarketType.sh
          ? [
              record.code,
              record.name,
              record.price,
              record.availableAmount,
            ]
          : [
              record.code,
              record.name,
              record.purchaserCode,
              record.availableAmount,
            ];

      return DataRow(
        cells: cells.asMap().entries.map((entry) {
          return DataCell(
            Text(entry.value),
            onTap: entry.key == 0 ? () => _fillFormFromRecord(record) : null,
          );
        }).toList(),
      );
    }).toList();
  }

  void _fillFormFromRecord(ExchangeRecord record) {
    _getController(widget.market == MarketType.sh ? '要约代码' : '证券代码').text = record.code;
    _getController('可用数量').text = record.availableAmount;
    if (widget.market == MarketType.sh) {
      _getController('申报价格').text = record.price;
    } else {
      _getController('收购人代码').text = record.purchaserCode;
    }
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

  void _loadData() {
    context.read<ExchangeBloc>().add(
          LoadExchangeData(
            market: widget.market,
            type: widget.exchangeType,
          ),
        );
  }
}
