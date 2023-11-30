import 'package:flutter/material.dart';
import 'package:crash_detection_and_analysis/constants/routes.dart';
import 'package:crash_detection_and_analysis/services/auth/auth_exceptions.dart';
import 'package:crash_detection_and_analysis/services/auth/auth_service.dart';
import 'package:crash_detection_and_analysis/utils/dialogs/show_error_dialog.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20),
          ),
          const Center(
            child: Text("We've sent you an email verification."),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          const Center(
            child: Text("Please verify your email."),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
          ),
          const Text("If you haven't received the email yet click here:"),
          const Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          ElevatedButton(
            onPressed: () {
              AuthService.firebase().sendEmailVerification();
            },
            child: const Text(
              "Send Email Verification",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  AuthService.firebase().refreshUserCredentials();
                } on UserNotLoggedInAuthException {
                  showErrorDialog(context, 'User Not Logged In');
                } on GenericAuthException {
                  showErrorDialog(context, 'Unable to Refresh user Credentias');
                }
                final user = AuthService.firebase().currentUser;
                if (user?.isEmailVerified ?? false) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    healthAnalysisRoute,
                    (_) => false,
                  );
                } else {
                  showErrorDialog(context, 'Email is not Verified');
                }
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          ElevatedButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              if (!mounted) {
                return;
              }
              Navigator.pushNamedAndRemoveUntil(
                context,
                registerRoute,
                (_) => false,
              );
            },
            child: const Text(
              "Restart",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
