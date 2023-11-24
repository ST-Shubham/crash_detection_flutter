import 'package:flutter_sms/flutter_sms.dart';

void sendingSMS(String msg, List<String> listReceipents) async {
  String sendResult = await sendSMS(message: msg, recipients: listReceipents);
  print(sendResult);
}
