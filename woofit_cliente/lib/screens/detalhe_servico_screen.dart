import 'dart:async';
import 'package:flutter/material.dart';
import '../models/servico.dart';
import '../services/api_service.dart';
import '../services/stomp_service.dart';

class DetalheServicoScreen extends StatefulWidget {
  final String servicoId;

  const DetalheServicoScreen({super.key, required this.servicoId});

  @override
  State<DetalheServicoScreen> createState() => _DetalheServicoScreenState();
}

class _DetalheServicoScreenState extends State<DetalheServicoScreen> {
  final _api = ApiService();
  final _stomp = StompService();
  Servico? _servico;
  String? _notificacao;

  @override
  void initState() {
    super.initState();
    _carregar();
    _stomp.conectar(
      url: 'ws://localhost:15674/ws',
      filas: ['status_atualizado'],
      onEvento: (fila, payload) {
        // só atualiza se o evento for deste serviço
        if (payload['servico_id'] == widget.servicoId) {
          _carregar();
          if (mounted) {
            setState(() {
              _notificacao =
                  'Status atualizado para: ${payload['novo_status']}';
            });
            // limpa a notificação após 4 segundos
            Future.delayed(
              const Duration(seconds: 4),
              () { if (mounted) setState(() => _notificacao = null); },
            );
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _stomp.desconectar();
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
                  // Banner de notificação em tempo real
                  if (_notificacao != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active,
                              color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            _notificacao!,
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
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
                  _linha('Descrição',
                      s.descricao.isEmpty ? '—' : s.descricao),
                  _linha('Pet ID', s.petId),
                  _linha('Prestador',
                      s.prestadorId ?? 'Aguardando aceite...'),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Notificações em tempo real via RabbitMQ',
                          style: TextStyle(color: Colors.green),
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
            Expanded(
                child: Text(valor, style: const TextStyle(fontSize: 16))),
          ],
        ),
      );
}