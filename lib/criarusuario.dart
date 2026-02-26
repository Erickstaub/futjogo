import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Criarusuario extends StatefulWidget {
  const Criarusuario({super.key});

  @override
  State<Criarusuario> createState() => _CriarusuarioState();
}

class _CriarusuarioState extends State<Criarusuario> {
   final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

 Future<void> _criar() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final supabase = Supabase.instance.client;

    final response = await supabase.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final user = response.user;

    if (user != null) {
      // 🔥 CRIA PROFILE AUTOMATICAMENTE
      await supabase.from('profiles').insert({
        'id': user.id,
        'nome': _emailController.text.split('@')[0], // nome provisório
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuário criado com sucesso 🚀")),
      );
      Navigator.pop(context);
    }
  } on AuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erro inesperado: $e")),
    );
  }

  setState(() => _isLoading = false);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
  controller: _emailController,
  decoration: const InputDecoration(
    labelText: 'Email',
    border: OutlineInputBorder(),
  ),
  validator: (value) =>
      value == null || value.isEmpty ? "Informe o email" : null,
),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextFormField(
  controller: _passwordController,
  obscureText: true,
  decoration: const InputDecoration(
    labelText: 'Senha',
    border: OutlineInputBorder(),
  ),
  validator: (value) =>
      value == null || value.length < 6 ? "Senha mínima 6 caracteres" : null,
),
            ),
            ElevatedButton(
              onPressed: _criar,
              child: Text('Criar'),
            ),
    ])));
  }
}