import 'package:flutter/material.dart';

class UsernameEditField extends StatelessWidget {
  final InputDecoration? inputDecoration;
  final TextEditingController controller;
  final TextInputAction? textInputAction;

  static const double _formElementSize = 15;
  static final _emailRegExValidator = RegExp('.*@.*.com');

  const UsernameEditField(
      {super.key,
      required this.controller,
      this.inputDecoration,
      this.textInputAction});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: _formElementSize),
      minLines: 1,
      textInputAction: textInputAction,
      controller: controller,
      validator: (username) {
        if (username != null) {
          var isEmailValid = _isEmailValid(username);
          if (!isEmailValid) {
            return 'Enter a valid email';
          }
          return null;
        }
        return null;
      },
      decoration: inputDecoration,
    );
  }

  static bool _isEmailValid(String username) {
    var matches = _emailRegExValidator.firstMatch(username);
    final matchedText = matches?.group(0);
    return matchedText == username;
  }
}
