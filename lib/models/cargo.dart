class Cargo {
  final String id;
  final String nome;

  Cargo({required this.id, required this.nome});

  factory Cargo.fromJson(Map<String, dynamic> json) {
    return Cargo(id: json['id'], nome: json['nome']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nome': nome};
  }
}
