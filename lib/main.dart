import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/voting_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/voting_screen.dart';
import 'screens/confirmation_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => VotingProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Votação - Faculdade',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VotingApp(),
    );
  }
}

class VotingApp extends StatefulWidget {
  const VotingApp({super.key});

  @override
  State<VotingApp> createState() => _VotingAppState();
}

class _VotingAppState extends State<VotingApp> {
  int _currentStep = 0; // 0: Auth, 1: Voting, 2: Confirmation

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Votação'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(
        index: _currentStep,
        children: [
          AuthScreen(onAuthenticated: _nextStep),
          VotingScreen(onVoted: _nextStep),
          ConfirmationScreen(onNewVote: _reset),
        ],
      ),
    );
  }
}
