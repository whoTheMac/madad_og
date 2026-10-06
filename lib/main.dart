import 'package:flutter/material.dart';
import 'package:madad/screens/dashboard_screen.dart';
import 'package:madad/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: "https://fdmkryrezyvkcdzglgws.supabase.co",
      publishableKey: "sb_publishable_S897UOC2k3rE6JWh-Epk1Q__2M_IOCW" );
  runApp(MyApp());
}
final supabase = Supabase.instance.client;
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Study Companion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const LogoPage(),
    );
  }
}