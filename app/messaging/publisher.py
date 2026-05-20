import pika
import json
from datetime import datetime

RABBITMQ_URL = 'amqp://guest:guest@localhost:5672/'

def publicar_evento(fila: str, payload: dict):
    """
    Publica um evento em uma fila do RabbitMQ.

    fila   → nome da fila onde o evento será publicado
    payload → dicionário com os dados do evento (será convertido para JSON)

    Por que ConnectionParameters e não URL direta?
    Porque permite configurar timeout, heartbeat e outros parâmetros
    de forma mais granular em ambiente de produção.
    """
    try:
        conexao = pika.BlockingConnection(
            pika.URLParameters(RABBITMQ_URL)
        )

        canal = conexao.channel()

        canal.queue_declare(queue=fila, durable=True)

        # Adiciona timestamp ao payload para rastreabilidade
        payload['timestamp'] = datetime.utcnow().isoformat()

        canal.basic_publish( # publica a mensagem na fila
            exchange='',
            routing_key=fila,
            body=json.dumps(payload),
            properties=pika.BasicProperties(
                delivery_mode=2 
            )
        )

        print(f"[MOM] Evento publicado na fila '{fila}': {payload}")
        conexao.close()

    except Exception as e:
        print(f"[MOM] Erro ao publicar evento: {e}")