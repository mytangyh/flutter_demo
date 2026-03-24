import '../models/market_type.dart';
import '../models/tender_offer_record.dart';
import '../models/tender_offer_type.dart';

abstract class TenderOfferRepository {
  Future<List<TenderOfferRecord>> getTenderOfferRecords(
    MarketType market,
    TenderOfferType type,
  );

  Future<String> getAvailableAmount(
    String code,
    MarketType market,
  );

  Future<void> submitTenderOfferForm({
    required String code,
    required String amount,
    String? price,
    String? purchaserCode,
    required MarketType market,
    required TenderOfferType type,
  });
} 