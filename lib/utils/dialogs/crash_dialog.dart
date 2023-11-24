import 'package:crash_detection_and_analysis/utils/dialogs/warning_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showCrashDialog(BuildContext context) {
  print('returning WaringDialog');
  return warningDialog(
    context: context,
    title: 'Alert !',
    content: 'Crash Detected, Are you Safe?',
    dialogOptionBuilder: () => {
      'Help': false,
      'Yes': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
