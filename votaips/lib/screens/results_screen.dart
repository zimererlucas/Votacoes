import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResultsScreen extends StatefulWidget {
  final String pollId;

  const ResultsScreen({super.key, required this.pollId});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Map<String, int> _results = {};
  String _pollTitle = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      // Fetch poll details
      final pollResponse =
          await Supabase.instance.client
              .from('polls')
              .select('title, options')
              .eq('id', widget.pollId)
              .single();

      _pollTitle = pollResponse['title'];

      // Fetch vote counts
      final votesResponse = await Supabase.instance.client
          .from('votes')
          .select('option')
          .eq('poll_id', widget.pollId);

      final votes = votesResponse as List;
      final results = <String, int>{};

      for (final option in pollResponse['options'] as List) {
        results[option] = 0;
      }

      for (final vote in votes) {
        final option = vote['option'] as String;
        results[option] = (results[option] ?? 0) + 1;
      }

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar resultados: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pollTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child:
                          _results.isEmpty
                              ? const Center(
                                child: Text('Nenhum voto registado'),
                              )
                              : Column(
                                children: [
                                  Expanded(
                                    child: BarChart(
                                      BarChartData(
                                        alignment:
                                            BarChartAlignment.spaceAround,
                                        maxY:
                                            _results.values.isEmpty
                                                ? 0
                                                : _results.values
                                                    .reduce(
                                                      (a, b) => a > b ? a : b,
                                                    )
                                                    .toDouble(),
                                        barGroups:
                                            _results.entries.map((entry) {
                                              return BarChartGroupData(
                                                x: _results.keys
                                                    .toList()
                                                    .indexOf(entry.key),
                                                barRods: [
                                                  BarChartRodData(
                                                    toY: entry.value.toDouble(),
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).primaryColor,
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                        titlesData: FlTitlesData(
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                final index = value.toInt();
                                                if (index >= 0 &&
                                                    index <
                                                        _results.keys.length) {
                                                  return Text(
                                                    _results.keys.elementAt(
                                                      index,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                            ),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: false,
                                            ),
                                          ),
                                        ),
                                        gridData: FlGridData(show: false),
                                        borderData: FlBorderData(show: false),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _results.length,
                                      itemBuilder: (context, index) {
                                        final entry = _results.entries
                                            .elementAt(index);
                                        return ListTile(
                                          title: Text(entry.key),
                                          trailing: Text(
                                            '${entry.value} votos',
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ],
                ),
              ),
    );
  }
}
