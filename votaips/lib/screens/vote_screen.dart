import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/poll.dart';
import '../providers/auth_provider.dart';

class VoteScreen extends ConsumerStatefulWidget {
  final Poll poll;

  const VoteScreen({super.key, required this.poll});

  @override
  ConsumerState<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends ConsumerState<VoteScreen> {
  String? _selectedOption;
  bool _isVoting = false;

  Future<void> _submitVote() async {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma opção')),
      );
      return;
    }

    final user = ref.read(authProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilizador não autenticado')),
      );
      return;
    }

    setState(() => _isVoting = true);

    try {
      await Supabase.instance.client.from('votes').insert({
        'user_id': user.id,
        'poll_id': widget.poll.id,
        'option': _selectedOption,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voto registado com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao registar voto: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isVoting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Votar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.poll.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              widget.poll.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Text(
              'Selecione uma opção:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: widget.poll.options.length,
                itemBuilder: (context, index) {
                  final option = widget.poll.options[index];
                  return RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() => _selectedOption = value);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVoting ? null : _submitVote,
                child:
                    _isVoting
                        ? const CircularProgressIndicator()
                        : const Text('Confirmar Voto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
