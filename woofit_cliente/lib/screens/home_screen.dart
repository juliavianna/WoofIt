import 'dart:async';
import 'package:flutter/material.dart';
import '../models/servico.dart';
import '../services/api_service.dart';
import '../widgets/servico_card.dart';
import 'criar_servico_screen.dart';
import 'detalhe_servico_screen.dart';

class HomeScreen extends StatefulWidget {
  final String clienteId;
  final String clienteNome;

  const HomeScreen({super.key, required this.clienteId, required this.clienteNome});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  List<Servico> _servicos = [];
  bool _carregando = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregar();
    // Polling a cada 5 segundos — atualização assíncrona de estado
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _carregar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _carregar() async {
    final lista = await _api.listarServicos(widget.clienteId);
    if (mounted) setState(() { _servicos = lista; _carregando = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá, ${widget.clienteNome.split(' ').first}'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregar),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _servicos.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma solicitação ainda.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _carregar,
        child: ListView.builder(
          itemCount: _servicos.length,
          itemBuilder: (_, i) => ServicoCard(
            servico: _servicos[i],
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DetalheServicoScreen(servicoId: _servicos[i].id),
                ),
              );
              _carregar();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CriarServicoScreen(clienteId: widget.clienteId),
            ),
          );
          _carregar();
        },
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nova Solicitação'),
      ),
    );
  }
}