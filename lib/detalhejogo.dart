import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:futjogo/jogo.dart';

class Detalhejogo extends StatefulWidget {
  final Jogo jogo;

  const Detalhejogo({
    super.key,
    required this.jogo,
  });

  @override
  State<Detalhejogo> createState() => _DetalhejogoState();
}

class _DetalhejogoState extends State<Detalhejogo> {
  final _supabase = Supabase.instance.client;

  List<String> jogadores = [];
  bool jaEstaNoJogo = false;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarJogadores();
  }

  Future<void> carregarJogadores() async {
    final user = _supabase.auth.currentUser;

    final data = await _supabase
        .from('jogadores_jogo')
        .select('usuario_id, profiles(nome)')
        .eq('jogo_id', widget.jogo.id);

    final lista = data as List;

    jogadores = lista
        .map((item) => item['profiles']['nome'] as String)
        .toList();

    jaEstaNoJogo =
        lista.any((item) => item['usuario_id'] == user!.id);

    setState(() {
      carregando = false;
    });
  }

  Future<void> entrarNoJogo() async {
    final user = _supabase.auth.currentUser;

    // 🔴 Regra 1: não pode estar cheio
    if (jogadores.length >= widget.jogo.limiteJogadores) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jogo já está lotado ⚠️")),
      );
      return;
    }

    // 🔴 Regra 2: não pode entrar duas vezes
    if (jaEstaNoJogo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Você já está nesse jogo ⚽")),
      );
      return;
    }

    await _supabase.from('jogadores_jogo').insert({
      'jogo_id': widget.jogo.id,
      'usuario_id': user!.id,
    });

    await carregarJogadores();
  }

  Future<void> sairDoJogo() async {
    final user = _supabase.auth.currentUser;

    await _supabase
        .from('jogadores_jogo')
        .delete()
        .eq('jogo_id', widget.jogo.id)
        .eq('usuario_id', user!.id);

    await carregarJogadores();
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jogo.nome),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 Local: ${widget.jogo.localizacao}"),
            const SizedBox(height: 8),
            Text("🕒 Horário: ${widget.jogo.horario}"),
            const SizedBox(height: 8),
            Text(
                "👥 ${jogadores.length}/${widget.jogo.limiteJogadores} jogadores"),
            const SizedBox(height: 20),

            const Text(
              "Jogadores confirmados:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: jogadores.isEmpty
                  ? const Text("Ninguém confirmou ainda 😢")
                  : ListView.builder(
                      itemCount: jogadores.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(jogadores[index]),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: jaEstaNoJogo ? sairDoJogo : entrarNoJogo,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      jaEstaNoJogo ? Colors.red : Colors.green,
                ),
                child: Text(
                  jaEstaNoJogo ? "Sair do jogo" : "Entrar no jogo",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}