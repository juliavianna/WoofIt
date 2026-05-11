# Schema do Banco de Dados — WoofIt

Banco: **woofit** (MongoDB)  
Tipo: NoSQL orientado a documentos  
Driver: pymongo 4.7

> Os IDs são gerados pela aplicação como strings alfanuméricas de 5 caracteres (ex: `a3k9z`),
> substituindo o ObjectId padrão do MongoDB na camada de API.

---

## Coleção: `usuarios`

Armazena tanto clientes (tutores de pets) quanto prestadores (pet sitters/walkers).
O campo `perfil` determina o papel do usuário no sistema.

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `_id` | ObjectId | sim | ID interno do MongoDB (não exposto na API) |
| `id` | String (5 chars) | sim | Identificador público gerado pela aplicação |
| `nome` | String | sim | Nome completo do usuário |
| `email` | String | sim | E-mail único no sistema |
| `senha` | String | sim | Senha do usuário |
| `perfil` | String (enum) | sim | `"cliente"` ou `"prestador"` |
| `criado_em` | Date (UTC) | sim | Data e hora de criação do registro |

**Exemplo de documento:**
```json
{
  "id": "j8u6a",
  "nome": "Ana Silva",
  "email": "ana@email.com",
  "senha": "123456",
  "perfil": "cliente",
  "criado_em": "2026-05-11T18:00:00.000Z"
}
```

---

## Coleção: `pets`

Armazena os animais cadastrados pelos clientes.
Cada pet pertence a um único cliente via `cliente_id`.

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `_id` | ObjectId | sim | ID interno do MongoDB (não exposto na API) |
| `id` | String (5 chars) | sim | Identificador público gerado pela aplicação |
| `nome` | String | sim | Nome do animal |
| `especie` | String | sim | Espécie (ex: cachorro, gato) |
| `raca` | String | não | Raça do animal (vazio se não informado) |
| `idade` | Number | sim | Idade em anos |
| `cliente_id` | String (5 chars) | sim | Referência ao `id` do usuário dono do pet |
| `criado_em` | Date (UTC) | sim | Data e hora de criação do registro |

**Relacionamento:** `pets.cliente_id` → `usuarios.id`

**Exemplo de documento:**
```json
{
  "id": "t0yiz",
  "nome": "Bob",
  "especie": "cachorro",
  "raca": "Golden Retriever",
  "idade": 3,
  "cliente_id": "j8u6a",
  "criado_em": "2026-05-11T18:05:00.000Z"
}
```

---

## Coleção: `servicos`

Armazena as solicitações de serviço criadas pelos clientes.
Representa o núcleo do domínio: o pedido que conecta cliente, pet e prestador.

| Campo | Tipo | Obrigatório | Descrição |
|-------|------|-------------|-----------|
| `_id` | ObjectId | sim | ID interno do MongoDB (não exposto na API) |
| `id` | String (5 chars) | sim | Identificador público gerado pela aplicação |
| `tipo` | String (enum) | sim | `"passeio"`, `"hospedagem"` ou `"visita"` |
| `descricao` | String | não | Descrição livre da solicitação |
| `data` | String | sim | Data do serviço no formato `dd-mm-aa` |
| `hora` | String | sim | Horário do serviço no formato `hh:mm` |
| `cliente_id` | String (5 chars) | sim | Referência ao `id` do cliente solicitante |
| `pet_id` | String (5 chars) | sim | Referência ao `id` do pet |
| `prestador_id` | String (5 chars) \| null | não | Referência ao `id` do prestador (preenchido no aceite) |
| `status` | String (enum) | sim | Estado atual do serviço (ver workflow abaixo) |
| `criado_em` | Date (UTC) | sim | Data e hora de criação da solicitação |
| `atualizado_em` | Date (UTC) | sim | Data e hora da última atualização de status |

**Relacionamentos:**
- `servicos.cliente_id` → `usuarios.id`
- `servicos.pet_id` → `pets.id`
- `servicos.prestador_id` → `usuarios.id` (após aceite)

**Workflow de status:**
```
pendente → aceito → em_andamento → concluido
    ↓          ↓           ↓
 cancelado  cancelado   cancelado
```

**Exemplo de documento:**
```json
{
  "id": "1akrq",
  "tipo": "passeio",
  "descricao": "Passeio de 40 minutos na rua",
  "data": "12-05-26",
  "hora": "15:00",
  "cliente_id": "j8u6a",
  "pet_id": "t0yiz",
  "prestador_id": null,
  "status": "pendente",
  "criado_em": "2026-05-11T18:10:00.000Z",
  "atualizado_em": "2026-05-11T18:10:00.000Z"
}
```

---

## Diagrama de Relacionamentos

```
usuarios (perfil: "cliente")
    │
    │ 1:N
    ▼
  pets ──── N:1 ──── usuarios (perfil: "cliente")
    │
    │ 1:N
    ▼
servicos ── N:1 ──── usuarios (perfil: "prestador")  [após aceite]
```
