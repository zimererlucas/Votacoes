import 'package:flutter/material.dart';
import '../models/voter.dart';
import '../models/candidate.dart';
import '../models/vote.dart';

class VotingProvider with ChangeNotifier {
  // Hardcoded valid voter IDs (in a real app, this would come from a database)
  final Set<String> _validVoterIds = {
    '1234567890', // Example NFC IDs
    '0987654321',
    '1111111111',
    '2222222222',
  };

  // Hardcoded candidates
  final List<Candidate> _candidates = [
    Candidate(
      id: '1',
      name: 'João Silva',
      description: 'Candidato para Presidente do Centro Acadêmico',
    ),
    Candidate(
      id: '2',
      name: 'Maria Santos',
      description: 'Candidata para Presidente do Centro Acadêmico',
    ),
    Candidate(
      id: '3',
      name: 'Pedro Oliveira',
      description: 'Candidato para Presidente do Centro Acadêmico',
    ),
  ];

  // Recorded votes
  final Set<Vote> _votes = {};

  // Current authenticated voter
  Voter? _currentVoter;

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Candidate> get candidates => _candidates;
  Set<Vote> get votes => _votes;
  Voter? get currentVoter => _currentVoter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check if voter has already voted
  bool hasVoted(Voter voter) {
    return _votes.any((vote) => vote.voter == voter);
  }

  // Authenticate voter via NFC ID
  Future<bool> authenticateVoter(String nfcId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulate processing

    if (_validVoterIds.contains(nfcId)) {
      _currentVoter = Voter(
        id: nfcId,
        name: 'Estudante $nfcId',
      ); // In real app, fetch from DB
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'ID NFC inválido. Você não está autorizado a votar.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Record a vote
  Future<bool> recordVote(Candidate candidate) async {
    if (_currentVoter == null) {
      _errorMessage = 'Nenhum eleitor autenticado.';
      notifyListeners();
      return false;
    }

    if (hasVoted(_currentVoter!)) {
      _errorMessage = 'Você já votou.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simulate processing

    final vote = Vote(
      voter: _currentVoter!,
      candidate: candidate,
      timestamp: DateTime.now(),
    );

    _votes.add(vote);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Logout current voter
  void logout() {
    _currentVoter = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
