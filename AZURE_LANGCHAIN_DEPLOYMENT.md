# Despliegue de LangChain en Azure / Deploying LangChain on Azure

## Servicios de Azure Necesarios / Required Azure Services

Para desplegar una aplicación LangChain en Azure, necesitarás los siguientes servicios:

### 1. **Azure App Service** o **Azure Container Apps**
- **App Service**: Para aplicaciones web tradicionales con LangChain
- **Container Apps**: Para aplicaciones basadas en contenedores con escalado automático
- **Cuándo usar**: Aplicaciones web, APIs REST con LangChain

### 2. **Azure OpenAI Service**
- Proporciona acceso a modelos GPT-4, GPT-3.5, y embeddings
- Integración nativa con LangChain
- **Esencial para**: Aplicaciones que usan modelos de lenguaje

### 3. **Azure Cosmos DB** o **Azure SQL Database**
- **Cosmos DB**: Base de datos NoSQL para almacenar conversaciones y vectores
- **Azure SQL**: Base de datos relacional para datos estructurados
- **Cuándo usar**: Persistencia de historial de chat, almacenamiento de datos

### 4. **Azure Cognitive Search (AI Search)**
- Búsqueda vectorial para RAG (Retrieval Augmented Generation)
- Almacenamiento y búsqueda de embeddings
- **Cuándo usar**: Aplicaciones con búsqueda semántica

### 5. **Azure Functions**
- Ejecución serverless de agentes LangChain
- **Cuándo usar**: Procesamiento asíncrono, webhooks, tareas programadas

### 6. **Azure Key Vault**
- Almacenamiento seguro de API keys y secrets
- **Esencial para**: Gestión segura de credenciales

### 7. **Azure Storage**
- Almacenamiento de documentos, embeddings, y datos
- **Cuándo usar**: Almacenar documentos para RAG

## Guía de Despliegue / Deployment Guide

### Opción 1: Azure App Service (Recomendado para principiantes)

#### Paso 1: Preparar tu aplicación LangChain

```python
# app.py
from fastapi import FastAPI
from langchain_openai import AzureChatOpenAI
from langchain.schema import HumanMessage
import os

app = FastAPI()

# Configurar Azure OpenAI
llm = AzureChatOpenAI(
    deployment_name=os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
    openai_api_version="2024-02-15-preview",
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
)

@app.post("/chat")
async def chat(message: str):
    response = llm.invoke([HumanMessage(content=message)])
    return {"response": response.content}
```

#### Paso 2: Crear requirements.txt

```txt
fastapi
uvicorn[standard]
langchain
langchain-openai
openai
python-dotenv
```

#### Paso 3: Desplegar a Azure App Service

```bash
# 1. Instalar Azure CLI
az login

# 2. Crear un grupo de recursos
az group create --name langchain-rg --location eastus

# 3. Crear un App Service Plan
az appservice plan create --name langchain-plan --resource-group langchain-rg --sku B1 --is-linux

# 4. Crear la Web App
az webapp create --resource-group langchain-rg --plan langchain-plan --name my-langchain-app --runtime "PYTHON:3.11"

# 5. Configurar variables de entorno
az webapp config appsettings set --resource-group langchain-rg --name my-langchain-app --settings \
    AZURE_OPENAI_ENDPOINT="https://your-endpoint.openai.azure.com/" \
    AZURE_OPENAI_API_KEY="your-key" \
    AZURE_OPENAI_DEPLOYMENT_NAME="gpt-4"

# 6. Desplegar código
az webapp up --resource-group langchain-rg --name my-langchain-app
```

### Opción 2: Azure Container Apps (Recomendado para producción)

#### Paso 1: Crear Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

#### Paso 2: Desplegar con Container Apps

