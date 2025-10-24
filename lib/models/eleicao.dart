class Eleicao {
  final String id;
  final String titulo;
  final String? descricao;
  final DateTime dataComeco;
  final DateTime dataFim;
  final String criadoPor;
  final DateTime criadoEm;

  Eleicao({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.dataComeco,
    required this.dataFim,
    required this.criadoPor,
    required this.criadoEm,
  });

  factory Eleicao.fromJson(Map<String, dynamic> json) {
    return Eleicao(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      dataComeco: DateTime.parse(json['data_comeco']),
      dataFim: DateTime.parse(json['data_fim']),
      criadoPor: json['criado_por'],
      criadoEm: DateTime.parse(json['criado_em']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'data_comeco': dataComeco.toIso8601String(),
      'data_fim': dataFim.toIso8601String(),
      'criado_por': criadoPor,
      'criado_em': criadoEm.toIso8601String(),
    };
  }
}
