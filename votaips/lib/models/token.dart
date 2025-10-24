class Token {
  final String id;
  final String eleicaoId;
  final String token;
  final bool usado;
  final DateTime criadoEm;

  Token({
    required this.id,
    required this.eleicaoId,
    required this.token,
    required this.usado,
    required this.criadoEm,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: json['id'],
      eleicaoId: json['eleicao_id'],
      token: json['token'],
      usado: json['usado'] ?? false,
      criadoEm: DateTime.parse(json['criado_em']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eleicao_id': eleicaoId,
      'token': token,
      'usado': usado,
      'criado_em': criadoEm.toIso8601String(),
    };
  }
}
