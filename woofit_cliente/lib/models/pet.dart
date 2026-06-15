class Pet {
  final String id;
  final String nome;
  final String especie;

  Pet({required this.id, required this.nome, required this.especie});

  factory Pet.fromJson(Map<String, dynamic> json) => Pet(
    id: json['id'],
    nome: json['nome'],
    especie: json['especie'],
  );
}