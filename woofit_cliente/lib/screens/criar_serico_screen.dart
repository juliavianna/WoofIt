import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/api_service.dart';

class CriarServicoScreen extends StatefulWidget {
  final String clienteId;

  const CriarServicoScreen({super.key, required this.clienteId});

  @override
  State<CriarServicoScreen> createState() => _CriarServicoScreenState();
}

class _CriarServicoScreenState extends State<CriarServicoScreen> {
  final _api = ApiService();
  final _descCtrl = TextEditingController();

  String _tipo = 'passeio';
  DateTime _data = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _hora = const TimeOfDay(hour: 10, minute: 0);
  List<Pet> _pets = [];
  String? _petSelecionado;
  bool _salvando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarPets();
  }

  Future<void> _carregarPets() async {
    final pets = await _api.listarPets(widget.clienteId);
    setState(() {
      _pets = pets;
      if (pets.isNotEmpty) _petSelecionado = pets.first.id;
    });
  }

  String _formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year.toString().substring(2)}';

  String _formatarHora(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _salvar() async {
    if (_petSelecionado == null) {
      setState(() => _erro = 'Cadastre um pet primeiro no sistema.');
      return;
    }
    setState(() { _salvando = true; _erro = null; });

    final ok = await _api.criarServico(
      tipo: _tipo,
      descricao: _descCtrl.text,
      data: _formatarData(_data),
      hora: _formatarHora(_hora),
      clienteId: widget.clienteId,
      petId: _petSelecionado!,
    );

    setState(() => _salvando = false);

    if (ok && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _erro = 'Erro ao criar solicitação.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Solicitação'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipo de serviço',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'passeio', label: Text('Passeio'), icon: Icon(Icons.directions_walk)),
                ButtonSegment(value: 'visita', label: Text('Visita'), icon: Icon(Icons.visibility)),
                ButtonSegment(value: 'hospedagem', label: Text('Hospedagem'), icon: Icon(Icons.home)),
              ],
              selected: {_tipo},
              onSelectionChanged: (v) => setState(() => _tipo = v.first),
            ),
            const SizedBox(height: 24),
            const Text('Pet', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _pets.isEmpty
                ? const Text('Nenhum pet cadastrado.',
                style: TextStyle(color: Colors.red))
                : DropdownButtonFormField<String>(
              value: _petSelecionado,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _pets
                  .map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text('${p.nome} (${p.especie})')))
                  .toList(),
              onChanged: (v) => setState(() => _petSelecionado = v),
            ),
            const SizedBox(height: 24),
            const Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _data,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _data = d);
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(_formatarData(_data)),
            ),
            const SizedBox(height: 16),
            const Text('Horário', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final t = await showTimePicker(
                    context: context, initialTime: _hora);
                if (t != null) setState(() => _hora = t);
              },
              icon: const Icon(Icons.access_time),
              label: Text(_formatarHora(_hora)),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            if (_erro != null) ...[
              const SizedBox(height: 12),
              Text(_erro!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _salvando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Solicitar Serviço',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}