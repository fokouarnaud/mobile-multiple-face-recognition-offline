import 'package:flutter/material.dart';


class SnackbarService {
  static final SnackbarService _instance = SnackbarService._internal();
  static SnackbarService get instance => _instance;

  SnackbarService._internal();

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void showSimpleSnackbar(String message, {int durationInSeconds = 2}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: durationInSeconds),
      ),
    );
  }

  void showResponse(String message, {
    bool isError = true,
    int durationInSeconds = 3,
  }) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      ResponseSnackBar(
        message: message,
        isError: isError,
        duration: Duration(seconds: durationInSeconds),
      ),
    );
  }

  void showSuccess(String message, {int durationInSeconds = 3}) {
    showResponse(message, isError: false, durationInSeconds: durationInSeconds);
  }

  void showError(String message, {int durationInSeconds = 3}) {
    showResponse(message, isError: true, durationInSeconds: durationInSeconds);
  }
}

class ResponseSnackBar extends SnackBar {
  final String message;
  final bool isError;

  ResponseSnackBar({
    super.key,
    required this.message,
    required this.isError,
    super.duration = const Duration(seconds: 5),
  }) : super(
    content: Text(message),
    backgroundColor: isError ? Colors.red : Colors.green,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 20.0,
    behavior: SnackBarBehavior.floating,
  );
}