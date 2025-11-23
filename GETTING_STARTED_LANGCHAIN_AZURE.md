# Guía Rápida: LangChain en Azure / Quick Start: LangChain on Azure

## 🚀 Inicio Rápido / Quick Start

Esta guía te ayudará a comenzar con LangChain en Azure en minutos.

This guide will help you get started with LangChain on Azure in minutes.

## 📚 Documentación / Documentation

Este repositorio incluye toda la documentación necesaria para desplegar LangChain en Azure:

This repository includes all necessary documentation to deploy LangChain on Azure:

### 1. [Guía de Agentes de Copilot](./COPILOT_AGENTS_GUIDE.md)
**¿Qué aprenderás?** / **What will you learn?**
- Qué son los agentes de GitHub Copilot (`@workspace`, `@terminal`, `@azure`, etc.)
- Para qué sirve cada agente (`@cli`, `@cloud`)
- Cómo usar los agentes para desplegar LangChain
- Mejores prácticas y ejemplos

**Comienza aquí si:** / **Start here if:**
- ✅ Quieres entender los agentes de Copilot
- ✅ Necesitas saber qué hace `@cli` o `@cloud`
- ✅ Quieres optimizar tu flujo de trabajo con Copilot

### 2. [Guía Completa de Despliegue](./AZURE_LANGCHAIN_DEPLOYMENT.md)
**¿Qué aprenderás?** / **What will you learn?**
- Qué servicios de Azure necesitas para LangChain
- Cómo desplegar con Azure App Service (principiantes)
- Cómo desplegar con Azure Container Apps (producción)
- Cómo usar Azure Functions para procesamiento asíncrono
- Arquitectura recomendada y mejores prácticas
- Costos estimados y troubleshooting

**Comienza aquí si:** / **Start here if:**
- ✅ Necesitas desplegar una aplicación LangChain
- ✅ Quieres conocer todos los servicios de Azure disponibles
- ✅ Buscas una arquitectura de producción completa

### 3. [Ejemplo Práctico](./examples/)
**¿Qué incluye?** / **What's included?**
- Aplicación FastAPI funcional con LangChain
- Integración con Azure OpenAI
- Dockerfile y configuración de despliegue
- Script de despliegue automatizado
- Documentación completa

**Comienza aquí si:** / **Start here if:**
- ✅ Quieres código que funcione de inmediato
- ✅ Prefieres aprender con ejemplos
- ✅ Necesitas una base para tu proyecto

## 🎯 Respuestas Rápidas / Quick Answers

### ¿Qué servicios de Azure necesito?

**Mínimo para comenzar:**
1. **Azure OpenAI Service** - Para usar GPT-4 / GPT-3.5
2. **Azure App Service** - Para hospedar tu aplicación

**Para producción también considera:**
3. **Azure Cognitive Search** - Para búsqueda vectorial (RAG)
4. **Azure Cosmos DB** - Para persistir conversaciones
5. **Azure Key Vault** - Para manejar secrets de forma segura

