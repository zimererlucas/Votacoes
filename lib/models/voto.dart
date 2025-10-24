class Voto {
  final String id;
  final String eleicaoId;
  final String candidatoId;
  final String token;
  final DateTime timestamp;

  Voto({
    required this.id,
    required this.eleicaoId,
    required this.candidatoId,
    required this.token,
    required this.timestamp,
  });

  factory Voto.fromJson(Map<String, dynamic> json) {
    return Voto(
      id: json['id'],
      eleicaoId: json['eleicao_id'],
      candidatoId: json['candidato_id'],
      token: json['token'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eleicao_id': eleicaoId,
      'candidato_id': candidatoId,
      'token': token,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
