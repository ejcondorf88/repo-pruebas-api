Feature: Auth - Login

    Background:
        * url baseUrl + '/api/' + apiVersion + '/auth'
        * header Content-Type = 'application/json'

    Scenario: Login exitoso como ADMIN
        Given path '/login/'
        And request { email: 'admin@pettech.com', password: 'Admin123!' }
        When method POST
        Then status 200
        And match response == { access: '#string', refresh: '#string', email: 'admin@pettech.com', rol: 'ADMIN', perfil_completo: '#boolean', nombre: '#string', id: '#number' }
        And match response.access == '#string'
        And match response.refresh == '#string'

    Scenario: Login exitoso como FAMILIA
        Given path '/login/'
        And request { email: 'familia@test.com', password: 'Familia123!' }
        When method POST
        Then status 200
        And match response == { access: '#string', refresh: '#string', email: 'familia@test.com', rol: 'FAMILIA', perfil_completo: '#boolean', nombre: '#string', id: '#number' }

    Scenario: Login fallido - usuario inexistente
        Given path '/login/'
        And request { email: 'noexiste@test.com', password: 'Password123!' }
        When method POST
        Then status 404
        And match response.error contains 'no se encuentra registrado'

    Scenario: Login fallido - contraseña incorrecta
        Given path '/login/'
        And request { email: 'admin@pettech.com', password: 'WrongPassword123!' }
        When method POST
        Then status 401

    Scenario: Login fallido - email mal formado
        Given path '/login/'
        And request { email: 'no-es-email', password: 'Password123!' }
        When method POST
        Then status 400

    Scenario: Login fallido - campos vacíos
        Given path '/login/'
        And request { email: '', password: '' }
        When method POST
        Then status 400

    Scenario: Login - validar estructura de tokens JWT
        Given path '/login/'
        And request { email: 'admin@pettech.com', password: 'Admin123!' }
        When method POST
        Then status 200
        * def accessToken = response.access
        * def refreshToken = response.refresh
        * assert accessToken.split('.').length == 3
        * assert refreshToken.split('.').length == 3
