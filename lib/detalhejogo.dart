import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:futjogo/jogo.dart';
import 'package:intl/intl.dart';

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

    jaEstaNoJogo = lista.any((item) => item['usuario_id'] == user!.id);

    if (mounted) {
      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> entrarNoJogo() async {
    final user = _supabase.auth.currentUser;

    if (jogadores.length >= widget.jogo.limiteJogadores) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jogo já está lotado ⚠️")),
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
        backgroundColor: Color(0xFF0A2A12),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final horarioFormatado = DateFormat('dd/MM/yyyy - HH:mm').format(widget.jogo.horario);

    return Scaffold(
      backgroundColor: const Color(0xFF0A2A12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.jogo.nome, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Card de Informações do Jogo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 8),
                      Text("Local: ${widget.jogo.localizacao}", 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: Colors.green),
                      const SizedBox(width: 8),
                      Text("Horário: $horarioFormatado", 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.groups, color: Colors.green),
                      const SizedBox(width: 8),
                      Text("Confirmados: ${jogadores.length}/${widget.jogo.limiteJogadores}", 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lista de Jogadores
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      "LISTA DE CONFIRMADOS",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: jogadores.isEmpty
                        ? const Center(child: Text("Ninguém confirmou ainda 😢"))
                        : ListView.builder(
                            itemCount: jogadores.length,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Color(0xFFF0F0F0),
                                  child: Icon(Icons.person, color: Colors.green),
                                ),
                                title: Text(jogadores[index], 
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                                trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                              );
                            },
                          ),
                  ),
                  
                  // Botão de Ação
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: jaEstaNoJogo ? sairDoJogo : entrarNoJogo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: jaEstaNoJogo ? Colors.redAccent : const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: Text(
                          jaEstaNoJogo ? "SAIR DA PARTIDA" : "CONFIRMAR PRESENÇA",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}