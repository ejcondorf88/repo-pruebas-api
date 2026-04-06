Feature: Setup - Crear Familia

    Background:
        * def authUrl = baseUrl + '/api/v1/auth/'
        * def familiasUrl = baseUrl + '/api/v1/familias/'
        * header Content-Type = 'application/json'

    @ignore
    Scenario: Crear usuario FAMILIA y familia completa
        # Paso 1: Crear usuario
        * def randomEmail = 'familia_' + java.util.UUID.randomUUID() + '@test.com'
        Given url authUrl + 'registro/'
        And request { email: '#(randomEmail)', password: 'Test1234!', password_confirm: 'Test1234!' }
        When method POST
        Then status 201
        
        # Paso 2: Login
        Given url authUrl + 'login/'
        And request { email: '#(randomEmail)', password: 'Test1234!' }
        When method POST
        Then status 200
        * def familiaToken = response.access
        * def familiaId = response.id
        
        # Paso 3: Crear familia
        * header Authorization = 'Bearer ' + familiaToken
        Given url familiasUrl + 'mia/'
        And request { nombre_familia: 'Familia Test', cedula: '1234567890', fecha_nacimiento: '1990-05-15', telefono: '+57 300 123 4567', ciudad: 'Bogota', departamento: 'Cundinamarca', direccion: 'Calle 123', redes_sociales: '@familiatest' }
        When method POST
        Then status 201
        * def familiaCreadaId = response.id
        
        # Resultado
        * def result = { familiaToken: familiaToken, familiaId: familiaId, familiaCreadaId: familiaCreadaId, familiaEmail: randomEmail }
