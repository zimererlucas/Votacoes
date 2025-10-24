class Candidato {
  final String id;
  final String eleicaoId;
  final String nomeCompleto;
  final String? partido;
  final DateTime criadoEm;

  Candidato({
    required this.id,
    required this.eleicaoId,
    required this.nomeCompleto,
    this.partido,
    required this.criadoEm,
  });

  factory Candidato.fromJson(Map<String, dynamic> json) {
    return Candidato(
      id: json['id'],
      eleicaoId: json['eleicao_id'],
      nomeCompleto: json['nome_completo'],
      partido: json['partido'],
      criadoEm: DateTime.parse(json['criado_em']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eleicao_id': eleicaoId,
      'nome_completo': nomeCompleto,
      'partido': partido,
      'criado_em': criadoEm.toIso8601String(),
    };
  }
}
