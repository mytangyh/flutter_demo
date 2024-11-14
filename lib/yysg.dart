import 'package:flutter/material.dart';

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

enum ExchangeType { reserve, cancel }

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: TabBar(
            tabs: [
              Tab(text: '上证'),
              Tab(text: '深证'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ExchangeFormView(
              exchangeType: type,
              market: '上证',
              showSubTabs: false,
            ),
            ExchangeFormView(
              exchangeType: type,
              market: '深证',
              showSubTabs: true,
            ),
          ],
        ),
      ),
    );
  }
}

class ExchangeFormView extends StatelessWidget {
  final ExchangeType exchangeType;
  final String market;
  final bool showSubTabs;

  const ExchangeFormView({
    Key? key,
    required this.exchangeType,
    required this.market,
    required this.showSubTabs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormSection(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _handleSubmit(context),
            child: Text('提交'),
          ),
          SizedBox(height: 20),
          if (showSubTabs) _buildSubTabs() else _buildDataTable(),
        ],
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    // TODO: 实现提交逻辑
    print('提交表单 - $market - ${exchangeType.name}');
  }

  Widget _buildFormSection() {
    final List<String> fields = [
      '证券代码',
      '证券名称',
      '预约数量',
      '预约价格',
    ];

    return Column(
      children: fields.map((label) => _buildFormField(label)).toList(),
    );
  }

  Widget _buildFormField(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
    final List<DataColumn> columns = [
      '证券代码',
      '证券名称',
      '预约数量',
      '预约价格',
    ].map((label) => DataColumn(label: Text(label))).toList();

    final List<DataRow> rows = [
      _createDataRow(
        market == '上证' ? '600001' : '000001',
        '示例股票',
        '1000',
        '10.00',
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns,
        rows: rows,
      ),
    );
  }

  DataRow _createDataRow(
    String code,
    String name,
    String amount,
    String price,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(code)),
        DataCell(Text(name)),
        DataCell(Text(amount)),
        DataCell(Text(price)),
      ],
    );
  }
}
