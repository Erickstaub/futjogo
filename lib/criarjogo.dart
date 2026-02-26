import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class Criarjogo extends StatefulWidget {
  const Criarjogo({super.key});

  @override
  State<Criarjogo> createState() => _CriarjogoState();
}

class _CriarjogoState extends State<Criarjogo> {
  final _nomeController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _totalJogadoresController = TextEditingController();
  final _dataController = TextEditingController();

// addsona o id do user que ta criando tbm, o data temque ser time timestamp, 



  final _formKey = GlobalKey<FormState>();
  final _isLoading = false;
  @override
  void dispose() {
    _nomeController.dispose();
    _localizacaoController.dispose();
    _totalJogadoresController.dispose();
    _dataController.dispose();

    super.dispose();
  }

  @override


Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text("Criar Jogo ⚽")),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [

            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: "Nome do Jogo",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? "Informe o nome" : null,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _localizacaoController,
              decoration: const InputDecoration(
                labelText: "Localização",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? "Informe a localização" : null,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _totalJogadoresController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Limite de jogadores",
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? "Informe o limite" : null,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _dataController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Data e Hora",
                border: OutlineInputBorder(),
              ),
              onTap: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );

                if (date != null) {
                  TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (time != null) {
                    final dateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );

                    _dataController.text = dateTime.toString();
                  }
                }
              },
              validator: (value) =>
                  value == null || value.isEmpty ? "Selecione data e hora" : null,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final user =
                      Supabase.instance.client.auth.currentUser;

                  await Supabase.instance.client
                      .from('jogos')
                      .insert({
                    'nome': _nomeController.text,
                    'localizacao': _localizacaoController.text,
                    'limite_jogadores':
                        int.parse(_totalJogadoresController.text),
                    'horario': DateTime.parse(_dataController.text).toIso8601String(),
                    'criador': user!.id,
                  });

                  Navigator.pop(context);
                },
                child: const Text("Criar Jogo"),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  }
