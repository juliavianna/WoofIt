from flask import Blueprint, request, jsonify
from datetime import datetime
from ..database import db
from ..models.servico import criar_servico

servicos_bp = Blueprint('servicos', __name__)

STATUS_VALIDOS = ['pendente', 'aceito', 'em_andamento', 'concluido', 'cancelado']
TIPOS_VALIDOS = ['passeio', 'hospedagem', 'visita']


def serializar(s):
    s.pop('_id')
    s['criado_em'] = s['criado_em'].isoformat()
    s['atualizado_em'] = s['atualizado_em'].isoformat()
    return s


@servicos_bp.route('/', methods=['POST'])
def criar():
    data = request.get_json()
    if not data:
        return jsonify({'erro': 'Body JSON obrigatorio'}), 400

    for campo in ['tipo', 'data_hora', 'cliente_id', 'pet_id']:
        if campo not in data:
            return jsonify({'erro': f'Campo obrigatorio ausente: {campo}'}), 400

    if data['tipo'] not in TIPOS_VALIDOS:
        return jsonify({'erro': f'tipo deve ser: {", ".join(TIPOS_VALIDOS)}'}), 400

    if not db.usuarios.find_one({'id': data['cliente_id'], 'perfil': 'cliente'}):
        return jsonify({'erro': 'Cliente nao encontrado'}), 404

    if not db.pets.find_one({'id': data['pet_id']}):
        return jsonify({'erro': 'Pet nao encontrado'}), 404

    servico = criar_servico(data['tipo'], data.get('descricao', ''), data['data_hora'], data['cliente_id'], data['pet_id'])
    db.servicos.insert_one(servico)

    return jsonify({'mensagem': 'Solicitacao criada com sucesso', 'id': servico['id']}), 201


@servicos_bp.route('/', methods=['GET'])
def listar():
    filtro = {}
    if request.args.get('status'):
        filtro['status'] = request.args.get('status')
    if request.args.get('tipo'):
        filtro['tipo'] = request.args.get('tipo')

    servicos = list(db.servicos.find(filtro).sort('criado_em', -1))
    return jsonify([serializar(s) for s in servicos]), 200


@servicos_bp.route('/<id>', methods=['GET'])
def buscar(id):
    servico = db.servicos.find_one({'id': id})
    if not servico:
        return jsonify({'erro': 'Servico nao encontrado'}), 404
    return jsonify(serializar(servico)), 200


@servicos_bp.route('/<id>/status', methods=['PATCH'])
def atualizar_status(id):
    data = request.get_json()
    if not data or 'status' not in data:
        return jsonify({'erro': 'Campo obrigatorio: status'}), 400

    if data['status'] not in STATUS_VALIDOS:
        return jsonify({'erro': f'Status invalido. Validos: {", ".join(STATUS_VALIDOS)}'}), 400

    atualizacao = {'$set': {'status': data['status'], 'atualizado_em': datetime.utcnow()}}

    if data['status'] == 'aceito' and 'prestador_id' in data:
        atualizacao['$set']['prestador_id'] = data['prestador_id']

    resultado = db.servicos.update_one({'id': id}, atualizacao)
    if resultado.matched_count == 0:
        return jsonify({'erro': 'Servico nao encontrado'}), 404

    return jsonify({'mensagem': 'Status atualizado com sucesso'}), 200