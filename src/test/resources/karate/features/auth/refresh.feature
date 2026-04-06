Feature: Auth - Token Refresh

Background:
* def authUrl = baseUrl + '/api/v1/auth/'
* url authUrl
* header Content-Type = 'application/json'

Scenario: Refresh token exitoso
# Primero hacer login para obtener refresh token
Given url authUrl + 'login/'
        And request { email: 'admin@pettech.com', password: 'Admin1234!' }
        When method POST
        Then status 200
        * def refreshToken = response.refresh

# Usar refresh token para obtener nuevo access token
Given url authUrl + 'token/refresh/'
        And request { refresh: '#(refreshToken)' }
        When method POST
    Then status 200
    And match response contains { access: '#string' }
        And match response.access == '#string'

Scenario: Refresh token - nuevo token es válido
# Login
Given url authUrl + 'login/'
        And request { email: 'admin@pettech.com', password: 'Admin1234!' }
        When method POST
        Then status 200
        * def oldAccess = response.access
        * def refreshToken = response.refresh

# Refresh
Given url authUrl + 'token/refresh/'
        And request { refresh: '#(refreshToken)' }
        When method POST
        Then status 200
        * def newAccess = response.access

        # Verificar que el nuevo token es diferente del anterior
        * assert oldAccess != newAccess

Scenario: Refresh token fallido - token inválido
Given url authUrl + 'token/refresh/'
        And request { refresh: 'token.invalido.aqui' }
        When method POST
        Then status 401

Scenario: Refresh token fallido - token expirado
Given url authUrl + 'token/refresh/'
        And request { refresh: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTYwOTQ1OTIwMCwiaWF0IjoxNjA5NDU5MjAwLCJqdGkiOiJ0ZXN0IiwidXNlcl9pZCI6MX0.test' }
        When method POST
        Then status 401

Scenario: Refresh token fallido - token vacío
Given url authUrl + 'token/refresh/'
        And request { refresh: '' }
        When method POST
        Then status 400

Scenario: Refresh token - usar token para acceder a recurso protegido
        # Crear usuario FAMILIA
        * def randomEmail = 'test_' + java.util.UUID.randomUUID() + '@test.com'
        Given url authUrl + 'registro/'
        And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
        When method POST
        Then status 201
        
        # Login y obtener refresh token
        Given url authUrl + 'login/'
        And request { email: '#(randomEmail)', password: 'Test1234!' }
        When method POST
        Then status 200
        * def refreshToken = response.refresh

# Refresh para obtener nuevo access token
Given url authUrl + 'token/refresh/'
        And request { refresh: '#(refreshToken)' }
        When method POST
        Then status 200
        * def newAccessToken = response.access

# Usar nuevo token para acceder a recurso protegido
* def perfilUrl = baseUrl + '/api/v1/auth/perfil/'
Given url perfilUrl
* header Authorization = 'Bearer ' + newAccessToken
When method GET
Then status 200
