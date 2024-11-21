import 'package:flutter/material.dart';
import '../constants/form_config.dart';

class CustomFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool readOnly;
  final bool isAvailableAmount;

  const CustomFormField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.readOnly = false,
    this.isAvailableAmount = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isAvailableAmount) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: FormConfig.fieldSpacing),
        child: Row(
          children: [
            Text(
              '可用数量：',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            Text(
              controller.text.isEmpty ? '--' : '${controller.text}股',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: FormConfig.fieldSpacing),
      child: Row(
        children: [
          SizedBox(
            width: FormConfig.labelWidth,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 