👉 [Ver detalles completos](./AZURE_LANGCHAIN_DEPLOYMENT.md#servicios-de-azure-necesarios--required-azure-services)

### ¿Cómo despliego rápidamente?

**Opción 1: Usa el ejemplo práctico**

```bash
cd examples
./deploy-to-azure.sh
```

👉 [Ver instrucciones completas](./examples/README.md)

**Opción 2: Sigue la guía paso a paso**

👉 [Ver guía de despliegue](./AZURE_LANGCHAIN_DEPLOYMENT.md#guía-de-despliegue--deployment-guide)

### ¿Qué hace el agente @azure?

El agente `@azure` (también llamado `@cloud`) es un experto en servicios de Azure que te ayuda con:
- Diseñar arquitecturas
- Configurar servicios
- Resolver problemas de despliegue
- Optimizar costos

**Ejemplo de uso:**
```
@azure ¿Qué servicios necesito para desplegar LangChain con RAG?
```

👉 [Ver guía completa de agentes](./COPILOT_AGENTS_GUIDE.md#5-azure-o-cloud)

### ¿Qué hace el agente @cli?

El agente `@cli` (también llamado `@terminal`) te ayuda con comandos de terminal:
- Generar comandos de Azure CLI
- Explicar errores
- Automatizar tareas

**Ejemplo de uso:**
```
@cli Genera comandos para desplegar a Azure Container Apps
```

👉 [Ver guía completa de agentes](./COPILOT_AGENTS_GUIDE.md#2-terminal-o-cli)

## 📖 Flujo de Aprendizaje Recomendado / Recommended Learning Flow

### Para Principiantes / For Beginners

1. **Lee:** [Guía de Agentes](./COPILOT_AGENTS_GUIDE.md) (15 min)
   - Entiende las herramientas disponibles

2. **Explora:** [Ejemplo Práctico](./examples/README.md) (20 min)
   - Ejecuta la aplicación localmente
   - Prueba los endpoints

3. **Despliega:** Usa el script automatizado (30 min)
   ```bash
   cd examples
   ./deploy-to-azure.sh
   ```

4. **Personaliza:** Modifica el ejemplo para tu caso de uso

### Para Usuarios Avanzados / For Advanced Users

1. **Lee:** [Guía de Despliegue](./AZURE_LANGCHAIN_DEPLOYMENT.md)
   - Sección de arquitectura de producción
   - Mejores prácticas de seguridad

2. **Implementa:** RAG con Azure Cognitive Search
   - [Ver ejemplo](./AZURE_LANGCHAIN_DEPLOYMENT.md#ejemplo-completo-rag-con-azure)

3. **Optimiza:** Monitoreo y costos
   - Application Insights
   - Cost Management

## 🔧 Comandos Útiles / Useful Commands

### Verificar configuración de Azure
```bash
az account show
az account list-locations -o table
```

### Crear recursos básicos
```bash
# Crear grupo de recursos
az group create --name langchain-rg --location eastus

# Listar grupos de recursos
az group list -o table
```

### Desplegar aplicación
```bash
# Desde el directorio examples/
cd examples

# Despliegue interactivo
./deploy-to-azure.sh

# O con comandos individuales
az webapp up --resource-group langchain-rg --name my-app
```

### Ver logs
```bash
# App Service
az webapp log tail --resource-group langchain-rg --name my-app

# Container Apps
az containerapp logs show --resource-group langchain-rg --name my-app --follow
```

## 💡 Consejos Pro / Pro Tips

### Usa Copilot para Acelerar el Desarrollo

1. **Pregunta a @azure antes de crear recursos:**
   ```
   @azure ¿Qué SKU de App Service recomiendas para una app de prueba?
   ```

2. **Usa @workspace para entender código:**
   ```
   @workspace Muéstrame dónde se configura Azure OpenAI
   ```

3. **Usa @terminal para comandos complejos:**
   ```
   @terminal Crea un script que despliegue y configure todo
   ```

### Optimiza Costos

- Comienza con **Azure App Service B1** (~$13/mes)
- Usa **Azure OpenAI Serverless** (pago por uso)
- Implementa **caché** para reducir llamadas a la API
- Configura **autoscaling** en Container Apps

👉 [Ver costos estimados](./AZURE_LANGCHAIN_DEPLOYMENT.md#costos-estimados)

### Seguridad

- ✅ Usa **Azure Key Vault** para secrets
- ✅ Habilita **Managed Identity**
- ✅ Configura **CORS** correctamente
- ✅ Nunca cometas archivos `.env`

👉 [Ver mejores prácticas](./AZURE_LANGCHAIN_DEPLOYMENT.md#mejores-prácticas--best-practices)

## 🆘 Solución de Problemas / Troubleshooting

### Error: "Authentication failed"
**Solución:** Verifica tus credenciales de Azure OpenAI

```bash
# Verificar variables de entorno
az webapp config appsettings list --name my-app --resource-group langchain-rg
```

### Error: "Module not found"
**Solución:** Instala dependencias

```bash
pip install -r requirements-langchain.txt
```

### Error: "Rate limit exceeded"
**Solución:** Aumenta TPM en Azure OpenAI o implementa rate limiting

👉 [Ver más problemas comunes](./AZURE_LANGCHAIN_DEPLOYMENT.md#troubleshooting-común)

## 📊 Arquitectura Típica / Typical Architecture

```
Usuario / User
    ↓
Azure Front Door (CDN + WAF)
    ↓
Azure Container Apps (LangChain App)
    ↓
    ├─→ Azure OpenAI (LLM)
    ├─→ Azure Cognitive Search (Vector DB)
    └─→ Azure Cosmos DB (Chat History)
```

👉 [Ver arquitectura detallada](./AZURE_LANGCHAIN_DEPLOYMENT.md#arquitectura-recomendada-para-producción)

## 🌟 Próximos Pasos / Next Steps

1. **Experimenta con el ejemplo**
   - Ejecuta localmente
   - Modifica los prompts
   - Agrega nuevos endpoints

2. **Despliega a Azure**
   - Usa App Service para empezar
   - Migra a Container Apps cuando necesites escalar

3. **Agrega funcionalidades**
   - Implementa RAG con Azure Cognitive Search
   - Agrega memoria persistente con Cosmos DB
   - Integra Application Insights para monitoreo

4. **Optimiza**
   - Implementa caché
   - Configura autoscaling
   - Optimiza costos

## 📚 Recursos Adicionales / Additional Resources

### Oficial / Official
- [Azure OpenAI Documentation](https://learn.microsoft.com/azure/ai-services/openai/)
- [LangChain Documentation](https://python.langchain.com/)
- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)

### Herramientas / Tools
- [Azure Portal](https://portal.azure.com/)
- [Azure CLI Documentation](https://learn.microsoft.com/cli/azure/)
- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)

### Comunidad / Community
- [LangChain Community](https://github.com/langchain-ai/langchain)
- [Azure Developer Community](https://techcommunity.microsoft.com/azure)

## 🤝 Contribuciones / Contributions

¿Encontraste un error o quieres mejorar la documentación?
- Abre un issue
- Envía un pull request
- Comparte tus experiencias

## 📄 Licencia / License

Este proyecto está bajo la licencia MIT. Ver [LICENSE](./LICENSE) para más detalles.

---

## Resumen de Archivos / File Summary

| Archivo | Propósito | ¿Cuándo usarlo? |
|---------|-----------|-----------------|
| `COPILOT_AGENTS_GUIDE.md` | Guía de agentes de Copilot | Entender @azure, @cli |
| `AZURE_LANGCHAIN_DEPLOYMENT.md` | Guía completa de despliegue | Desplegar a producción |
| `examples/` | Código funcional | Comenzar rápido |
| `examples/README.md` | Quick start del ejemplo | Primera vez |
| `examples/deploy-to-azure.sh` | Script de despliegue | Automatizar despliegue |

---

**¡Comienza ahora!** / **Start now!**

```bash
# 1. Clona el repositorio (si aún no lo has hecho)
git clone <repo-url>

# 2. Ve al directorio de ejemplos
cd examples

# 3. Lee el README
cat README.md

# 4. Ejecuta localmente
python langchain_azure_example.py

# 5. Despliega a Azure
./deploy-to-azure.sh
```

**¡Feliz desarrollo!** 🚀 / **Happy coding!** 🚀
