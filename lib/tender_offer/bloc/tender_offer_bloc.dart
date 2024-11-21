import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/mock_tender_offer_repository.dart';
import 'tender_offer_event.dart';
import 'tender_offer_state.dart';

class TenderOfferBloc extends Bloc<TenderOfferEvent, TenderOfferState> {
  final MockTenderOfferRepository repository;

  TenderOfferBloc({
    required this.repository,
  }) : super(const TenderOfferState()) {
    on<LoadTenderOfferData>(_onLoadTenderOfferData);
    on<QuerySecurityInfo>(_onQuerySecurityInfo);
    on<SubmitTenderOfferForm>(_onSubmitTenderOfferForm);
    on<LoadTabData>(_onLoadTabData);
  }

  Future<void> _onLoadTenderOfferData(
    LoadTenderOfferData event,
    Emitter<TenderOfferState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final records = await repository.getTenderOfferRecords(
        event.market,
        event.type,
      );
      emit(state.copyWith(
        records: records,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onQuerySecurityInfo(
    QuerySecurityInfo event,
    Emitter<TenderOfferState> emit,
  ) async {
    if (event.code.length != 6) return;

    try {
      final amount = await repository.getAvailableAmount(
        event.code,
        event.market,
      );
      emit(state.copyWith(availableAmount: amount));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onSubmitTenderOfferForm(
    SubmitTenderOfferForm event,
    Emitter<TenderOfferState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      await repository.submitTenderOfferForm(
        code: event.code,
        amount: event.amount,
        price: event.price,
        purchaserCode: event.purchaserCode,
        market: event.market,
        type: event.type,
      );
      emit(state.copyWith(isSubmitting: false));
      add(LoadTenderOfferData(
        market: event.market,
        type: event.type,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadTabData(
    LoadTabData event,
    Emitter<TenderOfferState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      if (event.isPurchaserTab) {
        final purchaserRecords = await repository.getPurchaserRecords();
        emit(state.copyWith(
          isLoading: false,
          purchaserRecords: purchaserRecords,
        ));
      } else {
        final positionRecords = await repository.getPositionRecords();
        emit(state.copyWith(
          isLoading: false,
          positionRecords: positionRecords,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: '加载数据失败：${e.toString()}',
      ));
    }
  }
} 