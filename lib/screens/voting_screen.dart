import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';
import '../models/candidate.dart';

class VotingScreen extends StatefulWidget {
  final VoidCallback onVoted;

  const VotingScreen({super.key, required this.onVoted});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  Candidate? _selectedCandidate;

  Future<void> _submitVote() async {
    if (_selectedCandidate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um candidato')),
      );
      return;
    }

    final votingProvider = Provider.of<VotingProvider>(context, listen: false);
    final success = await votingProvider.recordVote(_selectedCandidate!);

    if (success && mounted) {
      widget.onVoted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, child) {
        final voter = votingProvider.currentVoter;
        if (voter == null) {
          return const Center(child: Text('Erro: Nenhum eleitor autenticado'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bem-vindo, ${voter.name}!',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecione seu candidato para Presidente do Centro Acadêmico:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: votingProvider.candidates.length,
                  itemBuilder: (context, index) {
                    final candidate = votingProvider.candidates[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: RadioListTile<Candidate>(
                        title: Text(
                          candidate.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(candidate.description),
                        value: candidate,
                        groupValue: _selectedCandidate,
                        onChanged: (value) {
                          setState(() {
                            _selectedCandidate = value;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (votingProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitVote,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Confirmar Voto'),
                  ),
                ),
              if (votingProvider.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  votingProvider.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
