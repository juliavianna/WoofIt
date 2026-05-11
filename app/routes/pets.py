from flask import Blueprint, request, jsonify
from ..database import db
from ..models.pet import criar_pet

pets_bp = Blueprint('pets', __name__)


def serializar(p):
    p.pop('_id')
    p['criado_em'] = p['criado_em'].isoformat()
    return p


@pets_bp.route('/', methods=['POST'])
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

    return jsonify({'mensagem': 'Pet cadastrado com sucesso', 'id': pet['id']}), 201


@pets_bp.route('/', methods=['GET'])
def listar():
    filtro = {}
    if request.args.get('cliente_id'):
        filtro['cliente_id'] = request.args.get('cliente_id')

    pets = list(db.pets.find(filtro))
    return jsonify([serializar(p) for p in pets]), 200


@pets_bp.route('/<id>', methods=['GET'])
def buscar(id):
    pet = db.pets.find_one({'id': id})
    if not pet:
        return jsonify({'erro': 'Pet nao encontrado'}), 404
    return jsonify(serializar(pet)), 200