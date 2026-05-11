from datetime import datetime
from ..utils import gerar_id

def criar_pet(nome, especie, raca, idade, cliente_id):
    return {
        'id': gerar_id(),
        'nome': nome,
        'especie': especie,
        'raca': raca,
        'idade': idade,
        'cliente_id': cliente_id,
        'criado_em': datetime.utcnow()
    }