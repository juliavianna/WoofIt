from datetime import datetime
from ..utils import gerar_id

def criar_servico(tipo, descricao, data_hora, cliente_id, pet_id):
    return {
        'id': gerar_id(),
        'tipo': tipo,
        'descricao': descricao,
        'data_hora': data_hora,
        'cliente_id': cliente_id,
        'pet_id': pet_id,
        'prestador_id': None,
        'status': 'pendente',
        'criado_em': datetime.utcnow(),
        'atualizado_em': datetime.utcnow()
    }