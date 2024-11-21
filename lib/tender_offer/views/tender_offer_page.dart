import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tender_offer_bloc.dart';
import '../models/market_type.dart';
import '../models/tender_offer_type.dart';
import '../repositories/mock_tender_offer_repository.dart';
import 'tender_offer_form_view.dart';

class TenderOfferPage extends StatelessWidget {
  final String title;
  final TenderOfferType type;

  const TenderOfferPage({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TenderOfferBloc(
        repository: MockTenderOfferRepository(),
      ),
      child: _TenderOfferPageContent(title: title, type: type),
    );
  }
}

class _TenderOfferPageContent extends StatelessWidget {
  final String title;
  final TenderOfferType type;

  const _TenderOfferPageContent({
    required this.title,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: MarketType.values.length,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(title),
      bottom: TabBar(
        tabs: MarketType.values
            .map((market) => Tab(text: market.displayName(type)))
            .toList(),
        labelColor: Colors.red,
        unselectedLabelColor: Colors.black87,
        indicatorColor: Colors.red,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      children: MarketType.values
          .map(
            (market) => TenderOfferFormView(
              type: type,
              market: market,
              showSubTabs: market == MarketType.sz,
            ),
          )
          .toList(),
    );
  }
} 