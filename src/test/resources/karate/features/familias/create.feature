Feature: Familias - Creación

    Background:
        * url baseUrl + '/api/' + apiVersion + '/familias/'
        * header Content-Type = 'application/json'
        * def familiaRequest =
        """
        {
            "nombre_familia": "Familia Test",
            "cedula": "1234567890",
            "fecha_nacimiento": "1990-05-15",
            "telefono": "+57 300 123 4567",
            "ciudad": "Bogotá",
            "departamento": "Cundinamarca",
            "direccion": "Calle 123 # 45-67",
            "redes_sociales": "@familiatest"
        }
        """

    Scenario: Crear familia como FAMILIA - exitoso
        * header Authorization = 'Bearer ' + familiaToken
        Given path '/mia/'
        And request familiaRequest
        When method POST
        Then status 201
        And match response.familia == read('classpath:karate/schemas/familia.json')
        And match response.familia.nombre_familia == 'Familia Test'
        And match response.tiene_familia == true

    Scenario: Crear familia como ADMIN - exitoso
        * header Authorization = 'Bearer ' + adminToken
        Given path '/mia/'
        And request { "nombre_familia": "Admin Fam", "ciudad": "Medellín", "departamento": "Antioquia", "cedula": "0987654321", "fecha_nacimiento": "1985-01-01", "telefono": "3009998888" }
        When method POST
        Then status 201

    Scenario: Crear familia duplicada - debe fallar
        # Primera creación
        * header Authorization = 'Bearer ' + familiaToken
        Given path '/mia/'
        And request familiaRequest
        When method POST
        Then status 201

        # Segunda creación - debe fallar
        Given path '/mia/'
        And request { "nombre_familia": "Otra", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 400

    Scenario: Crear familia sin autenticación - 401
        * header Authorization = ''
        Given path '/mia/'
        And request familiaRequest
        When method POST
        Then status 401

    Scenario: Crear familia - campos mínimos requeridos
        * header Authorization = 'Bearer ' + familiaToken
        Given path '/mia/'
        And request { "nombre_familia": "Minima", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

    Scenario: Crear familia - validación edad 18+
        * header Authorization = 'Bearer ' + familiaToken
        Given path '/mia/'
        And request { "nombre_familia": "Joven", "ciudad": "Bogotá", "departamento": "Cundinamarca", "cedula": "1111111111", "fecha_nacimiento": "2010-01-01" }
        When method POST
        Then status 400

    Scenario: Crear familia - teléfono muy corto
        * header Authorization = 'Bearer ' + familiaToken
        Given path '/mia/'
        And request { "nombre_familia": "Test", "ciudad": "Bogotá", "departamento": "Cundinamarca", "telefono": "123" }
        When method POST
        Then status 400

    Scenario: Crear familia - verificar respuesta tiene usuario_email
        * header Authorization = 'Bearer ' + familiaToken
        Given path '/mia/'
        And request familiaRequest
        When method POST
        Then status 201
        And match response.familia.usuario_email == 'familia@test.com'
