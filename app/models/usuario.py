from datetime import datetime
from ..utils import gerar_id

def criar_usuario(nome, email, senha, perfil):
    return {
        'id': gerar_id(),
        'nome': nome,
        'email': email,
        'senha': senha,
        'perfil': perfil,
        'criado_em': datetime.utcnow()
    }