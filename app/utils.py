import random
import string

def gerar_id():
    # Gera um ID de 5 caracteres com letras minúsculas e números
    caracteres = string.ascii_lowercase + string.digits
    return ''.join(random.choices(caracteres, k=5))