import 'package:crash_detection_and_analysis/utils/dialogs/warning_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showHeartAnomilityDialog(BuildContext context) {
  return warningDialog(
    context: context,
    title: 'Alert !',
    content: 'Heart Rate Anomility Detected, Are you Safe?',
    dialogOptionBuilder: () => {
      'Help': false,
      'Yes': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
