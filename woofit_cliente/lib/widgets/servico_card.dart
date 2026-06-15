import 'package:flutter/material.dart';
import '../models/servico.dart';

class ServicoCard extends StatelessWidget {
  final Servico servico;
  final VoidCallback onTap;

  const ServicoCard({super.key, required this.servico, required this.onTap});

  Color _corStatus(String status) => switch (status) {
    'pendente' => Colors.orange,
    'aceito' => Colors.blue,
    'em_andamento' => Colors.purple,
    'concluido' => Colors.green,
    'cancelado' => Colors.red,
    _ => Colors.grey,
  };

  IconData _iconeTipo(String tipo) => switch (tipo) {
    'passeio' => Icons.directions_walk,
    'hospedagem' => Icons.home,
    'visita' => Icons.visibility,
    _ => Icons.pets,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepOrange.shade100,
          child: Icon(_iconeTipo(servico.tipo), color: Colors.deepOrange),
        ),
        title: Text(servico.tipo.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${servico.data} às ${servico.hora}'),
        trailing: Chip(
          label: Text(servico.status,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
          backgroundColor: _corStatus(servico.status),
        ),
        onTap: onTap,
      ),
    );
  }
}