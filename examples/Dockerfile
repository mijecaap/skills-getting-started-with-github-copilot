# Dockerfile para aplicación LangChain con Azure OpenAI
# Dockerfile for LangChain application with Azure OpenAI

# Usar imagen base de Python
FROM python:3.11-slim

# Establecer directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema si son necesarias
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copiar archivos de dependencias
COPY requirements-langchain.txt .

# Instalar dependencias de Python
RUN pip install --no-cache-dir -r requirements-langchain.txt

# Copiar el código de la aplicación
COPY langchain_azure_example.py .

# Exponer puerto
EXPOSE 8000

# Configurar variables de entorno por defecto
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Comando para ejecutar la aplicación
CMD ["uvicorn", "langchain_azure_example:app", "--host", "0.0.0.0", "--port", "8000"]
