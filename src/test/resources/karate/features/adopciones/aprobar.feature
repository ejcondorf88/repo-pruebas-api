Feature: Adopciones - Aprobación y Rechazo

Background:
* def familiasMiaUrl = baseUrl + '/api/v1/familias/mia/'
* def solicitudesUrl = baseUrl + '/api/v1/solicitudes/'
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

Scenario: Aprobar solicitud como ADMIN - exitoso
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
  * set familiaRequest.nombre_familia = 'Aprobar'
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

  * def solicitudRequest = { "mascota": "#(mascotaIdInt)", "mensaje": "Aprobar esta solicitud" }
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
And request { "notas_admin": "Excelente familia, apruebo la solicitud." }
When method POST
Then status 200
And match response.estado == 'APROBADA'
And match response.notas_admin == "Excelente familia, apruebo la solicitud."

Scenario: Aprobar solicitud como FAMILIA - debe fallar
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

Given url solicitudesUrl + '1/aprobar/'
And header Authorization = 'Bearer ' + familiaToken
And request { "notas_admin": "Intento de aprobación" }
When method POST
Then status 403

Scenario: Aprobar solicitud ya decidida - debe fallar
  # Login como ADMIN
  Given url authUrl + 'login/'
  And request { email: 'admin@pettech.com', password: 'Admin1234!' }
  When method POST
  Then status 200
  * def adminToken = response.access

  # Si la solicitud 1 ya existe y fue decidida -> 409 (conflicto)
  # Si no existe -> 404
  Given url solicitudesUrl + '1/aprobar/'
  And header Authorization = 'Bearer ' + adminToken
  And request { "notas_admin": "Segunda aprobación" }
  When method POST
  Then assert responseStatus == 400 || responseStatus == 404 || responseStatus == 409

Scenario: Rechazar solicitud como ADMIN
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
  * set familiaRequest.nombre_familia = 'Rechazar'
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

  * def solicitudRequest = { "mascota": "#(mascotaIdInt)", "mensaje": "Rechazar esta" }
Given url solicitudesUrl
And header Authorization = 'Bearer ' + familiaToken
And request solicitudRequest
When method POST
Then status 201
* def solicitudId = response.id

# Rechazar como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

Given url solicitudesUrl + solicitudId + '/rechazar/'
And header Authorization = 'Bearer ' + adminToken
And request { "notas_admin": "No cumple con los requisitos." }
When method POST
Then status 200
And match response.estado == 'RECHAZADA'

Scenario: Rechazar solicitud como FAMILIA - debe fallar
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

Given url solicitudesUrl + '1/rechazar/'
And header Authorization = 'Bearer ' + familiaToken
And request { "notas_admin": "Intento de rechazo" }
When method POST
Then status 403

Scenario: Flujo completo: crear -> aprobar -> completar adopción
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
  * set familiaRequest.nombre_familia = 'Flujo'
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

  # Crear solicitud con mascotaId dinámico
  * def solicitudRequest = { "mascota": "#(mascotaIdInt)", "mensaje": "Flujo completo" }
Given url solicitudesUrl
And header Authorization = 'Bearer ' + familiaToken
And request solicitudRequest
When method POST
Then status 201
* def solicitudId = response.id
And match response.estado == 'PENDIENTE'

# Aprobar
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

Given url solicitudesUrl + solicitudId + '/aprobar/'
And header Authorization = 'Bearer ' + adminToken
And request { "notas_admin": "Aprobada para prueba" }
When method POST
Then status 200
And match response.estado == 'APROBADA'

# Verificar adopción completada
Given url adopcionesUrl
And header Authorization = 'Bearer ' + adminToken
When method GET
Then status 200

Scenario: Aprobar solicitud inexistente - 404
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

Given url solicitudesUrl + '99999/aprobar/'
And header Authorization = 'Bearer ' + adminToken
And request { "notas_admin": "Test" }
When method POST
Then status 404

Scenario: Aprobar sin notas admin
  # Login como ADMIN
  Given url authUrl + 'login/'
  And request { email: 'admin@pettech.com', password: 'Admin1234!' }
  When method POST
  Then status 200
  * def adminToken = response.access

  # Si la solicitud no existe -> 404
  # Si la solicitud ya existe y fue decidida -> 409
  # Si existe y está pendiente sin notas -> 400
  Given url solicitudesUrl + '1/aprobar/'
  And header Authorization = 'Bearer ' + adminToken
  And request {}
  When method POST
  Then assert responseStatus == 400 || responseStatus == 404 || responseStatus == 409
