# Guía de Agentes de GitHub Copilot / GitHub Copilot Agents Guide

## ¿Qué son los Agentes de Copilot? / What are Copilot Agents?

Los agentes de GitHub Copilot (que comienzan con `@`) son asistentes especializados que te ayudan con tareas específicas en diferentes contextos.

## Agentes Principales / Main Agents

### 1. **@workspace**
- **Qué hace**: Entiende todo el contexto de tu workspace/proyecto
- **Para qué sirve**: 
  - Hacer preguntas sobre tu código
  - Encontrar archivos y funciones
  - Entender la arquitectura del proyecto
  - Refactorizar código a nivel de proyecto
- **Ejemplo de uso**:
  ```
  @workspace ¿Dónde se define la función de autenticación?
  @workspace Explica cómo funciona el sistema de rutas
  @workspace Encuentra todos los archivos que usan la API de OpenAI
  ```

### 2. **@terminal** (o @cli)
- **Qué hace**: Ayuda con comandos de terminal y CLI
- **Para qué sirve**:
  - Generar comandos de terminal
  - Explicar errores en la consola
  - Automatizar tareas de línea de comandos
  - Crear scripts
- **Ejemplo de uso**:
  ```
  @terminal ¿Cómo instalo las dependencias de este proyecto?
  @terminal Explica este error de git
  @terminal Crea un comando para hacer backup de la base de datos
  ```

### 3. **@vscode**
- **Qué hace**: Ayuda con funciones y configuración de VS Code
- **Para qué sirve**:
  - Configurar extensiones
  - Personalizar atajos de teclado
  - Resolver problemas de VS Code
  - Aprender funcionalidades del editor
- **Ejemplo de uso**:
  ```
  @vscode ¿Cómo configuro el formateo automático?
  @vscode Muéstrame atajos útiles para refactorización
  @vscode ¿Cómo depuro una aplicación Node.js?
  ```

### 4. **@github**
- **Qué hace**: Interactúa con GitHub (repos, issues, PRs)
- **Para qué sirve**:
  - Buscar información en repositorios
  - Entender issues y pull requests
  - Analizar commits y cambios
  - Trabajar con GitHub Actions
- **Ejemplo de uso**:
  ```
  @github Busca issues relacionados con autenticación
  @github Explica los cambios en el último PR
  @github ¿Cómo configuro un workflow de CI/CD?
  ```

## Agentes Especializados / Specialized Agents

### 5. **@azure** (o @cloud)
- **Qué hace**: Experto en servicios de nube de Azure
- **Para qué sirve**:
  - Diseñar arquitecturas en Azure
  - Configurar servicios de Azure
  - Resolver problemas de despliegue
  - Optimizar costos en Azure
  - **Integración con LangChain en Azure**
- **Ejemplo de uso**:
  ```
  @azure ¿Qué servicios necesito para desplegar una app FastAPI?
  @azure Explica cómo configurar Azure OpenAI Service
  @azure ¿Cómo optimizo los costos de mi Container App?
  @azure Ayúdame a configurar un RAG con Azure Cognitive Search
  ```

### 6. **@python** / **@javascript** / **@java** (Agentes de Lenguaje)
- **Qué hace**: Expertos en lenguajes de programación específicos
- **Para qué sirve**:
  - Escribir código idiomático
  - Resolver problemas específicos del lenguaje
  - Explicar características del lenguaje
  - Debugging especializado
- **Ejemplo de uso**:
  ```
  @python ¿Cómo uso async/await correctamente?
  @javascript Explica closures con ejemplos
  @java ¿Cuáles son las mejores prácticas para streams?
  ```

### 7. **@docker**
- **Qué hace**: Especialista en Docker y containerización
- **Para qué sirve**:
  - Crear Dockerfiles
  - Configurar docker-compose
  - Resolver problemas de containers
  - Optimizar imágenes
- **Ejemplo de uso**:
  ```
  @docker Crea un Dockerfile para mi aplicación Python
  @docker ¿Por qué mi container no puede conectarse a la base de datos?
  @docker Optimiza esta imagen para producción
  ```

## Comparación: @cli vs @terminal

**Son el mismo agente** (o muy similares). Algunos entornos usan `@cli` y otros `@terminal`:

| Característica | @cli / @terminal |
|---------------|------------------|
| **Contexto** | Comandos de terminal |
| **Uso principal** | Generar y explicar comandos |
| **Ejemplos** | git, npm, docker, azure-cli |
| **Plataformas** | Linux, Windows, macOS |

## Comparación: @cloud vs @azure

**@azure** es más específico que **@cloud**:

| @cloud | @azure |
|--------|--------|
| Multi-cloud (AWS, Azure, GCP) | Específico de Azure |
| Conceptos generales | Servicios específicos de Azure |
| Comparaciones entre clouds | Mejores prácticas de Azure |

**Usa @azure cuando**:
- Trabajas específicamente con Azure
- Necesitas detalles de servicios de Azure
- Despliegas a Azure
- Configuras Azure OpenAI, App Service, etc.

