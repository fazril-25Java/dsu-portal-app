import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/welcome_page.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://cwotvifkujfztfmfpbeb.supabase.co',
    anonKey: 'sb_publishable_my306-GGU-EoxW-rzoFLHg_noXCiSAx',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WelcomePage(),
    );
  }
}
