import '../constants/tender_offer_constants.dart';
import '../models/position_record.dart';
import '../models/purchaser_record.dart';
import '../models/tender_offer_record.dart';
import '../models/market_type.dart';
import '../models/tender_offer_type.dart';
import 'tender_offer_repository.dart';

class MockTenderOfferRepository implements TenderOfferRepository {
  @override
  Future<List<TenderOfferRecord>> getTenderOfferRecords(
    MarketType market,
    TenderOfferType type,
  ) async {
    await Future.delayed(TenderOfferConstants.mockNetworkDelay);
    return [
      TenderOfferRecord(
        code: market.defaultCode,
        name: '示例股票',
        amount: '1000',
        price: market.isSh ? '10.00' : '',
        availableAmount: '10000',
        purchaserCode: market.isSz ? 'P001' : '',
      ),
    ];
  }

  @override
  Future<String> getAvailableAmount(
    String code,
    MarketType market,
  ) async {
    await Future.delayed(TenderOfferConstants.debounceTime);
    return '10000';
  }

  @override
  Future<void> submitTenderOfferForm({
    required String code,
    required String amount,
    String? price,
    String? purchaserCode,
    required MarketType market,
    required TenderOfferType type,
  }) async {
    await Future.delayed(TenderOfferConstants.mockNetworkDelay);
    // 模拟网络请求，实际应该调用API
  }

  Future<List<PurchaserRecord>> getPurchaserRecords() async {
    await Future.delayed(TenderOfferConstants.mockNetworkDelay);
    
    // 模拟数据
    return [
      PurchaserRecord(
        purchaserCode: '000001',
        purchaserName: '示例收购方1',
        code: '600001',
        price: '15.66',
      ),
      PurchaserRecord(
        purchaserCode: '000002',
        purchaserName: '示例收购方2',
        code: '600002',
        price: '22.88',
      ),
    ];
  }

  Future<List<PositionRecord>> getPositionRecords() async {
    await Future.delayed(TenderOfferConstants.mockNetworkDelay);
    
    // 模拟数据
    return [
      PositionRecord(
        name: '平安银行',
        code: '000001',
        profit: '+2,394.05',
        profitRatio: '+12.45%',
        position: '1,000',
        available: '800',
        cost: '13.45',
        currentPrice: '15.66',
      ),
      PositionRecord(
        name: '招商银行',
        code: '600036',
        profit: '-1,256.80',
        profitRatio: '-5.23%',
        position: '2,000',
        available: '2,000',
        cost: '42.56',
        currentPrice: '41.88',
      ),
    ];
  }
} 