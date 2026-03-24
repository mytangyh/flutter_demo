import 'package:equatable/equatable.dart';
import '../models/market_type.dart';
import '../models/tender_offer_type.dart';

abstract class TenderOfferEvent extends Equatable {
  const TenderOfferEvent();

  @override
  List<Object?> get props => [];
}

class LoadTenderOfferData extends TenderOfferEvent {
  final MarketType market;
  final TenderOfferType type;

  const LoadTenderOfferData({
    required this.market,
    required this.type,
  });

  @override
  List<Object?> get props => [market, type];
}

class QuerySecurityInfo extends TenderOfferEvent {
  final String code;
  final MarketType market;

  const QuerySecurityInfo({
    required this.code,
    required this.market,
  });

  @override
  List<Object?> get props => [code, market];
}

class SubmitTenderOfferForm extends TenderOfferEvent {
  final String code;
  final String amount;
  final String? price;
  final String? purchaserCode;
  final MarketType market;
  final TenderOfferType type;

  const SubmitTenderOfferForm({
    required this.code,
    required this.amount,
    required this.market,
    required this.type,
    this.price,
    this.purchaserCode,
  });

  @override
  List<Object?> get props => [
        code,
        amount,
        price,
        purchaserCode,
        market,
        type,
      ];
}

class LoadTabData extends TenderOfferEvent {
  final bool isPurchaserTab;

  LoadTabData({required this.isPurchaserTab});

  @override
  List<Object?> get props => [isPurchaserTab];
} 