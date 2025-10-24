import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/results_screen.dart';
import 'screens/admin/create_poll_screen.dart';
import 'models/eleicao.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:
        'https://kyfsvxkuihntaswvnmxl.supabase.co', // Replace with your Supabase URL
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5ZnN2eGt1aWhudGFzd3ZubXhsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEyOTYxNDYsImV4cCI6MjA3Njg3MjE0Nn0.xgUVzy-vckRViI_8LsJ7njzEKWykV3V075K1EFdwjBI', // Replace with your Supabase anon key
  );

  runApp(const ProviderScope(child: VotaIPSApp()));
}

class VotaIPSApp extends ConsumerWidget {
  const VotaIPSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'VotaIPS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0056A0), // IPS Blue
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: authState.when(
        data:
            (user) =>
                user != null ? const HomeScreen() : const _TestModeScreen(),
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error:
            (error, stack) =>
                Scaffold(body: Center(child: Text('Error: $error'))),
      ),
    );
  }
}

class _TestModeScreen extends StatelessWidget {
  const _TestModeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VotaIPS - Modo Teste'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.how_to_vote,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Modo Teste',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Escolha uma opção para testar a aplicação:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                child: const Text('Fazer Login'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text('Entrar sem Login (Teste)'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Test admin login - simulate admin user for testing
                  // Navigate directly to home screen with admin privileges
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const _TestAdminHomeScreen(),
                    ),
                  );
                },
                child: const Text('Login de Admin (Teste)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestAdminHomeScreen extends ConsumerStatefulWidget {
  const _TestAdminHomeScreen();

  @override
  ConsumerState<_TestAdminHomeScreen> createState() =>
      _TestAdminHomeScreenState();
}

class _TestAdminHomeScreenState extends ConsumerState<_TestAdminHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VotaIPS (Admin Teste)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Ativas'), Tab(text: 'Encerradas')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EleicoesList(isActive: true),
          _EleicoesList(isActive: false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePollScreen(testMode: true),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EleicoesList extends ConsumerWidget {
  final bool isActive;

  const _EleicoesList({required this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Eleicao>>(
      future: _fetchEleicoes(isActive),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        final eleicoes = snapshot.data ?? [];

        if (eleicoes.isEmpty) {
          return Center(
            child: Text(
              isActive ? 'Nenhuma eleição ativa' : 'Nenhuma eleição encerrada',
            ),
          );
        }

        return ListView.builder(
          itemCount: eleicoes.length,
          itemBuilder: (context, index) {
            final eleicao = eleicoes[index];
            return EleicaoCard(eleicao: eleicao, isActive: isActive);
          },
        );
      },
    );
  }

  Future<List<Eleicao>> _fetchEleicoes(bool isActive) async {
    final now = DateTime.now().toUtc();
    final query = Supabase.instance.client.from('eleicoes').select('*');

    if (isActive) {
      query
          .lte('data_comeco', now.toIso8601String())
          .gte('data_fim', now.toIso8601String());
    } else {
      query.lt('data_fim', now.toIso8601String());
    }

    final response = await query;
    final eleicoes =
        (response as List<dynamic>)
            .map((json) => Eleicao.fromJson(json as Map<String, dynamic>))
            .toList();

    return eleicoes;
  }
}

class EleicaoCard extends ConsumerWidget {
  final Eleicao eleicao;
  final bool isActive;

  const EleicaoCard({super.key, required this.eleicao, required this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(eleicao.titulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (eleicao.descricao != null)
              Text(
                eleicao.descricao!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),
            Text(
              'Encerra em: ${eleicao.dataFim.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement ManageCandidatosScreen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidade em desenvolvimento'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Candidatos'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement ManageTokensScreen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcionalidade em desenvolvimento'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.token),
                  label: const Text('Tokens'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultsScreen(pollId: eleicao.id),
                      ),
                    );
                  },
                  child: const Text('Resultados'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
