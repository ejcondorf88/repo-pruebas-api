Feature: Auth - Token Refresh

    Background:
        * url baseUrl + '/api/' + apiVersion + '/auth'
        * header Content-Type = 'application/json'

    Scenario: Refresh token exitoso
        # Primero hacer login para obtener refresh token
        Given path '/login/'
        And request { email: 'admin@pettech.com', password: 'Admin123!' }
        When method POST
        Then status 200
        * def refreshToken = response.refresh

        # Usar refresh token para obtener nuevo access token
        Given path '/token/refresh/'
        And request { refresh: '#(refreshToken)' }
        When method POST
        Then status 200
        And match response == { access: '#string' }
        And match response.access == '#string'

    Scenario: Refresh token - nuevo token es válido
        # Login
        Given path '/login/'
        And request { email: 'admin@pettech.com', password: 'Admin123!' }
        When method POST
        Then status 200
        * def oldAccess = response.access
        * def refreshToken = response.refresh

        # Refresh
        Given path '/token/refresh/'
        And request { refresh: '#(refreshToken)' }
        When method POST
        Then status 200
        * def newAccess = response.access

        # Verificar que el nuevo token es diferente del anterior
        * assert oldAccess != newAccess

    Scenario: Refresh token fallido - token inválido
        Given path '/token/refresh/'
        And request { refresh: 'token.invalido.aqui' }
        When method POST
        Then status 401

    Scenario: Refresh token fallido - token expirado
        Given path '/token/refresh/'
        And request { refresh: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTYwOTQ1OTIwMCwiaWF0IjoxNjA5NDU5MjAwLCJqdGkiOiJ0ZXN0IiwidXNlcl9pZCI6MX0.test' }
        When method POST
        Then status 401

    Scenario: Refresh token fallido - token vacío
        Given path '/token/refresh/'
        And request { refresh: '' }
        When method POST
        Then status 400

    Scenario: Refresh token - usar token para acceder a recurso protegido
        # Login y obtener refresh token
        Given path '/login/'
        And request { email: 'familia@test.com', password: 'Familia123!' }
        When method POST
        Then status 200
        * def refreshToken = response.refresh

        # Refresh para obtener nuevo access token
        Given path '/token/refresh/'
        And request { refresh: '#(refreshToken)' }
        When method POST
        Then status 200
        * def newAccessToken = response.access

        # Usar nuevo token para acceder a recurso protegido
        * url baseUrl + '/api/' + apiVersion + '/auth/perfil/'
        * header Authorization = 'Bearer ' + newAccessToken
        When method GET
        Then status 200
