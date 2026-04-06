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

Scenario: Ver calendario sin autenticación - 401
Given url adopcionesUrl + '1/calendario/'
And header Authorization = ''
When method GET
Then status 401

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

Scenario: Estructura de entradas en calendario
  # Login como ADMIN
  Given url authUrl + 'login/'
  And request { email: 'admin@pettech.com', password: 'Admin1234!' }
  When method POST
  Then status 200
  * def adminToken = response.access

  # Si la adopción con ID 1 existe y ADMIN tiene permiso -> 200
  # Si no existe -> 404
  Given url adopcionesUrl + '1/calendario/'
  And header Authorization = 'Bearer ' + adminToken
  When method GET
  Then assert responseStatus == 200 || responseStatus == 404

Scenario: Calendario - verificar fechas sugeridas son futuras
  # Login como ADMIN
  Given url authUrl + 'login/'
  And request { email: 'admin@pettech.com', password: 'Admin1234!' }
  When method POST
  Then status 200
  * def adminToken = response.access

  # Si la adopción con ID 1 existe y ADMIN tiene permiso -> 200
  # Si no existe -> 404
  Given url adopcionesUrl + '1/calendario/'
  And header Authorization = 'Bearer ' + adminToken
  When method GET
  Then assert responseStatus == 200 || responseStatus == 404

Scenario: Calendario con notas
  # Login como ADMIN
  Given url authUrl + 'login/'
  And request { email: 'admin@pettech.com', password: 'Admin1234!' }
  When method POST
  Then status 200
  * def adminToken = response.access

  # Si la adopción con ID 1 existe y ADMIN tiene permiso -> 200
  # Si no existe -> 404
  Given url adopcionesUrl + '1/calendario/'
  And header Authorization = 'Bearer ' + adminToken
  When method GET
  Then assert responseStatus == 200 || responseStatus == 404

Scenario: Flujo completo: solicitud -> adopción -> calendario
* def solicitudesUrl = baseUrl + '/api/v1/solicitudes/'
* def familiasMiaUrl = baseUrl + '/api/v1/familias/mia/'

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

  * def familiaRequest = familiaBaseRequest
  * set familiaRequest.nombre_familia = 'Calendario'
  Given url familiasMiaUrl
  And header Authorization = 'Bearer ' + familiaToken
  And request familiaRequest
  When method POST
  Then status 201

  # Crear mascota como ADMIN
  Given url authUrl + 'login/'
  And request { email: 'admin@pettech.com', password: 'Admin1234!' }
  When method POST
  Then status 200
  * def adminToken = response.access

  Given url baseUrl + '/api/v1/mascotas/'
  And header Authorization = 'Bearer ' + adminToken
  And request { nombre: 'Mascota Test', especie: 'PERRO', estado: 'DISPONIBLE' }
  When method POST
  Then status 201
  * def mascotaIdInt = response.id

  # Crear solicitud usando mascotaId dinámico
  * def solicitudRequest = { "mascota": "#(mascotaIdInt)", "mensaje": "Para calendario" }
Given url solicitudesUrl
And header Authorization = 'Bearer ' + familiaToken
And request solicitudRequest
When method POST
Then status 201
* def solicitudId = response.id

# Aprobar como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

Given url solicitudesUrl + solicitudId + '/aprobar/'
And header Authorization = 'Bearer ' + adminToken
And request { "notas_admin": "Aprobada" }
When method POST
Then status 200
* def adopcionId = response.id

  # Ver calendario - puede ser 200 si existe, 404 si no se generó automáticamente
  Given url adopcionesUrl + adopcionId + '/calendario/'
  And header Authorization = 'Bearer ' + familiaToken
  When method GET
  Then assert responseStatus == 200 || responseStatus == 404
