import 'package:flutter/material.dart';
import 'package:futjogo/criarjogo.dart';
import 'package:futjogo/detalhejogo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:futjogo/jogo.dart';
import 'package:intl/intl.dart';

class Telajogos extends StatefulWidget {
  const Telajogos({super.key});

  @override
  State<Telajogos> createState() => _TelajogosState();
}

class _TelajogosState extends State<Telajogos> {
  final _supabase = Supabase.instance.client;
  List<Jogo> jogos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarJogos();
  }

  Future<void> carregarJogos() async {
    final data = await _supabase.from('jogos').select().order('horario', ascending: true);

    setState(() {
      jogos = (data as List).map((item) => Jogo.fromMap(item)).toList();
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mantendo o padrão Verde Escuro
      backgroundColor: const Color(0xFF0A2A12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Jogos Disponíveis',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      
      // Botão Flutuante Estilizado (Verde Vibrante)
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1DB954),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Criarjogo()),
          ).then((_) => carregarJogos()); // Recarrega ao voltar
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Partidas Abertas",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: jogos.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhum jogo encontrado ⚽",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: jogos.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemBuilder: (context, index) {
                            final jogo = jogos[index];
                            final horarioFormatado = DateFormat('dd/MM - HH:mm').format(jogo.horario);

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Detalhejogo(jogo: jogo),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.withOpacity(0.1),
                                  child: const Icon(Icons.event_available, color: Color(0xFF1DB954)),
                                ),
                                title: Text(
                                  jogo.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(jogo.localizacao),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time_filled, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(horarioFormatado),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}