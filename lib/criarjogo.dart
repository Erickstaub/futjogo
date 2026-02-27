import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _localizacaoController.dispose();
    _totalJogadoresController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _salvarJogo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      // 1. Criar o jogo e retornar o ID
      final novoJogo = await supabase
          .from('jogos')
          .insert({
            'nome': _nomeController.text,
            'localizacao': _localizacaoController.text,
            'limite_jogadores': int.parse(_totalJogadoresController.text),
            'horario': DateTime.parse(_dataController.text).toIso8601String(),
            'criador': user.id,
          })
          .select()
          .single();

      final jogoId = novoJogo['id'];

      // 2. Inserir o criador automaticamente como jogador
      await supabase.from('jogadores_jogo').insert({
        'jogo_id': jogoId,
        'usuario_id': user.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Jogo criado com sucesso! ⚽"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao criar jogo: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2A12), // Verde escuro padrão
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Novo Jogo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.add_location_alt_rounded, size: 60, color: Colors.white),
              const SizedBox(height: 20),
              
              // Container Branco (Modal)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Detalhes da Partida",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0A2A12)),
                      ),
                      const SizedBox(height: 20),
                      
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: "Nome do Jogo (Ex: Fut dos Amigos)",
                          prefixIcon: const Icon(Icons.sports_soccer),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Informe o nome" : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _localizacaoController,
                        decoration: InputDecoration(
                          labelText: "Localização",
                          prefixIcon: const Icon(Icons.map_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Informe a localização" : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _totalJogadoresController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Limite de Jogadores",
                          prefixIcon: const Icon(Icons.people_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? "Informe o limite" : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _dataController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Data e Hora",
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            initialDate: DateTime.now(),
                          );

                          if (date != null && mounted) {
                            TimeOfDay? time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );

                            if (time != null) {
                              final dateTime = DateTime(
                                date.year, date.month, date.day,
                                time.hour, time.minute,
                              );
                              _dataController.text = dateTime.toString();
                            }
                          }
                        },
                        validator: (value) => value == null || value.isEmpty ? "Selecione data e hora" : null,
                      ),
                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _salvarJogo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB954),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("CRIAR JOGO AGORA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}