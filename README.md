# PetTech - Pruebas de API con Karate Framework

Proyecto completo de pruebas de API para el sistema de adopción de mascotas PetTech.

## 📋 Contenido

- [Requisitos](#requisitos)
- [Tecnologías](#tecnologías)
- [Arquitectura SDD](#arquitectura-sdd)
- [Credenciales de Prueba](#credenciales-de-prueba)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Comandos](#comandos)
- [Tags de Ejecución](#tags-de-ejecución)
- [Recursos de la API](#recursos-de-la-api)
- [Casos Edge Cubiertos](#casos-edge-cubiertos)
- [Flujos de Prueba](#flujos-de-prueba)
- [Solución de Problemas](#solución-de-problemas)
- [Reportes](#reportes)
- [Plugins Utilizados](#plugins-utilizados)
- [Contribución](#contribución)

## Requisitos

- Java 11 o superior
- Maven 3.6 o superior
- Backend Django REST corriendo (por defecto: http://localhost:8000)

## Tecnologías

- **Backend**: Django 5.0.6 + Django REST Framework 3.15.2
- **Autenticación**: JWT (djangorestframework-simplejwt 5.3.1)
- **Testing**: Karate Framework 1.4.1 + JUnit 5
- **Gestión de Memoria**: Engram (sistema de memoria persistente)
- **Agentes IA**: OpenCode (orquestador SDD)

## Arquitectura SDD

Este proyecto sigue el enfoque **SDD (Spec-Driven Development)** mediante OpenCode Agents:

```
┌─────────────────────────────────────────────────────────────┐
│  FASES SDD                                                  │
├─────────────────────────────────────────────────────────────┤
│  @sdd-explorar    → Investigación de API y comportamientos  │
│  @sdd-especificar → Definición de escenarios y criterios    │
│  @sdd-disenar     → Decisiones de diseño técnico          │
│  @sdd-implementar → Implementación de tests               │
│  @sdd-verificar   → Depuración y verificación               │
└─────────────────────────────────────────────────────────────┘
```

### Flujo de Trabajo con OpenCode

1. **Exploración**: Agentes investigan el backend, documentan endpoints y comportamientos
2. **Especificación**: Se definen escenarios Gherkin con criterios de aceptación
3. **Diseño**: Se toman decisiones técnicas (patrones, estructura, helpers)
4. **Implementación**: Se escriben los tests Karate siguiendo patrones establecidos
5. **Verificación**: Se ejecutan tests, se documentan fallos y soluciones

### Sistema de Memoria Engram

Las enseñanzas y patrones se almacenan en **Engram** para futuras sesiones:

```bash
# Buscar patrones de implementación
mem_search(query: "@sdd-implementar @patrones", project: "repo-pruebas-api")

# Buscar comportamientos del backend
mem_search(query: "@sdd-explorar @django", project: "repo-pruebas-api")

# Buscar soluciones a errores comunes
mem_search(query: "@sdd-verificar @errores-comunes", project: "repo-pruebas-api")
```

**Tags documentados en Engram:**
- `@sdd-explorar` - Descubrimientos del backend
- `@sdd-especificar` - Especificaciones y escenarios
- `@sdd-disenar` - Patrones de diseño
- `@sdd-implementar` - Código y patrones
- `@sdd-verificar` - Debugging y soluciones

## Credenciales de Prueba

### Usuario Administrador (ADMIN)
```
Email: admin@pettech.com
Password: Admin1234!
Rol: ADMIN
```

### Usuario Familia (FAMILIA)
```
# Se crea dinámicamente en cada escenario
Email: familia_<uuid>@test.com
Password: Test1234!
Rol: FAMILIA
```

### Configuración en karate-config.js
```javascript
var config = {
  baseUrl: 'http://localhost:8000',
  adminEmail: 'admin@pettech.com',
  adminPassword: 'Admin1234!',
  // Tokens se obtienen dinámicamente en cada escenario
};
```

## Estructura del Proyecto

```
src/test/resources/karate/
├── karate-config.js              # Configuración multi-entorno + auth automático
├── helpers/
│   └── auth.feature              # Helper de autenticación reutilizable
├── schemas/                      # JSON Schemas para validación
│   ├── usuario.json
│   ├── mascota.json
│   ├── familia.json
│   ├── condiciones.json
│   ├── solicitud.json
│   ├── adopcion.json
│   └── calendario.json
└── features/
    ├── auth/                     # 3 features
    │   ├── login.feature         # Login exitoso/negativo, JWT validation
    │   ├── registro.feature      # Registro, validaciones
    │   └── refresh.feature       # Token refresh
    ├── mascotas/                 # 4 features
    │   ├── list.feature          # Listado, filtros, paginación
    │   ├── create.feature        # Creación (solo ADMIN)
    │   ├── update.feature        # Actualización, validaciones estado
    │   └── delete.feature        # Eliminación, restricciones
    ├── familias/                 # 3 features
    │   ├── create.feature        # Creación familia (una sola vez)
    │   ├── perfil.feature        # CRUD perfil
    │   └── condiciones.feature   # Condiciones de hogar
    └── adopciones/               # 3 features
        ├── solicitud.feature     # Solicitudes, estados
        ├── aprobar.feature       # Aprobación/rechazo (ADMIN)
        └── calendario.feature    # Calendario vacunación
```

## Configuración

### Entornos (karate-config.js)

```javascript
// Desarrollo (default)
karate.env=dev      → http://localhost:8000

// Staging
karate.env=staging  → https://staging-api.pettech.com

// Producción
karate.env=prod     → https://api.pettech.com
```

### Credenciales de Prueba

Editar `karate-config.js`:

```javascript
adminEmail: 'admin@pettech.com',
adminPassword: 'Admin123!',
familiaEmail: 'familia@test.com',
familiaPassword: 'Familia123!'
```

## Comandos

```bash
# Ejecutar todas las pruebas
mvn clean verify

# Ejecutar con entorno específico
mvn test -Dkarate.env=dev
mvn test -Dkarate.env=staging

# Ejecutar feature específico
mvn test -Dkarate.options="classpath:karate/features/auth/login.feature"
mvn test -Dkarate.options="classpath:karate/features/mascotas/create.feature"

# Ejecutar todos los features de un módulo
mvn test -Dkarate.options="classpath:karate/features/auth"

# Ejecutar con tags
mvn test -Dkarate.options="--tags @smoke"
mvn test -Dkarate.options="--tags @regression"
mvn test -Dkarate.options="--tags @negative"
mvn test -Dkarate.options="--tags @edgecase"

# Generar reporte
mvn test -Dkarate.options="--format html"
mvn serenity:aggregate
```

## Tags de Ejecución

Los escenarios están organizados con tags para ejecución selectiva:

### Tags Principales

| Tag | Descripción | Escenarios |
|-----|-------------|------------|
| `@smoke` | Pruebas críticas/happy path | 32 |
| `@regression` | Pruebas exhaustivas de regresión | 80 |
| `@negative` | Casos negativos (errores, denegados) | 50 |
| `@edgecase` | Casos límite y extremos | 19 |

### Uso de Tags

```bash
# Ejecutar solo smoke tests (rápido)
mvn clean verify -Dkarate.options="--tags @smoke"
# Resultado: 32 tests

# Ejecutar pruebas de regresión completas
mvn clean verify -Dkarate.options="--tags @regression"
# Resultado: 80 tests

# Ejecutar casos negativos
mvn clean verify -Dkarate.options="--tags @negative"
# Resultado: 50 tests

# Ejecutar edge cases
mvn clean verify -Dkarate.options="--tags @edgecase"
# Resultado: 19 tests

# Combinar tags
mvn clean verify -Dkarate.options="--tags @smoke or @negative"
```

## Recursos de la API

### 🔐 Autenticación

| Endpoint | Método | Auth | Descripción |
|----------|--------|------|-------------|
| `/api/v1/auth/login/` | POST | No | Login JWT |
| `/api/v1/auth/registro/` | POST | No | Registro usuario |
| `/api/v1/auth/token/refresh/` | POST | No | Refresh token |
| `/api/v1/auth/perfil/` | GET | Sí | Ver perfil |
| `/api/v1/auth/perfil/` | DELETE | Sí | Eliminar cuenta |

### 🐾 Mascotas

| Endpoint | Método | Auth | Permisos |
|----------|--------|------|----------|
| `/api/v1/mascotas/` | GET | Sí | ADMIN: todas; FAMILIA: disponibles |
| `/api/v1/mascotas/` | POST | Sí | Solo ADMIN |
| `/api/v1/mascotas/{id}/` | GET | Sí | Cualquier autenticado |
| `/api/v1/mascotas/{id}/` | PATCH | Sí | Solo ADMIN |
| `/api/v1/mascotas/{id}/` | DELETE | Sí | Solo ADMIN |

**Filtros**: `?estado=DISPONIBLE&especie=PERRO&page=1&page_size=10`

### 👨‍👩‍👧‍👦 Familias

| Endpoint | Método | Auth | Descripción |
|----------|--------|------|-------------|
| `/api/v1/familias/` | GET | ADMIN | Listar todas |
| `/api/v1/familias/mia/` | GET | Sí | Mi familia |
| `/api/v1/familias/mia/` | POST | Sí | Crear mi familia |
| `/api/v1/familias/mia/` | PATCH | Sí | Actualizar |
| `/api/v1/familias/mia/condiciones-hogar/` | GET/POST/PATCH | Sí | Condiciones hogar |

### 📋 Adopciones

| Endpoint | Método | Auth | Permisos |
|----------|--------|------|----------|
| `/api/v1/solicitudes/` | GET | Sí | Listar solicitudes |
| `/api/v1/solicitudes/` | POST | FAMILIA | Crear solicitud |
| `/api/v1/solicitudes/{id}/` | GET | Sí | Ver solicitud |
| `/api/v1/solicitudes/{id}/` | DELETE | FAMILIA | Cancelar (solo PENDIENTE) |
| `/api/v1/solicitudes/{id}/aprobar/` | POST | ADMIN | Aprobar solicitud |
| `/api/v1/solicitudes/{id}/rechazar/` | POST | ADMIN | Rechazar solicitud |
| `/api/v1/solicitudes/mis-contadores/` | GET | FAMILIA | Contadores |
| `/api/v1/adopciones/` | GET | Sí | Listar adopciones |
| `/api/v1/adopciones/{id}/calendario/` | GET | Sí | Calendario vacunación |

## Casos Edge Cubiertos (24)

### Autenticación
1. Login usuario inexistente (404)
2. Login contraseña incorrecta (401)
3. Registro email duplicado (400)
4. Registro contraseña débil (400)
5. Token expirado (401)
6. Token refresh con token inválido

### Mascotas
7. Crear como FAMILIA → 403
8. Actualizar mascota ADOPTADA → 400
9. Eliminar mascota ADOPTADA → 409
10. Filtros y paginación

### Familias
11. Crear familia duplicada → 400
12. Condiciones sin familia → 400
13. Condiciones duplicadas → 400
14. Edad menor 18 años → 400
15. Condiciones sin acuerdo → 400

### Adopciones
16. Solicitud sin familia → 400
17. Solicitud mascota no disponible → 400
18. ADMIN crea solicitud → 403
19. Aprobar solicitud ya decidida
20. Ver solicitud otra familia → 403
21. Cancelar solicitud no PENDIENTE → 400
22. Ver calendario otra familia → 403
23. Calendario no existe → 404
24. Flujo completo: solicitud → aprobación → adopción → calendario

## Flujos de Prueba

### Flujo 1: Registro y Login
```
POST /auth/registro/ → 201
POST /auth/login/ → 200 (tokens)
GET /auth/perfil/ → 200
```

### Flujo 2: Crear Mascota (ADMIN)
```
POST /auth/login/ (admin) → 200
POST /mascotas/ → 201
GET /mascotas/{id}/ → 200
PATCH /mascotas/{id}/ → 200
DELETE /mascotas/{id}/ → 204
```

### Flujo 3: Completar Adopción
```
POST /auth/login/ (familia) → 200
POST /familias/mia/ → 201
POST /familias/mia/condiciones-hogar/ → 201
POST /solicitudes/ → 201 (PENDIENTE)
POST /auth/login/ (admin) → 200
POST /solicitudes/{id}/aprobar/ → 200 (APROBADA)
GET /adopciones/ → 200
GET /adopciones/{id}/calendario/ → 200
```

## Configuración Avanzada

### Timeouts
```javascript
karate-config.js:
- connectTimeout: 5000ms
- readTimeout: 10000ms
```

### Headers por Defecto
- `Content-Type: application/json`
- `Authorization: Bearer {token}`

### Paginación
```json
{
  "count": 100,
  "next": "http://localhost:8000/api/v1/mascotas/?page=2",
  "previous": null,
  "results": [...]
}
```

## Solución de Problemas

### Error 401 Unauthorized
- Verificar que el token no haya expirado
- Revisar formato del header: `Bearer {token}`

### Error 403 Forbidden
- Verificar rol del usuario (ADMIN vs FAMILIA)
- Algunos endpoints solo permiten ADMIN

### Error 404 Not Found
- Verificar que el recurso exista
- IDs deben ser válidos (enteros positivos)

### Tests fallan por datos inconsistentes
- Asegurar que el backend tenga datos de prueba
- Verificar que mascotas existan con estado DISPONIBLE

## Reportes

Los reportes de Karate se generan en:
```
target/karate-reports/
├── karate-summary.html    # Resumen de todas las pruebas
├── karate-report.json     # Resultados en JSON
└── karate-<feature>.html  # Reporte por feature
```

## Contribución

Para agregar nuevos tests:

1. Crear archivo `.feature` en el módulo correspondiente
2. Reutilizar schemas existentes o crear nuevos
3. Usar `Background` para configuración común
4. Seguir el patrón Given/When/Then
5. Validar respuestas con schemas JSON
6. **Documentar en Engram**: Guardar patrones y aprendizajes usando `mem_save`

## Plugins Utilizados

### Maven Plugins

| Plugin | Versión | Propósito |
|--------|---------|-----------|
| `maven-surefire-plugin` | 3.1.2 | Ejecución de tests |
| `karate-maven-plugin` | 1.4.1 | Integración Karate con Maven |

### Frameworks y Librerías

| Librería | Versión | Uso |
|----------|---------|-----|
| `karate-core` | 1.4.1 | Framework de pruebas API |
| `karate-junit5` | 1.4.1 | Integración con JUnit 5 |
| `cucumber-java` | 7.x | Soporte Gherkin |
| `serenity-core` | 4.x | Reportes (opcional) |

### Herramientas de Desarrollo

| Herramienta | Versión | Descripción |
|-------------|---------|-------------|
| **OpenCode** | Latest | Orquestador de Agentes SDD |
| **Engram** | Latest | Sistema de memoria persistente |
| **Karate IntelliJ Plugin** | Latest | Soporte IDE (syntax highlighting) |

### Instalación de Plugins IDE (VS Code / IntelliJ)

**VS Code:**
```json
// extensions.json
{
  "recommendations": [
    "karateide.karate-ide",
    "cucumberopen.cucumber-official",
    "redhat.vscode-xml"
  ]
}
```

**IntelliJ IDEA:**
- Cucumber for Java (JetBrains)
- Gherkin (JetBrains)
- Karate Plugin (Community)

### Configuración OpenCode

Este proyecto utiliza OpenCode Agents para SDD:

```yaml
# .opencode/config.yaml (opcional)
agents:
  - sdd-explore
  - sdd-spec
  - sdd-design
  - sdd-apply
  - sdd-verify

memory:
  backend: engram
  project: repo-pruebas-api
```

### Comandos de Memoria (Engram)

```bash
# Guardar observación
mem_save(title: "Nuevo Patrón", type: "pattern", content: "...")

# Buscar en memoria
mem_search(query: "@sdd-implementar patrones", project: "repo-pruebas-api")

# Ver contexto del proyecto
mem_context(project: "repo-pruebas-api")
```

## Licencia

MIT License - 2024 PetTech
