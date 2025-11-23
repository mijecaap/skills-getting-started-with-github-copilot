#!/bin/bash

# Script para desplegar aplicación LangChain en Azure
# Script to deploy LangChain application to Azure

set -e

echo "================================================"
echo "   Despliegue de LangChain en Azure"
echo "   LangChain Deployment to Azure"
echo "================================================"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que Azure CLI está instalado
if ! command -v az &> /dev/null; then
    print_error "Azure CLI no está instalado. Instálalo desde: https://docs.microsoft.com/cli/azure/install-azure-cli"
    print_error "Azure CLI is not installed. Install it from: https://docs.microsoft.com/cli/azure/install-azure-cli"
    exit 1
fi

print_info "Azure CLI encontrado"

# Login a Azure
print_info "Verificando sesión de Azure..."
if ! az account show &> /dev/null; then
    print_warning "No hay sesión activa. Iniciando login..."
    az login
fi

print_info "Sesión de Azure activa"

# Configuración
read -p "Nombre del grupo de recursos [langchain-rg]: " RESOURCE_GROUP
RESOURCE_GROUP=${RESOURCE_GROUP:-langchain-rg}

read -p "Ubicación de Azure [eastus]: " LOCATION
LOCATION=${LOCATION:-eastus}

read -p "Nombre de la aplicación [my-langchain-app]: " APP_NAME
APP_NAME=${APP_NAME:-my-langchain-app}

read -p "Tipo de despliegue (1=App Service, 2=Container Apps) [1]: " DEPLOY_TYPE
DEPLOY_TYPE=${DEPLOY_TYPE:-1}

# Variables de entorno de Azure OpenAI
echo ""
print_warning "Configuración de Azure OpenAI requerida:"
print_warning "NOTA: Para producción, considera usar Azure Key Vault en lugar de variables de entorno"
print_warning "NOTE: For production, consider using Azure Key Vault instead of environment variables"
read -p "Azure OpenAI Endpoint: " AZURE_OPENAI_ENDPOINT
read -s -p "Azure OpenAI API Key (oculto/hidden): " AZURE_OPENAI_API_KEY
echo ""
read -p "Azure OpenAI Deployment Name [gpt-4]: " AZURE_OPENAI_DEPLOYMENT_NAME
AZURE_OPENAI_DEPLOYMENT_NAME=${AZURE_OPENAI_DEPLOYMENT_NAME:-gpt-4}

# Crear grupo de recursos
print_info "Creando grupo de recursos: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

