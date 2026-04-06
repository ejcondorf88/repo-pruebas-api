Feature: Familias - Perfil

Background:
* def familiasUrl = baseUrl + '/api/v1/familias/'
* def familiasMiaUrl = familiasUrl + 'mia/'
* def authUrl = baseUrl + '/api/v1/auth/'
* header Content-Type = 'application/json'

@smoke
Scenario: Obtener mi perfil como FAMILIA
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

# Crear familia primero
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
And request { "nombre_familia": "Test", "ciudad": "Bogotá", "departamento": "Cundinamarca", "telefono": "+57 300 123 4567" }
When method POST
Then status 201

# Obtener perfil
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
And match response contains { familia: '#object', tiene_familia: true }

@regression @edgecase
Scenario: Obtener perfil sin haber creado familia
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

# Verificar que no tiene familia
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
And match response.tiene_familia == false

@smoke
Scenario: Listar todas las familias como ADMIN
# Login inline como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url familiasUrl
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
And match response contains { count: '#number', next: '##string', previous: '##string', results: '#[]' }

@regression @negative
Scenario: Listar familias como FAMILIA - denegado
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

Given url familiasUrl
And header Authorization = 'Bearer ' + token
When method GET
Then status 403

@regression
Scenario: Actualizar mi perfil como FAMILIA
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
And request { "nombre_familia": "UpdateTest", "ciudad": "Bogotá", "departamento": "Cundinamarca", "telefono": "+57 300 123 4567" }
When method POST
Then status 201

# Actualizar
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
And request { "nombre_familia": "Familia Actualizada", "telefono": "+57 300 999 8888" }
When method PATCH
Then status 200
And match response.nombre_familia == 'Familia Actualizada'

@regression @edgecase
Scenario: Actualizar perfil sin familia - debe fallar
# Login inline como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
When method PATCH
Then status 404

@regression
Scenario: Eliminar cuenta como FAMILIA
* def authPerfilUrl = baseUrl + '/api/v1/auth/perfil/'
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

# Crear familia primero
Given url familiasMiaUrl
And header Authorization = 'Bearer ' + token
And request { "nombre_familia": "DeleteTest", "ciudad": "Bogotá", "departamento": "Cundinamarca", "telefono": "+57 300 123 4567" }
When method POST
Then status 201

# Eliminar cuenta
Given url authPerfilUrl
And header Authorization = 'Bearer ' + token
When method DELETE
Then status 204

@regression @negative
Scenario: Eliminar cuenta ADMIN - debe fallar
* def authPerfilUrl = baseUrl + '/api/v1/auth/perfil/'
# Login inline como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url authPerfilUrl
And header Authorization = 'Bearer ' + token
When method DELETE
Then status 403

@regression @negative
Scenario: Acceso sin autenticación
Given url familiasMiaUrl
And header Authorization = ''
When method GET
Then status 401
