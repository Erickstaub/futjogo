import 'package:flutter/material.dart';
import 'package:futjogo/compartilhar.dart';
import 'package:futjogo/jogo.dart';
import 'package:futjogo/login.dart';
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
  Future<void> abrirNotificacoes() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return;

  final data = await _supabase
      .from('convites')
      .select('*, jogos(nome, localizacao, horario)')
      .eq('destinatario', user.id)
      .eq('status', 'pendente');

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
              "Minhas Notificações",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Expanded(
              child: data.isEmpty
                  ? const Center(child: Text("Nenhum convite pendente ⚽"))
                  : ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final convite = data[index];
                        final jogo = convite['jogos'];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            title: Text(jogo['nome'] ?? ''),
                            subtitle:
                                Text(jogo['localizacao'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () async {
                                    await aceitarConvite(convite);
                                    Navigator.pop(context);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await recusarConvite(convite['id']);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
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
Future<void> aceitarConvite(Map<String, dynamic> convite) async {
  final user = _supabase.auth.currentUser;

  // 1️⃣ adiciona no jogo
  await _supabase.from('jogadores_jogo').insert({
    'jogo_id': convite['jogo_id'],
    'usuario_id': user!.id,
  });

  // 2️⃣ atualiza status
  await _supabase
      .from('convites')
      .update({'status': 'aceito'})
      .eq('id', convite['id']);

  carregarJogos();
}
Future<void> recusarConvite(String conviteId) async {
  await _supabase
      .from('convites')
      .update({'status': 'recusado'})
      .eq('id', conviteId);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo verde escuro para combinar com o Login
      backgroundColor: const Color(0xFF0A2A12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "FUTJOGO ⚽",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await _supabase.auth.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              }
            },
          ),
                   IconButton(
            icon: const Icon(Icons.refresh, color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () async {
              carregarJogos();
            },
          ),
          IconButton(
  icon: const Icon(Icons.notifications, color: Colors.white),
  onPressed: () {
    abrirNotificacoes();
  },
),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Minhas Partidas",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: jogos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sports_soccer, size: 80, color: Colors.white.withOpacity(0.3)),
                              const SizedBox(height: 10),
                              const Text(
                                "Você não está em nenhum jogo",
                                style: TextStyle(color: Colors.white70, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: jogos.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final jogo = jogos[index];
                            final horario = jogo['horario'] != null
                                ? DateFormat('dd/MM HH:mm').format(DateTime.parse(jogo['horario']))
                                : 'Sem horário';

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Compartilhar(jogo: Jogo.fromMap(jogo)),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF1DB954).withOpacity(0.2),
                                  child: const Icon(Icons.sports_soccer, color: Color(0xFF1DB954)),
                                ),
                                title: Text(
                                  jogo['nome'] ?? 'Partida sem nome',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(jogo['localizacao'] ?? 'Local não definido'),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(horario),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                ),
                
                // Botão inferior estilizado
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Telajogos()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1DB954),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "BUSCAR JOGOS DISPONÍVEIS",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}