**Usa @cloud cuando**:
- Comparas proveedores de nube
- Necesitas conceptos generales de cloud
- Diseñas arquitecturas multi-cloud

## Cómo Usar Agentes Efectivamente

### 1. **Sé Específico**
❌ Malo: `@workspace explica el código`
✅ Bueno: `@workspace explica cómo funciona el sistema de autenticación en auth.py`

### 2. **Usa el Agente Correcto**
❌ Malo: `@terminal ¿cómo despliego a Azure?`
✅ Bueno: `@azure ¿cómo despliego a Azure App Service?`

### 3. **Combina Agentes**
```
@workspace encuentra el archivo de configuración
@azure ayúdame a configurar estas variables en Azure
@terminal genera los comandos para desplegar
```

### 4. **Proporciona Contexto**
```
@azure Tengo una aplicación FastAPI que usa LangChain y Azure OpenAI.
Necesito desplegarla con autoscaling y bajo costo.
¿Qué servicios recomiendas?
```

## Ejemplo Práctico: Desplegar LangChain en Azure

```markdown
Paso 1: Entender el proyecto
@workspace ¿Qué dependencias tiene mi aplicación LangChain?

Paso 2: Preparar el despliegue
@docker Crea un Dockerfile optimizado para mi app Python con LangChain

Paso 3: Configurar Azure
@azure ¿Qué servicios de Azure necesito para LangChain con RAG?

Paso 4: Generar comandos
@terminal Genera los comandos de Azure CLI para:
- Crear Container Registry
- Desplegar a Container Apps
- Configurar Azure OpenAI Service

Paso 5: Configurar CI/CD
@github Crea un workflow de GitHub Actions para desplegar automáticamente
```

## Shortcuts y Tips

### En VS Code Chat:
- `Cmd+I` (Mac) o `Ctrl+I` (Windows): Abrir inline chat
- `Cmd+Shift+I`: Abrir chat lateral
- `/help`: Ver comandos disponibles
- `/clear`: Limpiar conversación

### Comandos Slash Útiles:
- `/explain`: Explica código seleccionado
- `/fix`: Sugiere correcciones
- `/tests`: Genera tests
- `/doc`: Genera documentación

### Agentes en Comentarios:
```python
# @workspace: ¿Cómo puedo optimizar esta función?
def process_data(data):
    # código aquí
    pass
```

## Recursos Adicionales

- [GitHub Copilot Documentation](https://docs.github.com/copilot)
- [Copilot Chat Guide](https://docs.github.com/copilot/using-github-copilot/asking-github-copilot-questions-in-your-ide)
- [Azure OpenAI with Copilot](https://learn.microsoft.com/azure/ai-services/openai/)

## Preguntas Frecuentes

### ¿Puedo crear mis propios agentes?
Actualmente, los agentes están predefinidos por GitHub, pero puedes:
- Usar GitHub Copilot Extensions
- Configurar prompts personalizados
- Crear herramientas custom con APIs

### ¿Los agentes comparten contexto?
Sí, dentro de una misma sesión de chat, los agentes comparten el contexto de la conversación.

### ¿Necesito internet para usar agentes?
Sí, GitHub Copilot requiere conexión a internet para funcionar.

### ¿Los agentes ven mi código?
Los agentes tienen acceso al código que compartes en el contexto de la conversación y pueden acceder a tu workspace cuando usas `@workspace`.

## Mejores Prácticas para LangChain + Azure

1. **Usa @azure para arquitectura**:
   ```
   @azure Diseña una arquitectura escalable para mi app LangChain con:
   - Azure OpenAI para LLM
   - Cognitive Search para vectores
   - Cosmos DB para chat history
   ```

2. **Usa @workspace para código**:
   ```
   @workspace Encuentra todos los lugares donde uso la API de OpenAI
   y ayúdame a migrar a Azure OpenAI
   ```

3. **Usa @terminal para despliegue**:
   ```
   @terminal Genera un script que:
   1. Construya la imagen Docker
   2. La suba a Azure Container Registry
   3. Despliegue a Container Apps
   ```

4. **Usa @docker para containerización**:
   ```
   @docker Optimiza mi Dockerfile para una app Python con LangChain:
   - Usa multi-stage build
   - Minimiza el tamaño de imagen
   - Cachea dependencias de pip
   ```

## Conclusión

Los agentes de Copilot son herramientas poderosas que te ayudan en diferentes aspectos del desarrollo:

- **@workspace**: Para entender y trabajar con tu código
- **@terminal/@cli**: Para comandos y automatización
- **@azure/@cloud**: Para despliegues en la nube
- **@docker**: Para containerización
- **@github**: Para trabajar con repositorios

Para desplegar LangChain en Azure, combina:
1. **@azure** - para configurar servicios
2. **@workspace** - para preparar tu código
3. **@docker** - para containerizar
4. **@terminal** - para ejecutar comandos

¡Experimenta con diferentes agentes y encuentra tu flujo de trabajo ideal! 🚀
