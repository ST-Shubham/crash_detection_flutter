import 'package:crash_detection_and_analysis/views/crash_detection.dart';
import 'package:flutter/material.dart';
import 'package:crash_detection_and_analysis/constants/routes.dart';
import 'package:crash_detection_and_analysis/services/auth/auth_service.dart';
import 'package:crash_detection_and_analysis/views/loading_view.dart';
import 'package:crash_detection_and_analysis/views/login_view.dart';
import 'package:crash_detection_and_analysis/views/register_view.dart';
import 'package:crash_detection_and_analysis/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        healthAnalysisRoute: (context) => const GyroscopeDataCollector(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().intialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const GyroscopeDataCollector();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const LoadingView();
        }
      },
    );
  }
}
