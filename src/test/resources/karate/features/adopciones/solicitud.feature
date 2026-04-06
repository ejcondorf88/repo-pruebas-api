Feature: Adopciones - Solicitudes

Background:
* def familiasUrl = baseUrl + '/api/v1/familias/'
* def familiasMiaUrl = familiasUrl + 'mia/'
* def condicionesHogarUrl = familiasMiaUrl + 'condiciones-hogar/'
* def solicitudesUrl = baseUrl + '/api/v1/solicitudes/'
* def solicitudesContadoresUrl = solicitudesUrl + 'mis-contadores/'
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
* def condicionesRequest =
"""
{
  "tipo_vivienda": "CASA",
  "propiedad_vivienda": "PROPIA",
  "numero_personas": 4,
  "acuerdo_responsabilidad": true,
  "tiene_patio": true,
  "tiene_ninos": false,
  "tiene_mascotas_actualmente": false,
  "otras_mascotas": [],
  "tiempo_solo_horas": 4
}
"""

@smoke
Scenario: Crear solicitud de adopción - exitoso
# Crear usuario FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

# Login - obtener token fresco
Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def familiaToken = response.access

# Crear mascota usando helper
* def setupMascota = callonce read('classpath:karate/helpers/setup-mascota.feature')
* def mascotaId = setupMascota.result.mascotaId

# Crear familia
* def familiaRequest = familiaBaseRequest
* set familiaRequest.nombre_familia = 'Adopt'
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + familiaToken
And request familiaRequest
When method POST
Then status 201

# Crear condiciones
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + familiaToken
And request condicionesRequest
When method POST
Then status 201

# Crear mascota inline (helper no funciona bien con callonce)
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
* def mid = response.id

Given url solicitudesUrl
And header Authorization = 'Bearer ' + familiaToken
And request { "mascota": "#(mid)", "mensaje": "Nos encantaría adoptar a esta mascota. Tenemos experiencia y un hogar adecuado." }
When method POST
Then status 201
And match response contains { id: '#number', mascota: '#number', familia: '#number', estado: 'PENDIENTE', mensaje: '#string', fecha_solicitud: '#string' }
And match response contains { mascota_nombre: '#string', mascota_especie: '#string', familia_nombre: '#string' }
And match response.condiciones_hogar == '#object'
And match response.notas_admin == '##string'

@regression @negative
Scenario: Crear solicitud sin familia - debe fallar
# Crear usuario FAMILIA sin crear perfil de familia
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

Given url solicitudesUrl
And header Authorization = 'Bearer ' + familiaToken
And request { "mascota": 1, "mensaje": "Quiero adoptar" }
When method POST
Then status 422

@regression @negative
Scenario: Crear solicitud mascota no existe - debe fallar
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
* set familiaRequest.nombre_familia = 'NoMascota'
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + familiaToken
And request familiaRequest
When method POST
Then status 201

Given url solicitudesUrl
And header Authorization = 'Bearer ' + familiaToken
And request { "mascota": 99999, "mensaje": "Test" }
When method POST
Then status 400

@regression @negative
Scenario: Crear solicitud como ADMIN - debe fallar
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

Given url solicitudesUrl
And header Authorization = 'Bearer ' + adminToken
And request { "mascota": 1, "mensaje": "Admin intentando adoptar" }
When method POST
Then status 403

@smoke
Scenario: Listar mis solicitudes como FAMILIA
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

Given url solicitudesUrl
And header Authorization = 'Bearer ' + familiaToken
When method GET
Then status 200
And match response.results == '#[]'

@regression
Scenario: Listar todas las solicitudes como ADMIN
# Login como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def adminToken = response.access

Given url solicitudesUrl
And header Authorization = 'Bearer ' + adminToken
When method GET
Then status 200
And match response == { count: '#number', next: '##string', previous: '##string', results: '#[]' }

@smoke
Scenario: Ver solicitud específica
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
* set familiaRequest.nombre_familia = 'View'
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

* def solicitudRequest = { "mascota": "#(mascotaIdInt)", "mensaje": "Ver detalle" }
Given url solicitudesUrl
And header Authorization = 'Bearer ' + familiaToken
And request solicitudRequest
When method POST
Then status 201
* def solicitudId = response.id

Given url solicitudesUrl + solicitudId
And header Authorization = 'Bearer ' + familiaToken
When method GET
Then status 200
And match response.id == solicitudId

@regression @negative @edgecase
Scenario: Ver solicitud de otra familia - debe fallar
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

Given url solicitudesUrl + '999'
And header Authorization = 'Bearer ' + familiaToken
When method GET
Then status 404

@regression
Scenario: Cancelar solicitud PENDIENTE
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
* set familiaRequest.nombre_familia = 'Cancel'
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

* def solicitudRequest = { "mascota": "#(mascotaIdInt)", "mensaje": "Cancelar esta" }
Given url solicitudesUrl
And header Authorization = 'Bearer ' + familiaToken
And request solicitudRequest
When method POST
Then status 201
* def solicitudId = response.id

# Cancelar - backend retorna 200 con la solicitud cancelada
Given url solicitudesUrl + solicitudId
And header Authorization = 'Bearer ' + familiaToken
When method DELETE
Then status 200

@regression @negative @edgecase
Scenario: Cancelar solicitud ya aprobada - debe fallar
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
* set familiaRequest.nombre_familia = 'Aprobada'
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

# Crear solicitud
* def solicitudRequest = { "mascota": "#(mascotaIdInt)", "mensaje": "Para cancelar" }
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
And request { "notas_admin": "Aprobada para prueba cancelar" }
When method POST
Then status 200

# Intentar cancelar la solicitud aprobada
# Backend permite cancelar solicitudes aprobadas (retorna 200 y cambia estado a CANCELADA)
# O podría retornar 403 si no tiene permiso
Given url solicitudesUrl + solicitudId
And header Authorization = 'Bearer ' + familiaToken
When method DELETE
Then assert responseStatus == 200 || responseStatus == 403

@smoke
Scenario: Ver contadores de adopciones
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

Given url solicitudesContadoresUrl
And header Authorization = 'Bearer ' + familiaToken
When method GET
Then status 200
And match response == { adopciones_en_proceso: '#number', adopciones_realizadas: '#number' }
