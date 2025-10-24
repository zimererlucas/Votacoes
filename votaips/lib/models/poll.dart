import 'eleicao.dart';

class Poll {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> options;
  final String createdBy;
  final DateTime createdAt;
  bool hasVoted;

  Poll({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.options,
    required this.createdBy,
    required this.createdAt,
    this.hasVoted = false,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      options: List<String>.from(json['options']),
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'options': options,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Poll.fromEleicao(Eleicao eleicao) {
    return Poll(
      id: eleicao.id,
      title: eleicao.titulo,
      description: eleicao.descricao ?? '',
      startDate: eleicao.dataComeco,
      endDate: eleicao.dataFim,
      options:
          [], // Assuming options are not in Eleicao, or need to fetch separately
      createdBy: eleicao.criadoPor,
      createdAt: eleicao.criadoEm,
    );
  }
}