```bash
# 1. Crear un Container Registry
az acr create --resource-group langchain-rg --name mylangchainacr --sku Basic

# 2. Construir y subir la imagen
az acr build --registry mylangchainacr --image langchain-app:v1 .

# 3. Crear Container App Environment
az containerapp env create --name langchain-env --resource-group langchain-rg --location eastus

# 4. Crear Container App
az containerapp create \
    --name langchain-app \
    --resource-group langchain-rg \
    --environment langchain-env \
    --image mylangchainacr.azurecr.io/langchain-app:v1 \
    --target-port 8000 \
    --ingress external \
    --registry-server mylangchainacr.azurecr.io \
    --env-vars \
        AZURE_OPENAI_ENDPOINT="https://your-endpoint.openai.azure.com/" \
        AZURE_OPENAI_API_KEY=secretref:openai-key

# 5. Agregar secrets
az containerapp secret set --name langchain-app --resource-group langchain-rg \
    --secrets openai-key="your-actual-key"
```

### Opción 3: Azure Functions (Para procesamiento asíncrono)

#### Paso 1: Crear Azure Function

```python
# function_app.py
import azure.functions as func
from langchain_openai import AzureChatOpenAI
from langchain.schema import HumanMessage
import os

app = func.FunctionApp()

@app.route(route="chat", methods=["POST"])
def chat_function(req: func.HttpRequest) -> func.HttpResponse:
    try:
        req_body = req.get_json()
        message = req_body.get('message')
        
        llm = AzureChatOpenAI(
            deployment_name=os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
            azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
            api_key=os.getenv("AZURE_OPENAI_API_KEY"),
        )
        
        response = llm.invoke([HumanMessage(content=message)])
        
        return func.HttpResponse(
            response.content,
            status_code=200
        )
    except Exception as e:
        return func.HttpResponse(
            str(e),
            status_code=500
        )
```

#### Paso 2: Desplegar Function

```bash
# 1. Crear Storage Account
az storage account create --name langchainstorage --resource-group langchain-rg --location eastus

# 2. Crear Function App
az functionapp create \
    --resource-group langchain-rg \
    --consumption-plan-location eastus \
    --runtime python \
    --runtime-version 3.11 \
    --functions-version 4 \
    --name my-langchain-function \
    --storage-account langchainstorage

# 3. Configurar settings
az functionapp config appsettings set --name my-langchain-function --resource-group langchain-rg \
    --settings AZURE_OPENAI_ENDPOINT="your-endpoint" AZURE_OPENAI_API_KEY="your-key"

# 4. Desplegar
func azure functionapp publish my-langchain-function
```

## Arquitectura Recomendada para Producción

```
┌─────────────────────────────────────────────────────────────┐
│                      Azure Front Door                       │
│                    (CDN + WAF + Load Balancer)              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Azure Container Apps                        │
│                  (LangChain Application)                     │
└─────────────────────────────────────────────────────────────┘
          │                    │                    │
          ▼                    ▼                    ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ Azure OpenAI     │  │ Azure Cognitive  │  │ Azure Cosmos DB  │
│ Service          │  │ Search           │  │                  │
│ (LLM Models)     │  │ (Vector Search)  │  │ (Chat History)   │
└──────────────────┘  └──────────────────┘  └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │ Azure Storage    │
                    │ (Documents)      │
                    └──────────────────┘
```

## Mejores Prácticas / Best Practices

### 1. Seguridad
- **Usar Azure Key Vault** para almacenar secrets
- **Habilitar Managed Identity** para autenticación sin passwords
- **Configurar Network Security Groups** para restringir acceso

```bash
# Habilitar Managed Identity
az webapp identity assign --name my-langchain-app --resource-group langchain-rg

# Dar acceso a Key Vault
az keyvault set-policy --name my-keyvault --object-id <identity-id> --secret-permissions get list
```

### 2. Escalabilidad
- **Usar Azure Container Apps** con autoscaling
- **Implementar caché** con Azure Cache for Redis
- **Usar Azure CDN** para contenido estático

