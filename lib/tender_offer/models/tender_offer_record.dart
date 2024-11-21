import 'package:equatable/equatable.dart';

class TenderOfferRecord extends Equatable {
  final String code;
  final String name;
  final String amount;
  final String price;
  final String availableAmount;
  final String purchaserCode;

  const TenderOfferRecord({
    required this.code,
    required this.name,
    required this.amount,
    required this.price,
    this.availableAmount = '',
    this.purchaserCode = '',
  });

  @override
  List<Object?> get props => [code, name, amount, price, availableAmount, purchaserCode];
} 