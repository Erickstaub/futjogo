import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:futjogo/jogo.dart';
import 'package:intl/intl.dart';

class Compartilhar extends StatefulWidget {
  final Jogo jogo;

  const Compartilhar({
    super.key,
    required this.jogo,
  });

  @override
  State<Compartilhar> createState() => _CompartilharState();
}

class _CompartilharState extends State<Compartilhar> {
  final _supabase = Supabase.instance.client;

  List<String> jogadores = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarJogadores();
  }

  Future<void> carregarJogadores() async {
    final data = await _supabase
        .from('jogadores_jogo')
        .select('profiles(nome)')
        .eq('jogo_id', widget.jogo.id);

    final lista = data as List;

    setState(() {
      jogadores = lista
          .map((item) => item['profiles']['nome'] as String)
          .toList();
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A2A12),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final horario = DateFormat('dd/MM/yyyy HH:mm').format(widget.jogo.horario);

    return Scaffold(
      backgroundColor: const Color(0xFF0A2A12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Compartilhar Jogo", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Card de resumo do jogo
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
                  Text(widget.jogo.nome, 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0A2A12))),
                  const Divider(),
                  const SizedBox(height: 5),
                  Text("📍 Local: ${widget.jogo.localizacao}"),
                  Text("🕒 Horário: $horario"),
                  Text("👥 Confirmados: ${jogadores.length}/${widget.jogo.limiteJogadores}"),
                ],
              ),
            ),
          ),

          // Lista de Jogadores (A Prancheta)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      "LISTA DE ESCALAÇÃO",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: jogadores.isEmpty
                        ? const Center(child: Text("Ninguém na lista ainda ⚽"))
                        : ListView.builder(
                            itemCount: jogadores.length,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.withOpacity(0.1),
                                  child: Text("${index + 1}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(jogadores[index], style: const TextStyle(fontWeight: FontWeight.w500)),
                                trailing: const Icon(Icons.person, color: Colors.grey),
                              );
                            },
                          ),
                  ),
                  
                  // Botão de Compartilhar
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Aqui você pode implementar a lógica de copiar para o clipboard ou abrir o share
                          print("Gerando lista para o WhatsApp...");
                        },
                        icon: const Icon(Icons.share),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        label: const Text(
                          "COMPARTILHAR NO WHATSAPP",
                          style: TextStyle(fontWeight: FontWeight.bold),
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