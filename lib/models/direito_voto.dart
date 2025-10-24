class DireitoVoto {
  final String id;
  final String usuarioId;
  final String eleicaoId;
  final bool jaRecebeuToken;

  DireitoVoto({
    required this.id,
    required this.usuarioId,
    required this.eleicaoId,
    required this.jaRecebeuToken,
  });

  factory DireitoVoto.fromJson(Map<String, dynamic> json) {
    return DireitoVoto(
      id: json['id'],
      usuarioId: json['usuario_id'],
      eleicaoId: json['eleicao_id'],
      jaRecebeuToken: json['ja_recebeu_token'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'eleicao_id': eleicaoId,
      'ja_recebeu_token': jaRecebeuToken,
    };
  }
}
