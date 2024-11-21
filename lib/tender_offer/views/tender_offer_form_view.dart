import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tender_offer_bloc.dart';
import '../bloc/tender_offer_event.dart';
import '../bloc/tender_offer_state.dart';
import '../models/tender_offer_record.dart';
import '../models/tender_offer_type.dart';
import '../models/market_type.dart';
import '../models/form_config.dart';
import '../widgets/tender_offer_form_field.dart';
import '../constants/tender_offer_constants.dart';

class TenderOfferFormView extends StatefulWidget {
  final TenderOfferType type;
  final MarketType market;
  final bool showSubTabs;

  const TenderOfferFormView({
    super.key,
    required this.type,
    required this.market,
    required this.showSubTabs,
  });

  @override
  State<TenderOfferFormView> createState() => _TenderOfferFormViewState();
}

class _TenderOfferFormViewState extends State<TenderOfferFormView> {
  final Map<String, TextEditingController> _controllers = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadData();
    if (widget.showSubTabs) {
      context.read<TenderOfferBloc>().add(
            LoadTabData(isPurchaserTab: true),
          );
    }
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
    _debounce = Timer(TenderOfferConstants.debounceTime, () {
      final codeLabel = widget.market.isSh ? '要约代码' : '证券代码';
      final code = _getController(codeLabel).text;
      if (code.length == 6) {
        context.read<TenderOfferBloc>().add(
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
      padding: const EdgeInsets.all(TenderOfferConstants.defaultPadding),
      child: Column(
        children: [
          _buildFormSection(),
          const SizedBox(height: 20),
          _buildSubmitButton(),
          const SizedBox(height: 20),
          if (widget.showSubTabs) _buildSubTabs() else _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<TenderOfferBloc, TenderOfferState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: TenderOfferConstants.buttonHeight,
          child: ElevatedButton(
            onPressed: state.isSubmitting
                ? null
                : () => _handleSubmit(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.type.buttonColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.type.displayName,
                    style: const TextStyle(
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
    final codeLabel = widget.market.isSh ? '要约代码' : '证券代码';
    context.read<TenderOfferBloc>().add(
          SubmitTenderOfferForm(
            code: _getController(codeLabel).text,
            amount: _getController('预收数量').text,
            price: widget.market.isSh ? _getController('申报价格').text : null,
            purchaserCode: widget.market.isSz ? _getController('收购人代码').text : null,
            market: widget.market,
            type: widget.type,
          ),
        );
  }

  void _loadData() {
    context.read<TenderOfferBloc>().add(
          LoadTenderOfferData(
            market: widget.market,
            type: widget.type,
          ),
        );
  }

  Widget _buildFormSection() {
    final fields = FormConfig.getFields(widget.market);
    return Column(
      children: fields.map((field) {
        return TenderOfferFormField(
          config: field,
          controller: _getController(field.label),
        );
      }).toList(),
    );
  }

  Widget _buildDataTable() {
    return BlocConsumer<TenderOfferBloc, TenderOfferState>(
      listener: (context, state) {
        if (state.availableAmount != null) {
          _getController('可用数量').text = state.availableAmount!;
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
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

  List<DataRow> _buildTableRows(List<TenderOfferRecord> records) {
    return records.map((record) {
      final cells = widget.market.isSh
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

  void _fillFormFromRecord(TenderOfferRecord record) {
    final codeLabel = widget.market.isSh ? '要约代码' : '证券代码';
    _getController(codeLabel).text = record.code;
    _getController('可用数量').text = record.availableAmount;
    if (widget.market.isSh) {
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
              Tab(text: TenderOfferConstants.purchaserTabLabel),
              Tab(text: TenderOfferConstants.positionTabLabel),
            ],
            labelColor: Theme.of(context).primaryColor,
            onTap: (index) {
              context.read<TenderOfferBloc>().add(
                    LoadTabData(isPurchaserTab: index == 0),
                  );
            },
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                _buildPurchaserTable(),
                _buildPositionTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaserTable() {
    return BlocBuilder<TenderOfferBloc, TenderOfferState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(child: Text(state.error!));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: TenderOfferConstants.purchaserTableColumns
                .map((label) => DataColumn(label: Text(label)))
                .toList(),
            rows: state.purchaserRecords.map((record) {
              return DataRow(
                cells: [
                  DataCell(Text(record.purchaserCode)),
                  DataCell(Text(record.purchaserName)),
                  DataCell(Text(record.code)),
                  DataCell(Text(record.price)),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPositionTable() {
    return BlocBuilder<TenderOfferBloc, TenderOfferState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(child: Text(state.error!));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: TenderOfferConstants.positionTableColumns
                .map((label) => DataColumn(label: Text(label)))
                .toList(),
            rows: state.positionRecords.map((record) {
              return DataRow(
                cells: [
                  DataCell(Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.name),
                      Text(record.code, style: TextStyle(color: Colors.grey[600])),
                    ],
                  )),
                  DataCell(Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(record.profit),
                      Text(record.profitRatio, style: TextStyle(color: Colors.grey[600])),
                    ],
                  )),
                  DataCell(Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(record.position),
                      Text(record.available, style: TextStyle(color: Colors.grey[600])),
                    ],
                  )),
                  DataCell(Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(record.cost),
                      Text(record.currentPrice, style: TextStyle(color: Colors.grey[600])),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
} 