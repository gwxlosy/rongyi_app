import 'package:flutter/material.dart';
import 'sign_to_text_page.dart'; //手语转文字页面
import 'test_hand_page.dart'; //测试识别功能
import 'login_page.dart'; //登陆页面

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF7A59)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

