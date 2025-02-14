import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:flutter/material.dart';

extension SnackBarExtension on BuildContext {
  void showSnackBar(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(0),
          curve: Curves.easeInOut,
        ),
        dismissDirection: DismissDirection.horizontal,
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).colorScheme.secondary,
        margin: Sizes.kPadd16,
        shape: RoundedRectangleBorder(
          borderRadius: Sizes.kRadius12,
        ),
        content: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: 1,
          child: Text(
            message,
            style: TextStyle(
              color:
                  isError ? Theme.of(this).colorScheme.onError : Colors.white,
            ),
          ),
        ),
        duration: duration,
      ),
    );
  }
}
