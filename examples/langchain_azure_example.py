"""
Ejemplo de aplicación LangChain con Azure OpenAI
Example LangChain application with Azure OpenAI

Este ejemplo muestra cómo crear una aplicación básica con LangChain y Azure OpenAI.
This example shows how to create a basic application with LangChain and Azure OpenAI.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import os
from dotenv import load_dotenv

# Cargar variables de entorno / Load environment variables
load_dotenv()

# Importar LangChain components
try:
    from langchain_openai import AzureChatOpenAI
    from langchain.schema import HumanMessage, SystemMessage, AIMessage
    from langchain.memory import ConversationBufferMemory
    from langchain.chains import ConversationChain
except ImportError:
    print("Por favor instala las dependencias: pip install langchain langchain-openai")
    print("Please install dependencies: pip install langchain langchain-openai")
    raise

app = FastAPI(
    title="LangChain Azure Demo",
    description="Aplicación demo de LangChain con Azure OpenAI",
    version="1.0.0"
)

# Configurar CORS
# NOTA: En producción, reemplaza "*" con dominios específicos
# NOTE: In production, replace "*" with specific domains
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ORIGINS", "*").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Modelos de datos
class ChatRequest(BaseModel):
    message: str
    system_prompt: Optional[str] = "Eres un asistente útil y amigable."

class ChatResponse(BaseModel):
    response: str
    model: str

class ConversationRequest(BaseModel):
    message: str
    conversation_id: Optional[str] = "default"

# Almacenamiento en memoria para conversaciones
# NOTA: En producción con múltiples workers, usa Redis o Cosmos DB
# NOTE: In production with multiple workers, use Redis or Cosmos DB
conversations = {}

def get_azure_llm():
    """
    Configura y retorna el modelo de Azure OpenAI
    Configure and return the Azure OpenAI model
    """
    try:
        llm = AzureChatOpenAI(
            deployment_name=os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME", "gpt-4"),
            openai_api_version=os.getenv("AZURE_OPENAI_API_VERSION", "2024-02-15-preview"),
            azure_endpoint=os.getenv("AZURE_OPENAI_ENDPOINT"),
            api_key=os.getenv("AZURE_OPENAI_API_KEY"),
            temperature=0.7,
        )
        return llm
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error configurando Azure OpenAI: {str(e)}"
        )

@app.get("/")
def root():
    """
    Endpoint raíz con información de la API
    Root endpoint with API information
    """
    return {
        "message": "LangChain + Azure OpenAI API",
        "endpoints": {
            "/chat": "Chat simple (sin memoria)",
            "/conversation": "Chat con memoria de conversación",
            "/health": "Estado de salud de la API"
        },
        "docs": "/docs"
    }

@app.get("/health")
def health_check():
    """
    Verifica que la API y Azure OpenAI estén funcionando
    Check that the API and Azure OpenAI are working
    """
    try:
        # Verificar que las variables de entorno estén configuradas
        required_vars = [
            "AZURE_OPENAI_ENDPOINT",
            "AZURE_OPENAI_API_KEY",
            "AZURE_OPENAI_DEPLOYMENT_NAME"
        ]
        
        missing_vars = [var for var in required_vars if not os.getenv(var)]
        
        if missing_vars:
            return {
                "status": "unhealthy",
                "error": f"Faltan variables de entorno: {', '.join(missing_vars)}"
            }
        
        # Intentar crear el modelo
        llm = get_azure_llm()
        
        return {
            "status": "healthy",
            "azure_endpoint": os.getenv("AZURE_OPENAI_ENDPOINT"),
            "deployment": os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME"),
            "api_version": os.getenv("AZURE_OPENAI_API_VERSION")
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e)
        }

@app.post("/chat", response_model=ChatResponse)
async def simple_chat(request: ChatRequest):
    """
    Chat simple sin memoria de conversación
    Simple chat without conversation memory
    
    Ejemplo / Example:
    {
        "message": "¿Qué servicios de Azure necesito para LangChain?",
        "system_prompt": "Eres un experto en Azure"
    }
    """
    try:
        llm = get_azure_llm()
        
        messages = [
            SystemMessage(content=request.system_prompt),
            HumanMessage(content=request.message)
        ]
        
        response = llm.invoke(messages)
        
        return ChatResponse(
            response=response.content,
            model=os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME", "gpt-4")
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/conversation")
async def conversation_chat(request: ConversationRequest):
    """
    Chat con memoria de conversación
    Chat with conversation memory
    
    Mantiene el contexto de la conversación usando un conversation_id
    Maintains conversation context using a conversation_id
    
    Ejemplo / Example:
    {
        "message": "Hola, soy desarrollador Python",
        "conversation_id": "user123"
    }
    """
    try:
        conversation_id = request.conversation_id
        
        # Crear o recuperar la conversación
        if conversation_id not in conversations:
            llm = get_azure_llm()
            memory = ConversationBufferMemory()
            conversations[conversation_id] = ConversationChain(
                llm=llm,
                memory=memory,
                verbose=True
            )
        
        chain = conversations[conversation_id]
        response = chain.predict(input=request.message)
        
        return {
            "response": response,
            "conversation_id": conversation_id,
            "model": os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME", "gpt-4")
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/conversation/{conversation_id}")
async def clear_conversation(conversation_id: str):
    """
    Borra una conversación de la memoria
    Clear a conversation from memory
    """
    if conversation_id in conversations:
        del conversations[conversation_id]
        return {"message": f"Conversación {conversation_id} eliminada"}
    else:
        raise HTTPException(
            status_code=404,
            detail=f"Conversación {conversation_id} no encontrada"
        )

@app.get("/conversations")
async def list_conversations():
    """
    Lista todas las conversaciones activas
    List all active conversations
    """
    return {
        "active_conversations": list(conversations.keys()),
        "count": len(conversations)
    }

# Ejemplo de uso con streaming (más avanzado)
@app.post("/chat/stream")
async def stream_chat(request: ChatRequest):
    """
    Chat con respuesta en streaming (para implementar después)
    Streaming chat response (to implement later)
    
    Nota: Requiere configuración adicional con SSE o WebSockets
    Note: Requires additional setup with SSE or WebSockets
    """
    return {
        "message": "Streaming no implementado aún. Usa /chat para respuestas síncronas.",
        "note": "Streaming not implemented yet. Use /chat for synchronous responses."
    }

if __name__ == "__main__":
    import uvicorn
    
    print("=" * 60)
    print("🚀 Iniciando aplicación LangChain + Azure OpenAI")
    print("=" * 60)
    print("\n📋 Configuración requerida:")
    print("  - AZURE_OPENAI_ENDPOINT")
    print("  - AZURE_OPENAI_API_KEY")
    print("  - AZURE_OPENAI_DEPLOYMENT_NAME")
    print("\n🌐 Documentación disponible en: http://localhost:8000/docs")
    print("=" * 60 + "\n")
    
    uvicorn.run(app, host="0.0.0.0", port=8000)
