# PetTech - Pruebas de API con Karate Framework

Proyecto completo de pruebas de API para el sistema de adopción de mascotas PetTech.

## Requisitos

- Java 11 o superior
- Maven 3.6 o superior
- Backend Django REST corriendo (por defecto: http://localhost:8000)

## Tecnologías

- **Backend**: Django 5.0.6 + Django REST Framework 3.15.2
- **Autenticación**: JWT (djangorestframework-simplejwt 5.3.1)
- **Testing**: Karate Framework 1.4.1 + JUnit 5

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
mvn test

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

# Generar reporte
mvn test -Dkarate.options="--format html"
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

## Licencia

MIT License - 2024 PetTech
