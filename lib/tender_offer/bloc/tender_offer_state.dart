import '../models/tender_offer_record.dart';
import '../models/purchaser_record.dart';
import '../models/position_record.dart';

class TenderOfferState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? availableAmount;
  final List<TenderOfferRecord> records;
  final List<PurchaserRecord> purchaserRecords;
  final List<PositionRecord> positionRecords;
  final SecurityInfo? securityInfo;

  const TenderOfferState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.availableAmount,
    this.records = const [],
    this.purchaserRecords = const [],
    this.positionRecords = const [],
    this.securityInfo,
  });

  TenderOfferState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? availableAmount,
    List<TenderOfferRecord>? records,
    List<PurchaserRecord>? purchaserRecords,
    List<PositionRecord>? positionRecords,
  }) {
    return TenderOfferState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      availableAmount: availableAmount ?? this.availableAmount,
      records: records ?? this.records,
      purchaserRecords: purchaserRecords ?? this.purchaserRecords,
      positionRecords: positionRecords ?? this.positionRecords,
    );
  }
} 