import 'package:flutter/material.dart';
import 'package:futjogo/telajogos.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> jogos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarJogos();
  }

  Future<void> carregarJogos() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = await _supabase
        .from('jogadores_jogo')
        .select('jogos(*)')
        .eq('usuario_id', user.id);

    setState(() {
      jogos = (data as List)
          .map((item) => item['jogos'] as Map<String, dynamic>)
          .toList();
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FUTJOGO ⚽"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await _supabase.auth.signOut();
            },
          ),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: jogos.isEmpty
                      ? const Center(
                          child: Text("Você não está em nenhum jogo 😢"),
                        )
                      : ListView.builder(
                          itemCount: jogos.length,
                          itemBuilder: (context, index) {
                            final jogo = jogos[index];
                            final horario = jogo['horario'] != null
                                ? DateFormat('dd/MM/yyyy HH:mm')
                                    .format(DateTime.parse(jogo['horario']))
                                : 'Sem horário';
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(jogo['nome'] ?? ''),
                                subtitle:
                                    Text("${jogo['localizacao'] ?? ''} • $horario"),
                                leading: const Icon(Icons.sports_soccer),
                                onTap: () {
                                  // Se quiser abrir detalhes do jogo
                                  // Navigator.push(...Detalhejogo)
                                },
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Telajogos(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("JOGOS DISPONÍVEIS"),
                  ),
                ),
              ],
            ),
    );
  }
}