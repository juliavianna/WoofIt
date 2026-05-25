import pika
import json

RABBITMQ_URL = 'amqp://guest:guest@localhost:5672/'

FILAS = ['solicitacao_criada', 'status_atualizado', 'usuario_cadastrado', 'pet_cadastrado']

def processar_mensagem(canal, method, properties, body):
    """
    Callback chamado automaticamente pelo RabbitMQ
    quando uma mensagem chega na fila.

    canal      → canal de comunicação com o RabbitMQ
    method     → metadados da entrega (fila, tag)
    properties → propriedades da mensagem
    body       → conteúdo da mensagem em bytes
    """
    evento = json.loads(body)
    fila = method.routing_key

    print(f"\n[CONSUMIDOR] Evento recebido da fila '{fila}':")
    for chave, valor in evento.items():
        print(f"  {chave}: {valor}")

    canal.basic_ack(delivery_tag=method.delivery_tag)


def iniciar_consumidor():
    print("[CONSUMIDOR] Conectando ao RabbitMQ...")

    conexao = pika.BlockingConnection(
        pika.URLParameters(RABBITMQ_URL)
    )
    canal = conexao.channel()

    for fila in FILAS:
        canal.queue_declare(queue=fila, durable=True)
        canal.basic_consume(
            queue=fila,
            on_message_callback=processar_mensagem
        )
        print(f"[CONSUMIDOR] Escutando fila: '{fila}'")

    print("[CONSUMIDOR] Aguardando eventos... (Ctrl+C para parar)\n")

    canal.start_consuming()


if __name__ == '__main__':
    iniciar_consumidor()