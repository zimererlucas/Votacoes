import 'voter.dart';
import 'candidate.dart';

class Vote {
  final Voter voter;
  final Candidate candidate;
  final DateTime timestamp;

  Vote({required this.voter, required this.candidate, required this.timestamp});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vote &&
          runtimeType == other.runtimeType &&
          voter == other.voter &&
          candidate == other.candidate;

  @override
  int get hashCode => voter.hashCode ^ candidate.hashCode;
}
