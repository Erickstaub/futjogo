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

Future<void> abrirModalConvites() async {
  final currentUser = _supabase.auth.currentUser;

  // 🔹 Todos usuários menos eu
  final usuarios = await _supabase
      .from('profiles')
      .select()
      .neq('id', currentUser!.id);

  // 🔹 Buscar quem já está no jogo
  final jogadoresData = await _supabase
      .from('jogadores_jogo')
      .select('usuario_id')
      .eq('jogo_id', widget.jogo.id);

  final jogadoresIds =
      (jogadoresData as List).map((e) => e['usuario_id']).toSet();

  // 🔹 Buscar convites pendentes desse jogo
  final convitesData = await _supabase
      .from('convites')
      .select('destinatario')
      .eq('jogo_id', widget.jogo.id)
      .eq('status', 'pendente');

  final convidadosIds =
      (convitesData as List).map((e) => e['destinatario']).toSet();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 15),
            const Text(
              "Convidar Jogadores",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: usuarios.length,
                itemBuilder: (context, index) {
                  final user = usuarios[index];
                  final userId = user['id'];

                  final jaEstaNoJogo = jogadoresIds.contains(userId);
                  final jaConvidado = convidadosIds.contains(userId);

                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(user['nome']),
                    trailing: jaEstaNoJogo
                        ? const Text(
                            "Já está no jogo",
                            style: TextStyle(color: Colors.grey),
                          )
                        : jaConvidado
                            ? const Text(
                                "Convite enviado",
                                style: TextStyle(color: Colors.orange),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  await enviarConvite(userId);
                                  Navigator.pop(context);
                                },
                                child: const Text("Convidar"),
                              ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
Future<void> enviarConvite(String destinatarioId) async {
  final user = _supabase.auth.currentUser;

  await _supabase.from('convites').insert({
    'jogo_id': widget.jogo.id,
    'remetente': user!.id,
    'destinatario': destinatarioId,
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Convite enviado ⚽")),
  );
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
                        onPressed: () async{
      abrirModalConvites();
    },
                        icon: const Icon(Icons.share),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        label: const Text(
                          "COMPARTILHAR",
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