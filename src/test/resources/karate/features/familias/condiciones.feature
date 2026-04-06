Feature: Familias - Condiciones de Hogar

Background:
* def familiasUrl = baseUrl + '/api/v1/familias/'
* def familiasMiaUrl = familiasUrl + 'mia/'
* def condicionesHogarUrl = familiasMiaUrl + 'condiciones-hogar/'
* def authUrl = baseUrl + '/api/v1/auth/'
* header Content-Type = 'application/json'
* def condicionesRequest =
"""
{
  "tipo_vivienda": "CASA",
  "propiedad_vivienda": "PROPIA",
  "tiene_patio": true,
  "numero_personas": 4,
  "tiene_ninos": true,
  "tamano_hogar": "MEDIANO",
  "tiene_mascotas_actualmente": false,
  "otras_mascotas": [],
  "tiempo_solo_horas": 4,
  "ingresos_estimados": "2_4SMLV",
  "experiencia_mascotas": "Hemos tenido perros antes",
  "motivacion": "Queremos darle un hogar a un animal necesitado",
  "acuerdo_responsabilidad": true
}
"""

@smoke
Scenario: Crear condiciones de hogar como FAMILIA - exitoso
# Login inline como FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def token = response.access

# Crear familia - incluir todos los campos requeridos
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
And request { "nombre_familia": "Test", "ciudad": "Bogotá", "departamento": "Cundinamarca", "telefono": "+57 300 123 4567" }
When method POST
Then status 201

# Crear condiciones
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
And request condicionesRequest
When method POST
Then status 201

# Verificar condiciones creadas
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
And match response.tipo_vivienda == 'CASA'

@regression @negative
Scenario: Crear condiciones sin familia - debe fallar
# Login inline como ADMIN (no tiene familia)
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
And request condicionesRequest
When method POST
Then status 400

@regression @negative
Scenario: Crear condiciones duplicadas - debe fallar
# Login inline como FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def token = response.access

# Crear familia
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
And request { "nombre_familia": "DupTest", "ciudad": "Bogotá", "departamento": "Cundinamarca", "telefono": "+57 300 123 4567" }
When method POST
Then status 201

# Crear condiciones primera vez
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
And request condicionesRequest
When method POST
Then status 201

# Segunda creación - debe fallar (409 Conflict)
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
And request condicionesRequest
When method POST
Then status 409

@regression @negative
Scenario: Crear condiciones sin acuerdo - debe fallar
# Login inline como FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def token = response.access

# Crear familia
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
And request { "nombre_familia": "NoAcuerdo", "ciudad": "Bogotá", "departamento": "Cundinamarca", "telefono": "+57 300 123 4567" }
When method POST
Then status 201

# Crear condiciones sin acuerdo
* def noAcuerdo =
"""
{
  "tipo_vivienda": "CASA",
  "propiedad_vivienda": "PROPIA",
  "tiene_patio": true,
  "numero_personas": 4,
  "tiene_ninos": true,
  "tamano_hogar": "MEDIANO",
  "tiene_mascotas_actualmente": false,
  "otras_mascotas": [],
  "tiempo_solo_horas": 4,
  "ingresos_estimados": "2_4SMLV",
  "experiencia_mascotas": "Hemos tenido perros antes",
  "motivacion": "Queremos darle un hogar a un animal necesitado",
  "acuerdo_responsabilidad": false
}
"""
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
And request noAcuerdo
When method POST
Then status 400

@smoke
Scenario: Obtener condiciones de hogar
# Login inline como FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def token = response.access

# Crear familia
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
And request { "nombre_familia": "GetTest", "ciudad": "Bogotá", "departamento": "Cundinamarca", "telefono": "+57 300 123 4567" }
When method POST
Then status 201

# Crear condiciones
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
And request condicionesRequest
When method POST
Then status 201

# Obtener condiciones
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
And match response.tipo_vivienda == 'CASA'

@regression
Scenario: Actualizar condiciones de hogar
# Login inline como FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def token = response.access

# Crear familia
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
And request { "nombre_familia": "UpdateCond", "ciudad": "Bogotá", "departamento": "Cundinamarca", "telefono": "+57 300 123 4567" }
When method POST
Then status 201

# Crear condiciones
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
And request condicionesRequest
When method POST
Then status 201

# Actualizar condiciones
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
And request { "numero_personas": 6, "tiene_patio": false }
When method PATCH
Then status 200
And match response.numero_personas == 6
And match response.tiene_patio == false

@regression @negative
Scenario: Condiciones - validar campos requeridos
# Login inline como FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def token = response.access

# Crear familia
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
And request { "nombre_familia": "ReqTest", "ciudad": "Bogotá", "departamento": "Cundinamarca", "telefono": "+57 300 123 4567" }
When method POST
Then status 201

# Intentar crear condiciones con campos incompletos
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
And request { "tipo_vivienda": "CASA" }
When method POST
Then status 400

@regression @negative
Scenario: Crear condiciones sin autenticación
Given url condicionesHogarUrl
When method POST
Then status 401

@regression @negative
Scenario: Crear condiciones sin familia previa - debe fallar
# Login inline como FAMILIA
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
* def token = response.access

# Intentar crear condiciones sin tener familia
Given url condicionesHogarUrl
And header Authorization = 'Bearer ' + token
And request condicionesRequest
When method POST
Then status 400