if [ "$DEPLOY_TYPE" == "1" ]; then
    # Desplegar con App Service
    print_info "Desplegando con Azure App Service..."
    
    PLAN_NAME="${APP_NAME}-plan"
    
    # Crear App Service Plan
    print_info "Creando App Service Plan: $PLAN_NAME"
    az appservice plan create \
        --name "$PLAN_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --sku B1 \
        --is-linux
    
    # Crear Web App
    print_info "Creando Web App: $APP_NAME"
    az webapp create \
        --resource-group "$RESOURCE_GROUP" \
        --plan "$PLAN_NAME" \
        --name "$APP_NAME" \
        --runtime "PYTHON:3.11"
    
    # Configurar variables de entorno
    print_info "Configurando variables de entorno..."
    az webapp config appsettings set \
        --resource-group "$RESOURCE_GROUP" \
        --name "$APP_NAME" \
        --settings \
            AZURE_OPENAI_ENDPOINT="$AZURE_OPENAI_ENDPOINT" \
            AZURE_OPENAI_API_KEY="$AZURE_OPENAI_API_KEY" \
            AZURE_OPENAI_DEPLOYMENT_NAME="$AZURE_OPENAI_DEPLOYMENT_NAME" \
            AZURE_OPENAI_API_VERSION="2024-02-15-preview"
    
    # Desplegar código
    print_info "Desplegando código..."
    
    # Crear un archivo zip con el código
    print_info "Preparando archivos para despliegue..."
    zip -r deploy.zip langchain_azure_example.py requirements-langchain.txt
    
    # Desplegar zip
    az webapp deployment source config-zip \
        --resource-group "$RESOURCE_GROUP" \
        --name "$APP_NAME" \
        --src deploy.zip
    
    # Limpiar
    rm deploy.zip
    
    # Obtener URL
    APP_URL=$(az webapp show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$APP_NAME" \
        --query defaultHostName \
        --output tsv)
    
    echo ""
    print_info "=========================================="
    print_info "Despliegue completado exitosamente!"
    print_info "Deployment completed successfully!"
    print_info "=========================================="
    echo ""
    print_info "URL de la aplicación: https://$APP_URL"
    print_info "Documentación API: https://$APP_URL/docs"
    print_info "Health check: https://$APP_URL/health"
    echo ""
    
elif [ "$DEPLOY_TYPE" == "2" ]; then
    # Desplegar con Container Apps
    print_info "Desplegando con Azure Container Apps..."
    
    ACR_NAME="${APP_NAME//-/}acr"
    ENV_NAME="${APP_NAME}-env"
    
    # Crear Container Registry
    print_info "Creando Azure Container Registry: $ACR_NAME"
    az acr create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$ACR_NAME" \
        --sku Basic \
        --admin-enabled true
    
    # Obtener credenciales de ACR
    ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username --output tsv)
    ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query passwords[0].value --output tsv)
    ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer --output tsv)
    
    # Construir y subir imagen
    print_info "Construyendo y subiendo imagen Docker..."
    az acr build \
        --registry "$ACR_NAME" \
        --image langchain-app:latest .
    
    # Crear Container App Environment
    print_info "Creando Container App Environment: $ENV_NAME"
    az containerapp env create \
        --name "$ENV_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION"
    
    # Crear Container App
    print_info "Creando Container App: $APP_NAME"
    az containerapp create \
        --name "$APP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --environment "$ENV_NAME" \
        --image "$ACR_LOGIN_SERVER/langchain-app:latest" \
        --target-port 8000 \
        --ingress external \
        --registry-server "$ACR_LOGIN_SERVER" \
        --registry-username "$ACR_USERNAME" \
        --registry-password "$ACR_PASSWORD" \
        --env-vars \
            AZURE_OPENAI_ENDPOINT="$AZURE_OPENAI_ENDPOINT" \
            AZURE_OPENAI_API_KEY="$AZURE_OPENAI_API_KEY" \
            AZURE_OPENAI_DEPLOYMENT_NAME="$AZURE_OPENAI_DEPLOYMENT_NAME" \
            AZURE_OPENAI_API_VERSION="2024-02-15-preview" \
        --cpu 0.5 \
        --memory 1.0Gi \
        --min-replicas 0 \
        --max-replicas 10
    
    # Obtener URL
    APP_URL=$(az containerapp show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$APP_NAME" \
        --query properties.configuration.ingress.fqdn \
        --output tsv)
    
    echo ""
    print_info "=========================================="
    print_info "Despliegue completado exitosamente!"
    print_info "Deployment completed successfully!"
    print_info "=========================================="
    echo ""
    print_info "URL de la aplicación: https://$APP_URL"
    print_info "Documentación API: https://$APP_URL/docs"
    print_info "Health check: https://$APP_URL/health"
    echo ""
    print_info "La aplicación usa autoscaling (0-10 réplicas)"
    print_info "The application uses autoscaling (0-10 replicas)"
    echo ""
else
    print_error "Tipo de despliegue no válido"
    exit 1
fi

# Comandos útiles
echo ""
print_info "Comandos útiles / Useful commands:"
echo ""
echo "Ver logs de la aplicación / View application logs:"
if [ "$DEPLOY_TYPE" == "1" ]; then
    echo "  az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME"
else
    echo "  az containerapp logs show --resource-group $RESOURCE_GROUP --name $APP_NAME --follow"
fi
echo ""
echo "Eliminar recursos / Delete resources:"
echo "  az group delete --name $RESOURCE_GROUP --yes"
echo ""

print_info "¡Despliegue completado! / Deployment complete!"
