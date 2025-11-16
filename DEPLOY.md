# 🚀 Deploy Evolution API com Gemini Transcription

## 📋 Sobre esta Versão

Esta é uma versão **customizada** da Evolution API que inclui:

✅ **Transcrição de Áudio com Google Gemini 2.0 Flash-Lite**
- Transcrição automática de mensagens de áudio do WhatsApp
- Custo ultra-baixo (~R$ 0,36 para 1.000 áudios de 30 segundos)
- Alta precisão com pontuação e formatação
- Processamento em português brasileiro

📁 **Arquivos Customizados:**
- `src/api/services/gemini-transcription.service.ts` - Serviço de transcrição
- Integração em `src/api/integrations/channel/whatsapp/whatsapp.baileys.service.ts`

---

## 🎯 Opções de Deploy

### Opção 1: Railway com Dockerfile (Recomendado)
### Opção 2: Imagem Docker Personalizada

---

## 📦 OPÇÃO 1: Deploy no Railway com Dockerfile

### Pré-requisitos
- Conta no [Railway](https://railway.app)
- Repositório GitHub com o código
- API Key do Google Gemini ([Obter aqui](https://aistudio.google.com/app/apikey))

### Passo 1: Criar Projeto no Railway

1. Acesse https://railway.app
2. Clique em **"New Project"**
3. Selecione **"Deploy from GitHub repo"**
4. Autorize e escolha este repositório

### Passo 2: Adicionar Banco de Dados

#### PostgreSQL
1. No projeto, clique em **"+ New"**
2. Selecione **"Database" → "Add PostgreSQL"**
3. ✅ A variável `${{Postgres.DATABASE_URL}}` será criada

#### Redis
1. Clique em **"+ New"**
2. Selecione **"Database" → "Add Redis"**
3. ✅ A variável `${{Redis.REDIS_URL}}` será criada

### Passo 3: Configurar Variáveis de Ambiente

No serviço **Evolution API**, clique em **"Variables"** e adicione:

```bash
# ============================================
# OBRIGATÓRIAS
# ============================================

# 1. Chave de autenticação (gere com: openssl rand -base64 32)
AUTHENTICATION_API_KEY=sua_chave_forte_aqui

# 2. Database
DATABASE_PROVIDER=postgresql
DATABASE_CONNECTION_URI=${{Postgres.DATABASE_URL}}

# 3. Redis
CACHE_REDIS_ENABLED=true
CACHE_REDIS_URI=${{Redis.REDIS_URL}}

# 4. GEMINI (IMPORTANTE!)
GEMINI_ENABLED=true
GEMINI_API_KEY=sua_api_key_do_gemini

# 5. Servidor
SERVER_NAME=evolution
SERVER_URL=https://seu-dominio.up.railway.app

# ============================================
# RECOMENDADAS
# ============================================

LOG_LEVEL=ERROR,WARN,INFO
LANGUAGE=pt-BR
WEBSOCKET_ENABLED=true

DATABASE_SAVE_DATA_INSTANCE=true
DATABASE_SAVE_DATA_NEW_MESSAGE=true
DATABASE_SAVE_DATA_CONTACTS=true
DATABASE_SAVE_DATA_CHATS=true

WEBHOOK_EVENTS_MESSAGES_UPSERT=true
WEBHOOK_EVENTS_CONNECTION_UPDATE=true
WEBHOOK_EVENTS_QRCODE_UPDATED=true
```

### Passo 4: Gerar Domínio

1. No serviço Evolution API, vá em **"Settings"**
2. Em **"Networking"**, clique em **"Generate Domain"**
3. Copie o domínio (ex: `https://evolution-production-xxxx.up.railway.app`)
4. Atualize a variável `SERVER_URL` com este domínio

### Passo 5: Deploy Automático

✅ O Railway fará deploy automaticamente!

Acompanhe em:
- **Deployments** (progresso do build)
- **Logs** (logs da aplicação)

---

## 🐳 OPÇÃO 2: Imagem Docker Personalizada

### Construir e Publicar Imagem

#### 1. Criar conta no GitHub Container Registry (ou Docker Hub)

**GitHub Container Registry (Recomendado):**
1. Acesse https://github.com/settings/tokens
2. Crie um **Personal Access Token** com permissão `write:packages`
3. Salve o token

#### 2. Build da Imagem

```bash
# Dar permissão ao script
chmod +x build-image.sh

# Build local (sem push)
./build-image.sh -u SEU_USERNAME_GITHUB

# Build e push para GitHub Container Registry
./build-image.sh -u SEU_USERNAME_GITHUB -p
```

#### 3. Fazer login e push manual (alternativa)

```bash
# Login no GitHub Container Registry
echo "SEU_TOKEN" | docker login ghcr.io -u SEU_USERNAME --password-stdin

# Build
docker build -f Dockerfile.custom -t ghcr.io/SEU_USERNAME/evolution-api-gemini:latest .

# Push
docker push ghcr.io/SEU_USERNAME/evolution-api-gemini:latest
```

### Usar Imagem no Railway

1. No Railway, ao invés de conectar ao GitHub, escolha **"Deploy a Docker Image"**
2. Cole a URL da imagem: `ghcr.io/SEU_USERNAME/evolution-api-gemini:latest`
3. Configure as variáveis de ambiente (mesmas do Passo 3 acima)
4. Adicione PostgreSQL e Redis

---

## 🔐 Obter API Keys

### Google Gemini API Key

1. Acesse https://aistudio.google.com/app/apikey
2. Clique em **"Get API Key"**
3. Copie a chave gerada
4. Cole em `GEMINI_API_KEY`

**Custo:** ~R$ 0,36 para 1.000 áudios de 30 segundos

### Chave de Autenticação

```bash
# Linux/Mac
openssl rand -base64 32

# Windows (PowerShell)
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))
```

---

## ✅ Testar a Aplicação

### 1. Health Check
```bash
curl https://seu-dominio.up.railway.app
```

### 2. Criar Instância WhatsApp
```bash
curl -X POST https://seu-dominio.up.railway.app/instance/create \
  -H "apikey: sua_chave_api" \
  -H "Content-Type: application/json" \
  -d '{
    "instanceName": "minha-instancia",
    "qrcode": true
  }'
```

### 3. Obter QR Code
```bash
curl https://seu-dominio.up.railway.app/instance/connect/minha-instancia \
  -H "apikey: sua_chave_api"
```

### 4. Testar Transcrição de Áudio

1. Conecte uma instância do WhatsApp
2. Envie um áudio para a instância
3. A transcrição será feita automaticamente
4. Verifique os logs para ver o resultado

---

## 🔧 Variáveis de Ambiente Completas

Consulte o arquivo [.env.railway](.env.railway) para lista completa de todas as variáveis disponíveis.

**Principais categorias:**
- ✅ Servidor e CORS
- ✅ Banco de Dados (PostgreSQL/MySQL)
- ✅ Redis (Cache)
- ✅ Autenticação
- ✅ Webhooks
- ✅ WebSocket
- ✅ **Gemini (Transcrição)**
- ✅ S3/MinIO (Armazenamento)
- ✅ Integrações (Typebot, Chatwoot, OpenAI, etc)
- ✅ Métricas e Logs

---

## 🐛 Troubleshooting

### ❌ Erro: "GEMINI_API_KEY não configurada"
**Solução:** Adicione a variável `GEMINI_API_KEY` nas variáveis de ambiente do Railway.

### ❌ Erro: "Migration failed"
**Solução:**
1. Verifique se `DATABASE_CONNECTION_URI=${{Postgres.DATABASE_URL}}`
2. Certifique-se de que o PostgreSQL está rodando

### ❌ Erro: "Redis connection failed"
**Solução:**
1. Verifique se `CACHE_REDIS_URI=${{Redis.REDIS_URL}}`
2. Certifique-se de que o Redis está rodando

### ❌ Transcrição não funciona
**Solução:**
1. Verifique se `GEMINI_ENABLED=true`
2. Verifique se `GEMINI_API_KEY` está correta
3. Verifique os logs para erros da API Gemini
4. Certifique-se de que está enviando áudio em formato OGG

### ❌ Build falha no Docker
**Solução:**
1. Verifique os logs em **Deployments**
2. Certifique-se de que o `Dockerfile.custom` existe
3. Configure o Railway para usar o Dockerfile correto

---

## 📊 Estrutura dos Serviços

```
┌─────────────────────────────────────┐
│  Railway Project                     │
├─────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────┐    │
│  │  Evolution API + Gemini     │    │
│  │  (Dockerfile.custom)        │    │
│  │  Port: Auto                 │    │
│  └────────────────────────────┘    │
│           │                          │
│           ├──────────────┐          │
│           ▼              ▼          │
│  ┌──────────────┐  ┌─────────┐    │
│  │ PostgreSQL   │  │  Redis   │    │
│  └──────────────┘  └─────────┘    │
│                                      │
└─────────────────────────────────────┘
```

---

## 💰 Custos Estimados

### Railway
- **Evolution API**: $5-10/mês
- **PostgreSQL**: $5/mês
- **Redis**: $5/mês
- **Total Railway**: ~$15-20/mês

### Google Gemini
- **1.000 áudios/mês**: ~R$ 0,36
- **10.000 áudios/mês**: ~R$ 3,60
- **100.000 áudios/mês**: ~R$ 36,00

**Custo Total Estimado**: $15-20/mês + custos de transcrição

💡 **Dica**: Railway oferece $5 grátis/mês para testar.

---

## 📖 Arquitetura da Transcrição

### Como Funciona

1. **Usuário envia áudio** via WhatsApp
2. **Baileys recebe** a mensagem de áudio
3. **Áudio é convertido** para base64
4. **Gemini API processa** e transcreve
5. **Texto é retornado** e pode ser usado em:
   - Webhooks
   - Chatbots
   - Armazenamento no banco
   - Logs

### Arquivo Principal

[src/api/services/gemini-transcription.service.ts](src/api/services/gemini-transcription.service.ts)

```typescript
export class GeminiTranscriptionService {
  async transcribeAudio(audioBase64: string): Promise<string | null>
  isEnabled(): boolean
}
```

### Configuração

- **Modelo**: `gemini-2.0-flash-lite`
- **Formato**: Audio OGG
- **Prompt**: Transcrição com pontuação e formatação
- **Custo**: R$ 0,42/1M tokens (input) + R$ 1,70/1M tokens (output)

---

## 🔗 Links Úteis

- 📚 [Evolution API Docs](https://doc.evolution-api.com)
- 🚂 [Railway Docs](https://docs.railway.app)
- 🤖 [Google AI Studio](https://aistudio.google.com)
- 💬 [Evolution API Discord](https://evolution-api.com/discord)
- 📊 [Custos Detalhados](CUSTOS_GEMINI_FLUDATA.md)

---

## 📝 Notas Importantes

⚠️ **Esta é uma versão CUSTOMIZADA**
- Não é a versão oficial da Evolution API
- Inclui feature de transcrição com Gemini
- Mantenha seu fork atualizado

✅ **Compatibilidade**
- Totalmente compatível com a Evolution API v2.3.6
- Todas as features originais funcionam normalmente
- Apenas adiciona transcrição de áudio

🔒 **Segurança**
- Nunca commite suas API keys
- Use variáveis de ambiente
- Mantenha `AUTHENTICATION_API_KEY` forte

---

✅ **Pronto! Sua Evolution API com Gemini Transcription está rodando!**

Se precisar de ajuda, consulte os logs ou entre em contato.
