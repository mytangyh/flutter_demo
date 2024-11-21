import 'package:flutter/material.dart';
import '../../tender_offer/views/appointment_page.dart';
import '../../tender_offer/views/tender_offer_page.dart';
import '../../tender_offer/models/tender_offer_type.dart';

class AppRoutes {
  static const String initial = '/';
  static const String accept = '/accept';
  static const String withdraw = '/withdraw';

  static Map<String, Widget Function(BuildContext)> get routes => {
        initial: (_) => const AppointmentPage(),
        accept: (_) => const TenderOfferPage(
              title: '预受要约',
              type: TenderOfferType.accept,
            ),
        withdraw: (_) => const TenderOfferPage(
              title: '解除要约',
              type: TenderOfferType.withdraw,
            ),
      };
} 