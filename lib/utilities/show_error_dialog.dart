import 'package:flutter/material.dart';

Future<void> showErrorDialog(context, String text) {
  return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text('Error'),
            content: Text(text),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok')),
            ]);
      });
}
