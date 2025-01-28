import 'package:flutter/material.dart';

class FieldData {
  final TextEditingController controller;
  final String label;
  final bool isVisible;

  FieldData({
    required this.controller,
    required this.label,
    this.isVisible = true,
  });

  // Add method to create a copy of field data
  FieldData copyWith({String? text}) {
    return FieldData(
      controller: TextEditingController(text: text ?? controller.text),
      label: label,
      isVisible: isVisible,
    );
  }
}
