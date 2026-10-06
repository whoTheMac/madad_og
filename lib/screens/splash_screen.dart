import 'package:flutter/material.dart';
import '../authentication/auth_gate.dart';

class LogoPage extends StatefulWidget {
  const LogoPage({super.key});

  @override
  State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthGate(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff050505),

      appBar: AppBar(
        backgroundColor: const Color(0xff000000),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // IMAGE ABOVE MADAD
            Image.asset(
              'assets/images/logo1.jpg',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),



            // MADAD TEXT
            const Text(
              'M A D A D',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Color(0xFFC5A052),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
