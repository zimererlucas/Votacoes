import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/eleicao.dart';
import '../models/candidato.dart';
import '../models/direito_voto.dart';
import '../models/token.dart';

final eleicoesProvider = FutureProvider<List<Eleicao>>((ref) async {
  final response = await Supabase.instance.client
      .from('eleicoes')
      .select('*')
      .order('criado_em', ascending: false);

  return (response as List).map((json) => Eleicao.fromJson(json)).toList();
});

final eleicaoProvider = FutureProvider.family<Eleicao?, String>((
  ref,
  id,
) async {
  final response =
      await Supabase.instance.client
          .from('eleicoes')
          .select('*')
          .eq('id', id)
          .single();

  return Eleicao.fromJson(response);
});

final candidatosProvider = FutureProvider.family<List<Candidato>, String>((
  ref,
  eleicaoId,
) async {
  final response = await Supabase.instance.client
      .from('candidatos')
      .select('*')
      .eq('eleicao_id', eleicaoId)
      .order('nome_completo');

  return (response as List).map((json) => Candidato.fromJson(json)).toList();
});

final direitoVotoProvider = FutureProvider.family<DireitoVoto?, String>((
  ref,
  eleicaoId,
) async {
  final user = ref.watch(authProvider).value;
  if (user == null) return null;

  final response =
      await Supabase.instance.client
          .from('direito_voto')
          .select('*')
          .eq('usuario_id', user.id)
          .eq('eleicao_id', eleicaoId)
          .maybeSingle();

  return response != null ? DireitoVoto.fromJson(response) : null;
});

final tokensProvider = FutureProvider.family<List<Token>, String>((
  ref,
  eleicaoId,
) async {
  final response = await Supabase.instance.client
      .from('tokens')
      .select('*')
      .eq('eleicao_id', eleicaoId)
      .order('criado_em', ascending: false);

  return (response as List).map((json) => Token.fromJson(json)).toList();
});

final authProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});
