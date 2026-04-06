Feature: Auth - Login

Background:
* def authUrl = baseUrl + '/api/v1/auth/'
* header Content-Type = 'application/json'

@smoke
Scenario: Login exitoso como ADMIN
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
And match response == { access: '#string', refresh: '#string', email: 'admin@pettech.com', rol: 'ADMIN', perfil_completo: '#boolean', nombre: '#string', id: '#number' }
And match response.access == '#string'
And match response.refresh == '#string'

@regression @negative
Scenario: Login fallido - usuario inexistente
Given url authUrl + 'login/'
And request { email: 'noexiste@test.com', password: 'Password123!' }
When method POST
Then status 404
And match response.error contains 'no se encuentra registrado'

@regression @negative
Scenario: Login fallido - contraseña incorrecta
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'WrongPassword123!' }
When method POST
Then status 401

@regression @negative
Scenario: Login fallido - email mal formado
Given url authUrl + 'login/'
And request { email: 'no-es-email', password: 'Password123!' }
When method POST
Then status 404
# Backend retorna 404 si no encuentra usuario (incluye email mal formado)

@regression @negative
Scenario: Login fallido - campos vacíos
Given url authUrl + 'login/'
And request { email: '', password: '' }
When method POST
Then status 404
# Backend retorna 404 para campos vacíos (no encuentra usuario)

@smoke
Scenario: Login - validar estructura de tokens JWT
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def accessToken = response.access
* def refreshToken = response.refresh
* assert accessToken.split('.').length == 3
* assert refreshToken.split('.').length == 3

@smoke @regression
Scenario: Login exitoso como usuario FAMILIA recién registrado
# 1. Registrar usuario FAMILIA nuevo
* def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
When method POST
Then status 201

# 2. Login con ese usuario
Given url authUrl + 'login/'
And request { email: '#(randomEmail)', password: 'Test1234!' }
When method POST
Then status 200
And match response == { access: '#string', refresh: '#string', email: '#(randomEmail)', rol: 'FAMILIA', perfil_completo: false, nombre: '#string', id: '#number' }
And match response.access == '#string'
And match response.refresh == '#string'

# 3. Usar el token para acceder
* def familiaToken = response.access
* header Authorization = 'Bearer ' + familiaToken
Given url baseUrl + '/api/v1/familias/mia/'
When method GET
Then status 200
And match response.tiene_familia == false
