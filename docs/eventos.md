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
| POST /usuarios | `usuario_cadastrado` |
| POST /pets | `pet_cadastrado` |
| POST /servicos | `solicitacao_criada` |
| PATCH /servicos/:id/status | `status_atualizado` |

## Consumidor

**Arquivo:** `app/messaging/consumer.py`  
**Execução:** `python -m app.messaging.consumer` (processo separado ao Flask)

O consumidor fica "de plantão" esperando mensagens chegarem. Quando uma mensagem aparece na fila, ele a lê e exibe os dados no terminal. Ao terminar, avisa o RabbitMQ que recebeu a mensagem com sucesso pois sem esse aviso, o RabbitMQ entenderia que algo deu errado e enviaria a mensagem de novo.

| Fila escutada | Callback |
|---------------|----------|
| `usuario_cadastrado` | `processar_mensagem` |
| `pet_cadastrado` | `processar_mensagem` |
| `solicitacao_criada` | `processar_mensagem` |
| `status_atualizado` | `processar_mensagem` |

---

## Eventos

### `usuario_cadastrado`

| Atributo | Valor |
|----------|-------|
| **Nome** | `usuario_cadastrado` |
| **Fila/Tópico** | `usuario_cadastrado` |
| **Produtor** | `app/routes/usuarios.py` — rota POST /usuarios |
| **Consumidor** | `app/messaging/consumer.py` |

**Descrição:** disparado quando um novo usuário se cadastra na plataforma, seja ele um tutor ou um prestador de serviço.

**Payload JSON de exemplo:**
```json
{
  "usuario_id": "ab3kx",
  "nome": "Maria Silva",
  "perfil": "cliente",
  "timestamp": "2026-05-25T10:12:00.000000"
}
```

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `usuario_id` | string | ID do usuário cadastrado |
| `nome` | string | Nome do usuário |
| `perfil` | string | Tipo de conta (`cliente` ou `prestador`) |
| `timestamp` | string | Momento da publicação no formato ISO 8601 |

---

### `pet_cadastrado`

| Atributo | Valor |
|----------|-------|
| **Nome** | `pet_cadastrado` |
| **Fila/Tópico** | `pet_cadastrado` |
| **Produtor** | `app/routes/pets.py` — rota POST /pets |
| **Consumidor** | `app/messaging/consumer.py` |

**Descrição:** disparado quando um tutor cadastra um novo pet na plataforma.

**Payload JSON de exemplo:**
```json
{
  "pet_id": "xz9qw",
  "nome": "Bolt",
  "especie": "cachorro",
  "cliente_id": "ab3kx",
  "timestamp": "2026-05-25T10:15:00.000000"
}
```

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `pet_id` | string | ID do pet cadastrado |
| `nome` | string | Nome do pet |
| `especie` | string | Espécie do animal |
| `cliente_id` | string | ID do tutor dono do pet |
| `timestamp` | string | Momento da publicação no formato ISO 8601 |

---

### `solicitacao_criada`

| Atributo | Valor |
|----------|-------|
| **Nome** | `solicitacao_criada` |
| **Fila/Tópico** | `solicitacao_criada` |
| **Produtor** | `app/routes/servicos.py` — rota POST /servicos |
| **Consumidor** | `app/messaging/consumer.py` |

**Descrição:** disparado quando um cliente cria uma nova solicitação de serviço. Permite que outros sistemas saibam que há um novo serviço aguardando um prestador.

**Payload JSON de exemplo:**
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

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `servico_id` | string | ID da solicitação criada |
| `tipo` | string | Tipo do serviço (`passeio`, `visita`, `hospedagem`) |
| `cliente_id` | string | ID do tutor que solicitou |
| `pet_id` | string | ID do pet envolvido |
| `status` | string | Sempre `pendente` na criação |
| `timestamp` | string | Momento da publicação no formato ISO 8601 |

---

### `status_atualizado`

| Atributo | Valor |
|----------|-------|
| **Nome** | `status_atualizado` |
| **Fila/Tópico** | `status_atualizado` |
| **Produtor** | `app/routes/servicos.py` — rota PATCH /servicos/:id/status |
| **Consumidor** | `app/messaging/consumer.py` |

**Descrição:** disparado quando o status de uma solicitação é alterado. Permite rastrear em tempo real a evolução de um serviço, desde a aceitação até a conclusão.

**Payload JSON de exemplo:**
```json
{
  "servico_id": "9jnuu",
  "novo_status": "aceito",
  "timestamp": "2026-05-20T18:50:13.881921"
}
```

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `servico_id` | string | ID da solicitação atualizada |
| `novo_status` | string | Novo status (`aceito`, `em_andamento`, `concluido`, `cancelado`) |
| `timestamp` | string | Momento da publicação no formato ISO 8601 |

---

## Fluxo de eventos

```
POST /usuarios ──► salva no MongoDB ──► publicar_evento('usuario_cadastrado')
                                                │
POST /pets     ──► salva no MongoDB ──► publicar_evento('pet_cadastrado')
                                                │
POST /servicos ──► salva no MongoDB ──► publicar_evento('solicitacao_criada')
                                                │
PATCH /servicos/:id/status                      │
               ──► atualiza MongoDB ──► publicar_evento('status_atualizado')
                                                │
                                                ▼
                                    ┌───────────────────────┐
                                    │       RabbitMQ        │
                                    │  fila: usuario_       │
                                    │        cadastrado     │
                                    │  fila: pet_cadastrado │
                                    │  fila: solicitacao_   │
                                    │        criada         │
                                    │  fila: status_        │
                                    │        atualizado     │
                                    └───────────┬───────────┘
                                                │
                                                ▼
                                    ┌───────────────────────┐
                                    │  consumer.py          │
                                    │  processa e exibe     │
                                    │  todos os eventos     │
                                    └───────────────────────┘
```

---

## Resiliência

O publisher usa `try/except`: se o RabbitMQ estiver indisponível, o erro é logado mas **a API REST continua funcionando**. O serviço é salvo no MongoDB normalmente.
