import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart' as auth_provider;
import '../providers/eleicao_provider.dart';
import '../models/eleicao.dart';

import '../models/poll.dart';
import 'vote_screen.dart';
import 'results_screen.dart';
import 'admin/create_poll_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
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
    final userRole = ref.watch(auth_provider.userRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VotaIPS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
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
      floatingActionButton: userRole.when(
        data:
            (role) =>
                role == 'administrador'
                    ? FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreatePollScreen(),
                          ),
                        );
                      },
                      child: const Icon(Icons.add),
                    )
                    : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}

class _EleicoesList extends ConsumerWidget {
  final bool isActive;

  const _EleicoesList({required this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    if (user == null) {
      return const Center(child: Text('Utilizador não autenticado'));
    }

    return FutureBuilder<List<Eleicao>>(
      future: _fetchEleicoes(user.id, isActive),
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

  Future<List<Eleicao>> _fetchEleicoes(String userId, bool isActive) async {
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
        (response as List).map((json) => Eleicao.fromJson(json)).toList();

    return eleicoes;
  }
}

class EleicaoCard extends ConsumerWidget {
  final Eleicao eleicao;
  final bool isActive;

  const EleicaoCard({super.key, required this.eleicao, required this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(auth_provider.userRoleProvider);
    final direitoVotoAsync = ref.watch(direitoVotoProvider(eleicao.id));

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
            direitoVotoAsync.when(
              data: (direitoVoto) {
                if (userRole.value == 'administrador') {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement ManageCandidatosScreen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Funcionalidade em desenvolvimento',
                              ),
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
                              content: Text(
                                'Funcionalidade em desenvolvimento',
                              ),
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
                  );
                } else if (direitoVoto != null) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (direitoVoto.jaRecebeuToken) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => VoteScreen(
                                      poll: Poll.fromEleicao(eleicao),
                                    ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Você ainda não recebeu um token para votar nesta eleição',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Votar'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => VoteScreen(
                                    poll: Poll.fromEleicao(eleicao),
                                  ),
                            ),
                          );
                        },
                        child: const Text('Votar sem NFC'),
                      ),
                    ],
                  );
                } else {
                  return const Text(
                    'Você não tem direito de voto nesta eleição',
                    style: TextStyle(color: Colors.grey),
                  );
                }
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Erro: $error'),
            ),
          ],
        ),
      ),
    );
  }
}
