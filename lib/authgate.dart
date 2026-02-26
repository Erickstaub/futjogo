import 'package:flutter/material.dart';
import 'package:futjogo/home.dart';
import 'package:futjogo/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authgate extends StatelessWidget {
  const Authgate({super.key});

  @override
  Widget build(BuildContext context) {
final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return const Login();
    } else {
      return const Home();
    }
  }
}