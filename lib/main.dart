import 'package:flutter/material.dart';
import 'package:futjogo/authgate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://opxtnadhpscdfzztnaks.supabase.co',
    anonKey: 'sb_publishable_6KiE2dkEl8uTPEbx-IAL_w_NEJ8Ans_',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  
  Widget build(BuildContext context) {
    return const MaterialApp(
     debugShowCheckedModeBanner: false,
     home: Authgate()
    );
  }
}