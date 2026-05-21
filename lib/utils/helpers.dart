import 'package:flutter/material.dart';

class UiHelpers {
  static Widget verticalSpace(double height) => SizedBox(height: height);

  static Widget errorText(String error) {
    return Text(
      error,
      style: const TextStyle(color: Colors.red),
    );
  }
}
