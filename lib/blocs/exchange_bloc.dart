import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_demo/models/exchange_record.dart';
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
abstract class ExchangeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExchangeInitial extends ExchangeState {}

class ExchangeLoading extends ExchangeState {}

class ExchangeLoaded extends ExchangeState {
  final List<ExchangeRecord> records;

  ExchangeLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class ExchangeError extends ExchangeState {
  final String message;

  ExchangeError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExchangeSubmitting extends ExchangeState {}

class ExchangeSubmitSuccess extends ExchangeState {}

class SecurityInfoLoaded extends ExchangeState {
  final String name;
  final String availableAmount;

  SecurityInfoLoaded({
    required this.name,
    required this.availableAmount,
  });

  @override
  List<Object?> get props => [name, availableAmount];
}

// Bloc
class ExchangeBloc extends Bloc<ExchangeEvent, ExchangeState> {
  ExchangeBloc() : super(ExchangeInitial()) {
    on<LoadExchangeData>(_onLoadExchangeData);
    on<SubmitExchangeForm>(_onSubmitExchangeForm);
    on<QuerySecurityInfo>(_onQuerySecurityInfo);
  }

  Future<void> _onLoadExchangeData(
    LoadExchangeData event,
    Emitter<ExchangeState> emit,
  ) async {
    emit(ExchangeLoading());
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
      emit(ExchangeLoaded(records));
    } catch (e) {
      emit(ExchangeError(e.toString()));
    }
  }

  Future<void> _onSubmitExchangeForm(
    SubmitExchangeForm event,
    Emitter<ExchangeState> emit,
  ) async {
    emit(ExchangeSubmitting());
    try {
      // TODO: 实现实际的提交逻辑
      await Future.delayed(Duration(seconds: 1)); // 模拟网络请求
      emit(ExchangeSubmitSuccess());
      add(LoadExchangeData(market: event.market, type: event.type));
    } catch (e) {
      emit(ExchangeError(e.toString()));
    }
  }

  Future<void> _onQuerySecurityInfo(
    QuerySecurityInfo event,
    Emitter<ExchangeState> emit,
  ) async {
    try {
      // TODO: 实现实际的证券信息查询逻辑
      await Future.delayed(Duration(milliseconds: 500)); // 模拟网络请求
      
      // 模拟返回数据
      if (event.code.length == 6) {
        emit(SecurityInfoLoaded(
          name: '测试股票',
          availableAmount: '10000',
        ));
      }
    } catch (e) {
      emit(ExchangeError(e.toString()));
    }
  }
} 