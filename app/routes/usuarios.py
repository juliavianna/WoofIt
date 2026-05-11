from flask import Blueprint, request, jsonify
from ..database import db
from ..models.usuario import criar_usuario

usuarios_bp = Blueprint('usuarios', __name__)


def serializar(u):
    u.pop('_id')
    u['criado_em'] = u['criado_em'].isoformat()
    return u


@usuarios_bp.route('/', methods=['POST'])
def criar():
    data = request.get_json()
    if not data:
        return jsonify({'erro': 'Body JSON obrigatorio'}), 400

    for campo in ['nome', 'email', 'senha', 'perfil']:
        if campo not in data:
            return jsonify({'erro': f'Campo obrigatorio ausente: {campo}'}), 400

    if data['perfil'] not in ['cliente', 'prestador']:
        return jsonify({'erro': "perfil deve ser 'cliente' ou 'prestador'"}), 400

    if db.usuarios.find_one({'email': data['email']}):
        return jsonify({'erro': 'Email ja cadastrado'}), 409

    usuario = criar_usuario(data['nome'], data['email'], data['senha'], data['perfil'])
    db.usuarios.insert_one(usuario)

    return jsonify({'mensagem': 'Usuario criado com sucesso', 'id': usuario['id']}), 201


@usuarios_bp.route('/', methods=['GET'])
def listar():
    usuarios = list(db.usuarios.find({}, {'senha': 0}))
    return jsonify([serializar(u) for u in usuarios]), 200


@usuarios_bp.route('/<id>', methods=['GET'])
def buscar(id):
    usuario = db.usuarios.find_one({'id': id}, {'senha': 0})
    if not usuario:
        return jsonify({'erro': 'Usuario nao encontrado'}), 404
    return jsonify(serializar(usuario)), 200