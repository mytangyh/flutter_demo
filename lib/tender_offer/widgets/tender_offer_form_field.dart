import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/tender_offer_bloc.dart';
import '../bloc/tender_offer_state.dart';
import '../models/form_config.dart';
import '../constants/tender_offer_constants.dart';

class TenderOfferFormField extends StatelessWidget {
  final FormFieldConfig config;
  final TextEditingController controller;

  const TenderOfferFormField({
    super.key,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return config.type == FieldType.availableAmount
        ? _buildAvailableAmount(context) // Pass context
        : _buildInputField();
  }

  Widget _buildAvailableAmount(BuildContext context) {
    // Add context parameter
    return BlocBuilder<TenderOfferBloc, TenderOfferState>(
      // Use BlocBuilder
      buildWhen: (previous, current) =>
          previous.availableAmount !=
          current.availableAmount, // Rebuild only when availableAmount changes
      builder: (context, state) {
        final availableAmount = state.availableAmount;
        return Column(
          children: [
            SizedBox(
              // Use SizedBox for consistent height
              height: TenderOfferConstants.formFieldHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('可用数量：',
                      style: TextStyle(fontSize: 14, color: Colors.black87)),
                  Text(
                    availableAmount == null || availableAmount.isEmpty
                        ? '--'
                        : '${availableAmount}股',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }

  Widget _buildInputField() {
    return Column(
      children: [
        SizedBox(
          // Use SizedBox for consistent height
          height: TenderOfferConstants.formFieldHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: TenderOfferConstants.labelWidth,
                child: Text(config.label,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87)),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: config.readOnly,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: config.hint,
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
