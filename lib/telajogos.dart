import 'package:flutter/material.dart';
import 'package:futjogo/criarjogo.dart';
import 'package:futjogo/detalhejogo.dart';
import 'package:futjogo/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:futjogo/jogo.dart';


class Telajogos extends StatefulWidget {
  const Telajogos({super.key});

  @override
  State<Telajogos> createState() => _TelajogosState();
}

class _TelajogosState extends State<Telajogos> {
  final _supabase = Supabase.instance.client;

  List<Jogo> jogos = [];

  @override
  void initState() {
    super.initState();
    carregarJogos();
  }

  Future<void> carregarJogos() async {
    final data = await _supabase.from('jogos').select();

    setState(() {
      jogos = (data as List)
          .map((item) => Jogo.fromMap(item))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogos Disponíveis'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Criarjogo()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: jogos.length,
        itemBuilder: (context, index) {
          final jogo = jogos[index];

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Detalhejogo(jogo: jogo),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jogo.nome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text("📍 ${jogo.localizacao}"),
                      const SizedBox(height: 4),
                      Text("🕒 ${jogo.horario}"),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}