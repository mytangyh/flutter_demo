import 'package:flutter/material.dart';
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
        ? _buildAvailableAmount()
        : _buildInputField();
  }

  Widget _buildAvailableAmount() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: TenderOfferConstants.defaultSpacing,
      ),
      child: Row(
        children: [
          Text(
            '可用数量：',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            controller.text.isEmpty ? '--' : '${controller.text}股',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: TenderOfferConstants.defaultSpacing,
      ),
      child: Row(
        children: [
          SizedBox(
            width: TenderOfferConstants.labelWidth,
            child: Text(
              config.label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: config.readOnly,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: config.hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: _buildUnderlineBorder(),
                enabledBorder: _buildUnderlineBorder(),
                focusedBorder: _buildUnderlineBorder(Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputBorder _buildUnderlineBorder([Color? color]) {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        color: color ?? Colors.grey[300]!,
      ),
    );
  }
} 