### 3. Monitoreo
- **Azure Application Insights** para telemetría
- **Log Analytics** para logs centralizados
- **Azure Monitor** para alertas

```python
# Agregar Application Insights
from opencensus.ext.azure.log_exporter import AzureLogHandler
import logging

logger = logging.getLogger(__name__)
logger.addHandler(AzureLogHandler(
    connection_string='InstrumentationKey=your-key'
))
```

### 4. Costos
- **Usar Azure Cost Management** para tracking
- **Implementar rate limiting** en la API
- **Usar reserved instances** para ahorros

## Ejemplo Completo: RAG con Azure

```python
# rag_app.py
from langchain_openai import AzureChatOpenAI, AzureOpenAIEmbeddings
from langchain_community.vectorstores import AzureSearch
from langchain.chains import RetrievalQA
from langchain_community.document_loaders import AzureBlobStorageContainerLoader
import os

# Configurar componentes
llm = AzureChatOpenAI(
    deployment_name=os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
)

embeddings = AzureOpenAIEmbeddings(
    deployment=os.getenv("AZURE_OPENAI_EMBEDDING_DEPLOYMENT"),
    azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
    api_key=os.getenv("AZURE_OPENAI_API_KEY"),
)

# Configurar Azure Cognitive Search como vector store
vector_store = AzureSearch(
    azure_search_endpoint=os.getenv("AZURE_SEARCH_ENDPOINT"),
    azure_search_key=os.getenv("AZURE_SEARCH_KEY"),
    index_name="langchain-index",
    embedding_function=embeddings.embed_query,
)

# Crear cadena RAG
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vector_store.as_retriever(search_kwargs={"k": 3}),
)

# Usar la cadena
response = qa_chain.run("¿Cuál es el proceso de inscripción?")
```

## Recursos Adicionales / Additional Resources

- [Azure OpenAI Service Documentation](https://learn.microsoft.com/azure/ai-services/openai/)
- [LangChain Documentation](https://python.langchain.com/)
- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Azure Cognitive Search Vector Search](https://learn.microsoft.com/azure/search/vector-search-overview)

## Troubleshooting Común

### Error: "Rate limit exceeded"
**Solución**: Aumentar TPM (Tokens Per Minute) en Azure OpenAI o implementar retry logic

```python
from langchain.llms import AzureOpenAI
from langchain.callbacks import RetryCallback

llm = AzureOpenAI(
    max_retries=3,
    request_timeout=60,
)
```

### Error: "Authentication failed"
**Solución**: Verificar que las variables de entorno estén configuradas correctamente

```bash
az webapp config appsettings list --name my-langchain-app --resource-group langchain-rg
```

### Error: "Module not found"
**Solución**: Asegurar que requirements.txt incluya todas las dependencias

```bash
pip freeze > requirements.txt
```

## Costos Estimados

**Nota**: Los precios pueden variar. Consulta [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) para precios actualizados.

Para una aplicación pequeña-mediana (estimación aproximada):
- **Azure App Service (B1)**: ~$13/mes
- **Azure OpenAI (Pay-as-you-go)**: Varía según uso (~$0.002/1K tokens)
- **Azure Cosmos DB (Serverless)**: ~$0.25/million RU
- **Azure Cognitive Search (Basic)**: ~$75/mes
- **Azure Storage**: ~$0.02/GB/mes

**Total estimado**: $90-150/mes para comenzar

## Conclusión

Desplegar LangChain en Azure es sencillo y escalable. Los servicios clave son:
1. **Azure OpenAI Service** - El cerebro de tu aplicación
2. **Azure App Service/Container Apps** - Hosting de la aplicación
3. **Azure Cognitive Search** - Para búsqueda vectorial (RAG)
4. **Azure Cosmos DB** - Para persistencia
5. **Azure Key Vault** - Para seguridad

¡Comienza con Azure App Service para proyectos simples y migra a Container Apps cuando necesites más escalabilidad!
