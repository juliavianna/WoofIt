import 'dart:async';
import 'package:flutter/material.dart';
import '../models/servico.dart';
import '../services/api_service.dart';

class DetalheServicoScreen extends StatefulWidget {
  final String servicoId;

  const DetalheServicoScreen({super.key, required this.servicoId});

  @override
  State<DetalheServicoScreen> createState() => _DetalheServicoScreenState();
}

class _DetalheServicoScreenState extends State<DetalheServicoScreen> {
  final _api = ApiService();
  Servico? _servico;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregar();
    // Polling a cada 5 segundos para detectar quando prestador aceitar
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _carregar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregar() async {
    final s = await _api.buscarServico(widget.servicoId);
    if (mounted && s != null) setState(() => _servico = s);
  }

  Color _corStatus(String s) => switch (s) {
    'pendente' => Colors.orange,
    'aceito' => Colors.blue,
    'em_andamento' => Colors.purple,
    'concluido' => Colors.green,
    'cancelado' => Colors.red,
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final s = _servico;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Serviço'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Chip(
                label: Text(
                  s.status.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                backgroundColor: _corStatus(s.status),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
              ),
            ),
            const SizedBox(height: 24),
            _linha('Tipo', s.tipo),
            _linha('Data', s.data),
            _linha('Horário', s.hora),
            _linha('Descrição', s.descricao.isEmpty ? '—' : s.descricao),
            _linha('Pet ID', s.petId),
            _linha('Prestador', s.prestadorId ?? 'Aguardando aceite...'),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.sync, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Atualizando automaticamente a cada 5s',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linha(String label, String valor) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        Expanded(child: Text(valor, style: const TextStyle(fontSize: 16))),
      ],
    ),
  );
}