class Servico {
  final String id;
  final String tipo;
  final String descricao;
  final String data;
  final String hora;
  final String clienteId;
  final String petId;
  final String? prestadorId;
  final String status;

  Servico({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.data,
    required this.hora,
    required this.clienteId,
    required this.petId,
    this.prestadorId,
    required this.status,
  });

  factory Servico.fromJson(Map<String, dynamic> json) => Servico(
        id: json['id'],
        tipo: json['tipo'],
        descricao: json['descricao'] ?? '',
        data: json['data'],
        hora: json['hora'],
        clienteId: json['cliente_id'],
        petId: json['pet_id'],
        prestadorId: json['prestador_id'],
        status: json['status'],
      );
}