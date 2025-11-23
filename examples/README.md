# Ejemplo de LangChain con Azure OpenAI / LangChain with Azure OpenAI Example

Este directorio contiene un ejemplo completo de cómo implementar una aplicación LangChain con Azure OpenAI.

This directory contains a complete example of how to implement a LangChain application with Azure OpenAI.

## Archivos / Files

- `langchain_azure_example.py` - Aplicación FastAPI con LangChain y Azure OpenAI
- `requirements-langchain.txt` - Dependencias necesarias
- `.env.example` - Plantilla de variables de entorno
- `Dockerfile` - Para containerizar la aplicación
- `README.md` - Este archivo

## Inicio Rápido / Quick Start

### 1. Instalar dependencias / Install dependencies

```bash
pip install -r requirements-langchain.txt
```

### 2. Configurar variables de entorno / Configure environment variables

```bash
# Copiar el archivo de ejemplo
cp .env.example .env

# Editar .env con tus credenciales de Azure
# Edit .env with your Azure credentials
```

### 3. Ejecutar la aplicación / Run the application

```bash
python langchain_azure_example.py
```

O con uvicorn directamente:

```bash
uvicorn langchain_azure_example:app --reload
```

### 4. Probar la API / Test the API

Visita `http://localhost:8000/docs` para ver la documentación interactiva de la API.

Visit `http://localhost:8000/docs` to see the interactive API documentation.

## Endpoints Disponibles / Available Endpoints

### GET /
Información básica de la API

Basic API information

### GET /health
Verifica el estado de la aplicación y la conexión con Azure OpenAI

Check application health and Azure OpenAI connection

### POST /chat
Chat simple sin memoria de conversación

Simple chat without conversation memory

```bash
curl -X POST "http://localhost:8000/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "¿Qué servicios de Azure necesito para LangChain?",
    "system_prompt": "Eres un experto en Azure"
  }'
```

### POST /conversation
Chat con memoria de conversación

Chat with conversation memory

```bash
curl -X POST "http://localhost:8000/conversation" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hola, soy desarrollador Python",
    "conversation_id": "user123"
  }'
```

### DELETE /conversation/{conversation_id}
Elimina una conversación de la memoria

Delete a conversation from memory

```bash
curl -X DELETE "http://localhost:8000/conversation/user123"
```

### GET /conversations
Lista todas las conversaciones activas

List all active conversations

```bash
curl "http://localhost:8000/conversations"
```

## Desplegar con Docker / Deploy with Docker

### Construir la imagen / Build the image

```bash
docker build -t langchain-azure-app .
```

### Ejecutar el contenedor / Run the container

```bash
docker run -p 8000:8000 \
  -e AZURE_OPENAI_ENDPOINT="your-endpoint" \
  -e AZURE_OPENAI_API_KEY="your-key" \
  -e AZURE_OPENAI_DEPLOYMENT_NAME="gpt-4" \
  langchain-azure-app
```

## Desplegar en Azure / Deploy to Azure

### Opción 1: Azure App Service

```bash
# Crear grupo de recursos
az group create --name langchain-rg --location eastus

# Crear App Service Plan
az appservice plan create \
  --name langchain-plan \
  --resource-group langchain-rg \
  --sku B1 \
  --is-linux

# Crear Web App
az webapp create \
  --resource-group langchain-rg \
  --plan langchain-plan \
  --name my-langchain-app \
  --runtime "PYTHON:3.11"

# Configurar variables de entorno
az webapp config appsettings set \
  --resource-group langchain-rg \
  --name my-langchain-app \
  --settings \
    AZURE_OPENAI_ENDPOINT="your-endpoint" \
    AZURE_OPENAI_API_KEY="your-key" \
    AZURE_OPENAI_DEPLOYMENT_NAME="gpt-4"

# Desplegar
az webapp up --resource-group langchain-rg --name my-langchain-app
```

### Opción 2: Azure Container Apps

```bash
# Crear Container Registry
az acr create \
  --resource-group langchain-rg \
  --name mylangchainacr \
  --sku Basic

# Construir y subir imagen
az acr build \
  --registry mylangchainacr \
  --image langchain-app:v1 .

# Crear Container App Environment
az containerapp env create \
  --name langchain-env \
  --resource-group langchain-rg \
  --location eastus

# Crear Container App
az containerapp create \
  --name langchain-app \
  --resource-group langchain-rg \
  --environment langchain-env \
  --image mylangchainacr.azurecr.io/langchain-app:v1 \
  --target-port 8000 \
  --ingress external \
  --env-vars \
    AZURE_OPENAI_ENDPOINT="your-endpoint" \
    AZURE_OPENAI_API_KEY="your-key" \
    AZURE_OPENAI_DEPLOYMENT_NAME="gpt-4"
```

## Requisitos de Azure / Azure Requirements

Para ejecutar este ejemplo necesitas:

To run this example you need:

1. **Azure OpenAI Service**
   - Un recurso de Azure OpenAI creado
   - Un modelo desplegado (gpt-4 o gpt-35-turbo)
   - API key y endpoint

2. **(Opcional) Azure Cognitive Search**
   - Para implementar RAG con búsqueda vectorial
   - Para almacenar embeddings

3. **(Opcional) Azure Cosmos DB**
   - Para persistir conversaciones
   - Para almacenar historial de chat

## Personalización / Customization

### Cambiar el modelo / Change the model

Edita la función `get_azure_llm()` para cambiar parámetros como `temperature`, `max_tokens`, etc.

Edit the `get_azure_llm()` function to change parameters like `temperature`, `max_tokens`, etc.

### Agregar memoria persistente / Add persistent memory

Reemplaza `ConversationBufferMemory` con `CosmosDBChatMessageHistory`:

Replace `ConversationBufferMemory` with `CosmosDBChatMessageHistory`:

```python
from langchain.memory import CosmosDBChatMessageHistory

memory = CosmosDBChatMessageHistory(
    cosmos_endpoint=os.getenv("COSMOS_DB_ENDPOINT"),
    cosmos_database=os.getenv("COSMOS_DB_DATABASE"),
    cosmos_container=os.getenv("COSMOS_DB_CONTAINER"),
    session_id=conversation_id
)
```

### Implementar RAG / Implement RAG

Agrega Azure Cognitive Search como vector store:

Add Azure Cognitive Search as vector store:

```python
from langchain.vectorstores.azuresearch import AzureSearch
from langchain.embeddings import AzureOpenAIEmbeddings

embeddings = AzureOpenAIEmbeddings(
    deployment=os.getenv("AZURE_OPENAI_EMBEDDING_DEPLOYMENT"),
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
)

vector_store = AzureSearch(
    azure_search_endpoint=os.getenv("AZURE_SEARCH_ENDPOINT"),
    azure_search_key=os.getenv("AZURE_SEARCH_KEY"),
    index_name="langchain-index",
    embedding_function=embeddings.embed_query,
)
```

## Troubleshooting

### Error: "Module not found"
Asegúrate de instalar todas las dependencias:
```bash
pip install -r requirements-langchain.txt
```

### Error: "Authentication failed"
Verifica que tus credenciales de Azure sean correctas en el archivo `.env`

### Error: "Rate limit exceeded"
Aumenta el TPM (Tokens Per Minute) en tu deployment de Azure OpenAI o implementa rate limiting

## Recursos / Resources

- [Documentación de LangChain](https://python.langchain.com/)
- [Azure OpenAI Service](https://learn.microsoft.com/azure/ai-services/openai/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

## Licencia / License

Este ejemplo está disponible bajo la licencia MIT.

This example is available under the MIT license.
