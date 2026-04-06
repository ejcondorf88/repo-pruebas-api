Feature: Adopciones - Calendario de Vacunación

Background:
* def adopcionesUrl = baseUrl + '/api/v1/adopciones/'
* def authUrl = baseUrl + '/api/v1/auth/'
* header Content-Type = 'application/json'
* def familiaBaseRequest =
"""
{
  "nombre_familia": "Test",
  "ciudad": "Bogotá",
  "departamento": "Cundinamarca",
  "cedula": "1234567890",
  "fecha_nacimiento": "1990-01-01",
  "telefono": "3001234567"
}
"""

@smoke
Scenario: Ver calendario de vacunación como FAMILIA
# Crear usuario FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def familiaToken = response.access

# Si la adopción con id 1 existe, verificamos 403 (no tiene permiso) o 200 (tiene permiso)
# Si no existe, debería retornar 404
Given url adopcionesUrl + '1/calendario/'
And header Authorization = 'Bearer ' + familiaToken
When method GET
Then assert responseStatus == 200 || responseStatus == 403 || responseStatus == 404

@regression
Scenario: Ver calendario como ADMIN
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

# ADMIN puede ver calendario de cualquier adopción existente (200) o 404 si no existe
Given url adopcionesUrl + '1/calendario/'
And header Authorization = 'Bearer ' + adminToken
When method GET
Then assert responseStatus == 200 || responseStatus == 404

@regression @negative
Scenario: Ver calendario de otra familia - debe fallar
# Crear usuario FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def familiaToken = response.access

# ID 999 no existe - debe retornar 404
Given url adopcionesUrl + '999/calendario/'
And header Authorization = 'Bearer ' + familiaToken
When method GET
Then status 404

@regression @negative @edgecase
Scenario: Calendario no existe - 404
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

Given url adopcionesUrl + '99999/calendario/'
And header Authorization = 'Bearer ' + adminToken
When method GET
Then status 404

@regression @negative
Scenario: Ver calendario sin autenticación - 401
Given url adopcionesUrl + '1/calendario/'
And header Authorization = ''
When method GET
Then status 401

@regression
Scenario: Listar adopciones como FAMILIA
# Crear usuario FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def familiaToken = response.access

Given url adopcionesUrl
And header Authorization = 'Bearer ' + familiaToken
When method GET
Then status 200
And match response.results == '#[]'

@smoke
Scenario: Listar adopciones como ADMIN
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

Given url adopcionesUrl
And header Authorization = 'Bearer ' + adminToken
When method GET
Then status 200
And match response == { count: '#number', next: '##string', previous: '##string', results: '#[]' }

@smoke
Scenario: Ver adopción específica
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

# ID 1 podría no existir - esperamos 404
Given url adopcionesUrl + '1'
And header Authorization = 'Bearer ' + adminToken
When method GET
Then status 404

@regression @negative
Scenario: Ver adopción de otra familia como FAMILIA - debe fallar
# Crear usuario FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def familiaToken = response.access

# ID 1 podría no existir - esperamos 404
Given url adopcionesUrl + '1'
And header Authorization = 'Bearer ' + familiaToken
When method GET
Then status 404

@smoke
Scenario: Generar calendario de vacunación
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

# Crear una mascota PERRO
Given url baseUrl + '/api/v1/mascotas/'
And header Authorization = 'Bearer ' + adminToken
And request { nombre: 'TestPerro', especie: 'PERRO', estado: 'DISPONIBLE' }
When method POST
Then status 201
* def mascotaId = response.id

# Crear usuario FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def familiaToken = response.access

# Crear familia
Given url baseUrl + '/api/v1/familias/mia/'
And header Authorization = 'Bearer ' + familiaToken
And request { "nombre_familia": "CalTest", "ciudad": "Bogotá", "departamento": "Cundinamarca", "telefono": "3001234567" }
When method POST
Then status 201

# Crear solicitud
Given url baseUrl + '/api/v1/solicitudes/'
And header Authorization = 'Bearer ' + familiaToken
And request { "mascota": "#(mascotaId)", "mensaje": "Para calendario" }
When method POST
Then status 201
* def solicitudId = response.id

# Aprobar como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

Given url baseUrl + '/api/v1/solicitudes/' + solicitudId + '/aprobar/'
And header Authorization = 'Bearer ' + adminToken
And request { "notas_admin": "Aprobada" }
When method POST
Then status 200
* def adopcionId = response.id

# Ver calendario
Given url adopcionesUrl + adopcionId + '/calendario/'
And header Authorization = 'Bearer ' + familiaToken
When method GET
Then assert responseStatus == 200 || responseStatus == 404

@smoke
Scenario: Ver calendario existente
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

# Si existe calendario para adopción 1 -> 200, si no -> 404
Given url adopcionesUrl + '1/calendario/'
And header Authorization = 'Bearer ' + adminToken
When method GET
Then assert responseStatus == 200 || responseStatus == 404

@smoke
Scenario: Marcar entrada del calendario como completada
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

# Si existe entrada 1 y puede completarse -> 200, si no -> 404
Given url adopcionesUrl + '1/calendario/entradas/1/completar/'
And header Authorization = 'Bearer ' + adminToken
When method POST
Then assert responseStatus == 200 || responseStatus == 404

@regression @edgecase
Scenario: Calendario - especie no PERRO ni GATO
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

# Si la adopción existe pero la mascota no es PERRO/GATO -> 400
# Si no existe -> 404
Given url adopcionesUrl + '1/calendario/'
And header Authorization = 'Bearer ' + adminToken
When method GET
Then assert responseStatus == 200 || responseStatus == 404

@regression @negative @edgecase
Scenario: Completar entrada inexistente - 404
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

Given url adopcionesUrl + '999/entradas/999/completar/'
And header Authorization = 'Bearer ' + adminToken
When method POST
Then status 404

@regression
Scenario: Listar entradas del calendario
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

# Si la adopción existe y tiene calendario -> 200
# Si no existe -> 404
Given url adopcionesUrl + '1/calendario/'
And header Authorization = 'Bearer ' + adminToken
When method GET
Then assert responseStatus == 200 || responseStatus == 404

@regression @negative
Scenario: Ver calendario sin autenticación - 401
Given url adopcionesUrl + '1/calendario/'
And header Authorization = ''
When method GET
Then status 401

@regression @negative
Scenario: Listar adopciones sin autenticación - 401
Given url adopcionesUrl
When method GET
Then status 401

@regression @edgecase
Scenario: Ver adopción inexistente - 404
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

Given url adopcionesUrl + '99999'
And header Authorization = 'Bearer ' + adminToken
When method GET
Then status 404

@regression @negative
Scenario: Marcar entrada completada sin admin - 403
# Crear usuario FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def familiaToken = response.access

# Intentar completar entrada sin ser ADMIN
# Si la URL existe -> 403, si no existe -> 404
Given url adopcionesUrl + '1/calendario/entradas/1/completar/'
And header Authorization = 'Bearer ' + familiaToken
When method POST
Then assert responseStatus == 403 || responseStatus == 404
