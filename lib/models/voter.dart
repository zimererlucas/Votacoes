class Voter {
  final String id;
  final String name;

  Voter({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Voter && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
