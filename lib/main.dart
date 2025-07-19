import 'package:flutter/cupertino.dart';

import 'screens/login_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const HelloWorldApp());
}

class HelloWorldApp extends StatelessWidget {
  const HelloWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      title: Constants.APP_NAME,
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
