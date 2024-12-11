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
    return Column(
      children: [
        Container(
          height: TenderOfferConstants.formFieldHeight,
          padding: const EdgeInsets.symmetric(
            vertical: TenderOfferConstants.defaultSpacing,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '可用数量：',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.0,
                ),
              ),
              Text(
                controller.text.isEmpty ? '--' : '${controller.text}股',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildInputField() {
    return Column(
      children: [
        Container(
          height: TenderOfferConstants.formFieldHeight,
          padding: const EdgeInsets.symmetric(
            vertical: TenderOfferConstants.defaultSpacing,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: TenderOfferConstants.labelWidth,
                child: Text(
                  config.label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.0,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: config.readOnly,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.0,
                  ),
                  decoration: InputDecoration(
                    hintText: config.hint,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
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