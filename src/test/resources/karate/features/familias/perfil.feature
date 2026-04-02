Feature: Familias - Perfil

    Background:
        * url baseUrl + '/api/' + apiVersion + '/familias/'
        * header Content-Type = 'application/json'

    Scenario: Obtener mi perfil como FAMILIA
        * header Authorization = 'Bearer ' + familiaToken
        Given path '/mia/'
        When method GET
        Then status 200
        And match response == { familia: '##object', tiene_familia: '#boolean' }

    Scenario: Obtener perfil sin haber creado familia
        * header Authorization = 'Bearer ' + familiaToken
        Given path '/mia/'
        When method GET
        Then status 200
        And match response.tiene_familia == true

    Scenario: Listar todas las familias como ADMIN
        * header Authorization = 'Bearer ' + adminToken
        When method GET
        Then status 200
        And match response == { count: '#number', next: '##string', previous: '##string', results: '#[]' }

    Scenario: Listar familias como FAMILIA - denegado
        * header Authorization = 'Bearer ' + familiaToken
        When method GET
        Then status 403

    Scenario: Actualizar mi perfil como FAMILIA
        * header Authorization = 'Bearer ' + familiaToken
        # Primero crear si no existe
        Given path '/mia/'
        And request { "nombre_familia": "UpdateTest", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        # Actualizar
        Given path '/mia/'
        And request { "nombre_familia": "Familia Actualizada", "telefono": "+57 300 999 8888" }
        When method PATCH
        Then status 200
        And match response.nombre_familia == 'Familia Actualizada'

    Scenario: Actualizar perfil sin familia - debe fallar
        * header Authorization = 'Bearer ' + adminToken
        Given path '/mia/'
        When method PATCH
        Then status 400

    Scenario: Eliminar cuenta como FAMILIA
        * header Authorization = 'Bearer ' + familiaToken
        # Primero crear familia
        Given path '/mia/'
        And request { "nombre_familia": "DeleteTest", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        # Eliminar cuenta (esto requiere el endpoint auth/perfil/)
        * url baseUrl + '/api/' + apiVersion + '/auth/perfil/'
        When method DELETE
        Then status 204

    Scenario: Eliminar cuenta ADMIN - debe fallar
        * header Authorization = 'Bearer ' + adminToken
        * url baseUrl + '/api/' + apiVersion + '/auth/perfil/'
        When method DELETE
        Then status 403

    Scenario: Ver familia específica como ADMIN
        * header Authorization = 'Bearer ' + adminToken
        * url baseUrl + '/api/' + apiVersion + '/familias/'
        Given path '1'
        When method GET
        Then status 200

    Scenario: Acceso sin autenticación
        * header Authorization = ''
        Given path '/mia/'
        When method GET
        Then status 401
