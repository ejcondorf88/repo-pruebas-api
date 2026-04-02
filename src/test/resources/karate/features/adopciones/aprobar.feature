Feature: Adopciones - Aprobación y Rechazo

    Background:
        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        * header Content-Type = 'application/json'

    Scenario: Aprobar solicitud como ADMIN - exitoso
        # Login como familia para crear
        * header Authorization = 'Bearer ' + familiaToken
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "Aprobar", "ciudad": "Bogotá", "departamento": "Cundinamarca", "cedula": "1234567890", "fecha_nacimiento": "1990-01-01", "telefono": "3001234567" }
        When method POST
        Then status 201

        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        And request { "mascota": 1, "mensaje": "Aprobar esta solicitud" }
        When method POST
        Then status 201
        * def solicitudId = response.id

        # Aprobar como ADMIN
        * header Authorization = 'Bearer ' + adminToken
        Given path solicitudId + '/aprobar/'
        And request { "notas_admin": "Excelente familia, apruebo la solicitud." }
        When method POST
        Then status 200
        And match response.estado == 'APROBADA'
        And match response.notas_admin == "Excelente familia, apruebo la solicitud."

    Scenario: Aprobar solicitud como FAMILIA - debe fallar
        * header Authorization = 'Bearer ' + familiaToken
        Given path '1/aprobar/'
        And request { "notas_admin": "Intento de aprobación" }
        When method POST
        Then status 403

    Scenario: Aprobar solicitud ya decidida - debe fallar
        * header Authorization = 'Bearer ' + adminToken
        # Asumir que la solicitud 1 ya fue aprobada
        Given path '1/aprobar/'
        And request { "notas_admin": "Segunda aprobación" }
        When method POST
        Then status >= 400

    Scenario: Rechazar solicitud como ADMIN
        # Crear solicitud como familia
        * header Authorization = 'Bearer ' + familiaToken
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "Rechazar", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        And request { "mascota": 1, "mensaje": "Rechazar esta" }
        When method POST
        Then status 201
        * def solicitudId = response.id

        # Rechazar como ADMIN
        * header Authorization = 'Bearer ' + adminToken
        Given path solicitudId + '/rechazar/'
        And request { "notas_admin": "No cumple con los requisitos." }
        When method POST
        Then status 200
        And match response.estado == 'RECHAZADA'

    Scenario: Rechazar solicitud como FAMILIA - debe fallar
        * header Authorization = 'Bearer ' + familiaToken
        Given path '1/rechazar/'
        And request { "notas_admin": "Intento de rechazo" }
        When method POST
        Then status 403

    Scenario: Flujo completo: crear -> aprobar -> completar adopción
        # Crear familia
        * header Authorization = 'Bearer ' + familiaToken
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "Flujo", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        # Crear solicitud
        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        And request { "mascota": 1, "mensaje": "Flujo completo" }
        When method POST
        Then status 201
        * def solicitudId = response.id
        And match response.estado == 'PENDIENTE'

        # Aprobar
        * header Authorization = 'Bearer ' + adminToken
        Given path solicitudId + '/aprobar/'
        And request { "notas_admin": "Aprobada para prueba" }
        When method POST
        Then status 200
        And match response.estado == 'APROBADA'

        # Verificar adopción completada
        * url baseUrl + '/api/' + apiVersion + '/adopciones/'
        When method GET
        Then status 200

    Scenario: Aprobar solicitud inexistente - 404
        * header Authorization = 'Bearer ' + adminToken
        Given path '99999/aprobar/'
        And request { "notas_admin": "Test" }
        When method POST
        Then status 404

    Scenario: Aprobar sin notas admin
        * header Authorization = 'Bearer ' + adminToken
        Given path '1/aprobar/'
        And request {}
        When method POST
        Then status >= 400
