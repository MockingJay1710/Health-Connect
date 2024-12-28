import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String? _email;

  String? get email => _email;

  void setEmail(String email) {
    _email = email;
    notifyListeners();  // Notify listeners that the email has changed
  }
}