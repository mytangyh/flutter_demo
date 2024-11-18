import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/exchange_record.dart';
import '../models/exchange_types.dart';
import '../models/market_types.dart';

// Events
abstract class ExchangeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitExchangeForm extends ExchangeEvent {
  final String code;
  final String name;
  final String amount;
  final String price;
  final MarketType market;
  final ExchangeType type;
  final String purchaserCode;

  SubmitExchangeForm({
    required this.code,
    required this.name,
    required this.amount,
    required this.price,
    required this.market,
    required this.type,
    this.purchaserCode = '',
  });

  @override
  List<Object?> get props => [code, name, amount, price, market, type, purchaserCode];
}

class LoadExchangeData extends ExchangeEvent {
  final MarketType market;
  final ExchangeType type;

  LoadExchangeData({
    required this.market,
    required this.type,
  });

  @override
  List<Object?> get props => [market, type];
}

class QuerySecurityInfo extends ExchangeEvent {
  final String code;
  final MarketType market;

  QuerySecurityInfo({
    required this.code,
    required this.market,
  });

  @override
  List<Object?> get props => [code, market];
}

// States
class ExchangeState extends Equatable {
  final MarketType currentMarket;
  final List<ExchangeRecord> records;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? availableAmount;

  const ExchangeState({
    this.currentMarket = MarketType.sh,
    this.records = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.availableAmount,
  });

  ExchangeState copyWith({
    MarketType? currentMarket,
    List<ExchangeRecord>? records,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? availableAmount,
  }) {
    return ExchangeState(
      currentMarket: currentMarket ?? this.currentMarket,
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      availableAmount: availableAmount,
    );
  }

  @override
  List<Object?> get props => [
        currentMarket,
        records,
        isLoading,
        isSubmitting,
        error,
        availableAmount,
      ];
}

// Bloc
class ExchangeBloc extends Bloc<ExchangeEvent, ExchangeState> {
  ExchangeBloc() : super(ExchangeState()) {
    on<LoadExchangeData>(_onLoadExchangeData);
    on<SubmitExchangeForm>(_onSubmitExchangeForm);
    on<QuerySecurityInfo>(_onQuerySecurityInfo);
  }

  Future<void> _onLoadExchangeData(
    LoadExchangeData event,
    Emitter<ExchangeState> emit,
  ) async {
    try {
      final records = [
        ExchangeRecord(
          code: event.market.code,
          name: '示例股票',
          amount: '1000',
          price: event.market == MarketType.sh ? '10.00' : '',
          availableAmount: '10000',
          purchaserCode: event.market == MarketType.sz ? 'P001' : '',
        ),
      ];
      emit(state.copyWith(
        records: records,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSubmitExchangeForm(
    SubmitExchangeForm event,
    Emitter<ExchangeState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await Future.delayed(Duration(seconds: 1)); // 模拟网络请求
      emit(state.copyWith(isSubmitting: false));
      add(LoadExchangeData(market: event.market, type: event.type));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onQuerySecurityInfo(
    QuerySecurityInfo event,
    Emitter<ExchangeState> emit,
  ) async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      
      if (event.code.length == 6) {
        emit(state.copyWith(
          availableAmount: '10000',
          error: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
} 