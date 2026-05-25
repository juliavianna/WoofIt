from flask import Blueprint, request, jsonify
from bson import ObjectId

from app.messaging.publisher import publicar_evento
from ..database import db
from ..models.pet import criar_pet

pets_bp = Blueprint('pets', __name__)


def serializar(p): #remove o _id do MongoDB e converte os ObjectId para string para facilitar a leitura no front
    p.pop('_id', None)
    for chave in list(p.keys()):
        if isinstance(p[chave], ObjectId):
            p[chave] = str(p[chave])
    p['criado_em'] = p['criado_em'].isoformat()
    return p


def nomeTutor(p): #pega o nome do tutor do pet para exibir junto com os dados do pet
    cliente = db.usuarios.find_one({'id': p['cliente_id']}, {'nome': 1})
    p['nome_cliente'] = cliente['nome'] if cliente else 'Desconhecido'
    return p


@pets_bp.route('/', methods=['POST']) #cadastra um novo pet, é necessário informar o id do cliente para associar o pet ao tutor
def criar():
    data = request.get_json()
    if not data:
        return jsonify({'erro': 'Body JSON obrigatorio'}), 400

    for campo in ['nome', 'especie', 'idade', 'cliente_id']:
        if campo not in data:
            return jsonify({'erro': f'Campo obrigatorio ausente: {campo}'}), 400

    cliente = db.usuarios.find_one({'id': data['cliente_id'], 'perfil': 'cliente'})
    if not cliente:
        return jsonify({'erro': 'Cliente nao encontrado'}), 404

    pet = criar_pet(data['nome'], data['especie'], data.get('raca', ''), data['idade'], data['cliente_id'])
    db.pets.insert_one(pet)

    publicar_evento('pet_cadastrado', {
        'pet_id': pet['id'],
        'nome': pet['nome'],
        'especie': pet['especie'],
        'cliente_id': pet['cliente_id']
    })

    return jsonify({'mensagem': 'Pet cadastrado com sucesso', 'id': pet['id']}), 201


@pets_bp.route('/', methods=['GET']) #lista pets, pode filtrar por cliente_id para mostrar apenas os pets de um cliente específico
def listar():
    filtro = {}
    if request.args.get('cliente_id'):
        filtro['cliente_id'] = request.args.get('cliente_id')

    pets = list(db.pets.find(filtro))
    return jsonify([serializar(nomeTutor(p)) for p in pets]), 200


@pets_bp.route('/<id>', methods=['GET']) #busca pet por id e exibe junto o nome do tutor
def buscar(id):
    pet = db.pets.find_one({'id': id})
    if not pet:
        return jsonify({'erro': 'Pet nao encontrado'}), 404
    return jsonify(serializar(nomeTutor(pet))), 200