class Jogo {
  final String id;
  final String nome;
  final String localizacao;
  final DateTime horario;
  final int limiteJogadores;

  Jogo({
    required this.id,
    required this.nome,
    required this.localizacao,
    required this.horario,
    required this.limiteJogadores,
  });

  factory Jogo.fromMap(Map<String, dynamic> map) {
    return Jogo(
      id: map['id'],
      nome: map['nome'] ?? '',
      localizacao: map['localizacao'] ?? '',
      horario: DateTime.parse(map['horario']),
      limiteJogadores: map['limite_jogadores'] ?? 0,
    );
  }
}