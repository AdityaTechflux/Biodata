import 'package:flutter/material.dart';
import '../request/education_details_api.dart';

class SwappingController extends ChangeNotifier {
  final EducationDetailsRequest _request = EducationDetailsRequest();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
}
