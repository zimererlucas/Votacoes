import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';

class ConfirmationScreen extends StatelessWidget {
  final VoidCallback onNewVote;

  const ConfirmationScreen({super.key, required this.onNewVote});

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, child) {
        final voter = votingProvider.currentVoter;
        final lastVote =
            votingProvider.votes.isNotEmpty ? votingProvider.votes.last : null;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Voto Registrado com Sucesso!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (voter != null) ...[
                Text(
                  'Eleitor: ${voter.name}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
              ],
              if (lastVote != null) ...[
                Text(
                  'Candidato: ${lastVote.candidate.name}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Horário: ${lastVote.timestamp.toString()}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 32),
              const Text(
                'Obrigado por participar da votação!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                child: const Text('Novo Voto'),
                onPressed: () {
                  votingProvider.logout();
                  onNewVote();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
