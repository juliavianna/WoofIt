import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/servico.dart';
import '../models/pet.dart';

class ApiService {
  // 10.0.2.2 é o localhost da máquina host dentro do emulador Android
  static const String _base = 'http://10.0.2.2:5000';

  Future<Map<String, dynamic>?> buscarUsuarioPorEmail(String email) async {
    final res = await http.get(Uri.parse('$_base/usuarios/'));
    if (res.statusCode != 200) return null;
    final lista = List<Map<String, dynamic>>.from(jsonDecode(res.body));
    try {
      return lista.firstWhere((u) => u['email'] == email);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String senha) async {
  try {
    final res = await http.post(
      Uri.parse('$_base/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  } catch (_) {
    return null;
  }
}

  Future<List<Pet>> listarPets(String clienteId) async {
    final res = await http.get(Uri.parse('$_base/pets/?cliente_id=$clienteId'));
    if (res.statusCode != 200) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(res.body))
        .map(Pet.fromJson)
        .toList();
  }

  Future<List<Servico>> listarServicos(String clienteId) async {
    final res = await http.get(Uri.parse('$_base/servicos/'));
    if (res.statusCode != 200) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(res.body))
        .where((s) => s['cliente_id'] == clienteId)
        .map(Servico.fromJson)
        .toList();
  }

  Future<Servico?> buscarServico(String id) async {
    final res = await http.get(Uri.parse('$_base/servicos/$id'));
    if (res.statusCode != 200) return null;
    return Servico.fromJson(jsonDecode(res.body));
  }

  Future<bool> criarServico({
    required String tipo,
    required String descricao,
    required String data,
    required String hora,
    required String clienteId,
    required String petId,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/servicos/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'tipo': tipo,
        'descricao': descricao,
        'data': data,
        'hora': hora,
        'cliente_id': clienteId,
        'pet_id': petId,
      }),
    );
    return res.statusCode == 201;
  }
}