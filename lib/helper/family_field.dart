import 'package:flutter/material.dart';

class FamilyField {
  TextEditingController controller;
  String label;
  FocusNode focusNode;
  bool isVisible;

  FamilyField({
    required this.controller,
    required this.label,
    FocusNode? focusNode,
    this.isVisible = true,
  }) : focusNode = focusNode ?? FocusNode();
}
