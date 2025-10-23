import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../providers/voting_provider.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isNfcAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  Future<void> _checkNfcAvailability() async {
    _isNfcAvailable = await NfcManager.instance.isAvailable();
    setState(() {});
  }

  Future<void> _startNfcSession() async {
    if (!_isNfcAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NFC não está disponível neste dispositivo'),
        ),
      );
      return;
    }

    final votingProvider = Provider.of<VotingProvider>(context, listen: false);

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        // For demonstration, we'll use a hardcoded ID
        const demoNfcId = '1234567890';

        final success = await votingProvider.authenticateVoter(demoNfcId);
        NfcManager.instance.stopSession();

        if (success && mounted) {
          widget.onAuthenticated();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, votingProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.nfc, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text(
                'Autenticação NFC',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Aproxime seu cartão NFC para se autenticar e votar.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (votingProvider.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _startNfcSession,
                  icon: const Icon(Icons.nfc),
                  label: const Text('Ler Cartão NFC'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
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
              const SizedBox(height: 16),
              if (!_isNfcAvailable)
                const Text(
                  'NFC não suportado neste dispositivo',
                  style: TextStyle(color: Colors.orange),
                ),
            ],
          ),
        );
      },
    );
  }
}
