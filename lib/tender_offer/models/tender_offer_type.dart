import 'package:flutter/material.dart';

enum TenderOfferType {
  accept,    // 预受要约
  withdraw;  // 解除要约

  String get displayName {
    switch (this) {
      case TenderOfferType.accept:
        return '预受要约';
      case TenderOfferType.withdraw:
        return '解除要约';
    }
  }

  Color get buttonColor {
    switch (this) {
      case TenderOfferType.accept:
        return Colors.red;
      case TenderOfferType.withdraw:
        return Colors.blue;
    }
  }
} 