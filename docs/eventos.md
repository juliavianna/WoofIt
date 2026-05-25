# Documentação de Eventos — WoofIt MOM

Documentação dos eventos publicados no RabbitMQ pelo backend WoofIt.

## Broker

| Parâmetro | Valor |
|-----------|-------|
| Protocolo | AMQP 0-9-1 |
| Host | localhost |
| Porta | 5672 |
| Usuário | guest |
| Biblioteca Python | pika 1.4.1 |

## Produtor

**Arquivo:** `app/messaging/publisher.py`  
**Função:** `publicar_evento(fila, payload)`

O produtor é chamado pelas rotas de serviços sempre que uma operação relevante ocorre. Ele abre uma conexão com o broker, declara a fila (criando-a se não existir) e publica a mensagem serializada em JSON. A conexão é fechada logo após o envio.

| Rota que produz | Evento gerado |
|-----------------|---------------|
| POST /servicos | `solicitacao_criada` |
| PATCH /servicos/:id/status | `status_atualizado` |

## Consumidor

**Arquivo:** `app/messaging/consumer.py`  
**Execução:** `python -m app.messaging.consumer` (processo separado ao Flask)

O consumidor fica "de plantão" esperando mensagens chegarem. Quando uma mensagem aparece na fila, ele a lê e exibe os dados no terminal. Ao terminar, avisa o RabbitMQ que recebeu a mensagem com sucesso pois sem esse aviso, o RabbitMQ entenderia que algo deu errado e enviaria a mensagem de novo.

| Fila escutada | Callback |
|---------------|----------|
| `solicitacao_criada` | `processar_mensagem` |
| `status_atualizado` | `processar_mensagem` |

---

## Eventos

### `solicitacao_criada`

Publicado quando um cliente cria uma nova solicitação de serviço (POST /servicos).

**Fila:** `solicitacao_criada`  
**Durabilidade:** persistente (`durable=True`, `delivery_mode=2`)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `servico_id` | string | ID da solicitação criada |
| `tipo` | string | Tipo do serviço (`passeio`, `visita`, `hospedagem`) |
| `cliente_id` | string | ID do tutor que solicitou |
| `pet_id` | string | ID do pet envolvido |
| `status` | string | Sempre `pendente` na criação |
| `timestamp` | string | ISO 8601 — momento da publicação |

**Exemplo de payload:**
```json
{
  "servico_id": "9jnuu",
  "tipo": "visita",
  "cliente_id": "icuzg",
  "pet_id": "camaf",
  "status": "pendente",
  "timestamp": "2026-05-20T18:49:31.149729"
}
```

---

### `status_atualizado`

Publicado quando o status de uma solicitação é alterado (PATCH /servicos/:id/status).

**Fila:** `status_atualizado`  
**Durabilidade:** persistente (`durable=True`, `delivery_mode=2`)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `servico_id` | string | ID da solicitação atualizada |
| `novo_status` | string | Novo status (`aceito`, `em_andamento`, `concluido`, `cancelado`) |
| `timestamp` | string | ISO 8601 — momento da publicação |

**Exemplo de payload:**
```json
{
  "servico_id": "9jnuu",
  "novo_status": "aceito",
  "timestamp": "2026-05-20T18:50:13.881921"
}
```

---

## Fluxo de eventos

```
Cliente faz POST /servicos
        │
        ▼
  [Flask cria serviço no MongoDB]
        │
        ▼
  publicar_evento('solicitacao_criada', {...})
        │
        ▼
  [RabbitMQ — fila: solicitacao_criada]
        │
        ▼
  [Consumer imprime evento recebido]


Cliente faz PATCH /servicos/:id/status
        │
        ▼
  [Flask atualiza status no MongoDB]
        │
        ▼
  publicar_evento('status_atualizado', {...})
        │
        ▼
  [RabbitMQ — fila: status_atualizado]
        │
        ▼
  [Consumer imprime evento recebido]
```

---

## Resiliência

O publisher usa `try/except`: se o RabbitMQ estiver indisponível, o erro é logado mas **a API REST continua funcionando**. O serviço é salvo no MongoDB normalmente.
