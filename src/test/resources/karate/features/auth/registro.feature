Feature: Auth - Registro

Background:
* def authUrl = baseUrl + '/api/v1/auth/'
* url authUrl
* header Content-Type = 'application/json'

Scenario: Registro exitoso de nuevo usuario FAMILIA
* def randomEmail = 'test_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
        And request { email: '#(randomEmail)', password: 'NewPass123!', password_confirm: 'NewPass123!' }
        When method POST
        Then status 201
        And match response == { message: '#string', user: { id: '#number', email: '#(randomEmail)', nombre: '#string', rol: 'FAMILIA', perfil_completo: false, fecha_creacion: '#string' } }
        And match response.message contains 'registrado exitosamente'

Scenario: Registro fallido - email duplicado
Given url authUrl + 'registro/'
        And request { email: 'admin@pettech.com', password: 'Password123!', password_confirm: 'Password123!' }
        When method POST
        Then status 400
        And match response.error.email[0] contains 'registrado'
    # Mensaje real: "Este correo ya está registrado."

Scenario: Registro fallido - contraseña débil (sin número)
* def randomEmail = 'test_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
        And request { email: '#(randomEmail)', password: 'Password!', password_confirm: 'Password!' }
        When method POST
        Then status 400
        And match response.error.password contains '#string'

Scenario: Registro fallido - contraseña débil (sin especial)
* def randomEmail = 'test_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
        And request { email: '#(randomEmail)', password: 'Password123', password_confirm: 'Password123' }
        When method POST
        Then status 400

Scenario: Registro fallido - contraseñas no coinciden
* def randomEmail = 'test_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
        And request { email: '#(randomEmail)', password: 'Password123!', password_confirm: 'DifferentPass123!' }
        When method POST
        Then status 400

Scenario: Registro fallido - email mal formado
Given url authUrl + 'registro/'
        And request { email: 'no-es-un-email', password: 'Password123!', password_confirm: 'Password123!' }
        When method POST
        Then status 400

Scenario: Registro fallido - campos vacíos
Given url authUrl + 'registro/'
        And request { email: '', password: '', password_confirm: '' }
        When method POST
        Then status 400

Scenario: Registro - verificar rol por defecto es FAMILIA
* def randomEmail = 'test_' + java.util.UUID.randomUUID() + '@test.com'
Given url authUrl + 'registro/'
        And request { email: '#(randomEmail)', password: 'NewPass123!', password_confirm: 'NewPass123!' }
        When method POST
        Then status 201
        And match response.user.rol == 'FAMILIA'
