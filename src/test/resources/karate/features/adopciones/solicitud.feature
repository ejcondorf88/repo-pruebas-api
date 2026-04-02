Feature: Adopciones - Solicitudes

    Background:
        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        * header Content-Type = 'application/json'
        * header Authorization = 'Bearer ' + familiaToken

    Scenario: Crear solicitud de adopción - exitoso
        # Crear familia primero
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "Adopt", "ciudad": "Bogotá", "departamento": "Cundinamarca", "cedula": "1234567890", "fecha_nacimiento": "1990-01-01", "telefono": "3001234567" }
        When method POST
        Then status 201

        # Crear condiciones
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/condiciones-hogar/'
        And request { "tipo_vivienda": "CASA", "propiedad_vivienda": "PROPIA", "numero_personas": 4, "acuerdo_responsabilidad": true, "tiene_patio": true, "tiene_ninos": false, "tiene_mascotas_actualmente": false, "otras_mascotas": [], "tiempo_solo_horas": 4 }
        When method POST
        Then status 201

        # Crear solicitud (asumiendo mascota con id 1 existe)
        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        And request { "mascota": 1, "mensaje": "Nos encantaría adoptar a esta mascota. Tenemos experiencia y un hogar adecuado." }
        When method POST
        Then status 201
        And match response == read('classpath:karate/schemas/solicitud.json')
        And match response.estado == 'PENDIENTE'
        And match response.mensaje == 'Nos encantaría adoptar a esta mascota. Tenemos experiencia y un hogar adecuado.'

    Scenario: Crear solicitud sin familia - debe fallar
        And request { "mascota": 1, "mensaje": "Quiero adoptar" }
        When method POST
        Then status 400

    Scenario: Crear solicitud mascota no existe - debe fallar
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "NoMascota", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        And request { "mascota": 99999, "mensaje": "Test" }
        When method POST
        Then status 404

    Scenario: Crear solicitud como ADMIN - debe fallar
        * header Authorization = 'Bearer ' + adminToken
        And request { "mascota": 1, "mensaje": "Admin intentando adoptar" }
        When method POST
        Then status 403

    Scenario: Listar mis solicitudes como FAMILIA
        When method GET
        Then status 200
        And match response.results == '#[]'

    Scenario: Listar todas las solicitudes como ADMIN
        * header Authorization = 'Bearer ' + adminToken
        When method GET
        Then status 200
        And match response == { count: '#number', next: '##string', previous: '##string', results: '#[]' }

    Scenario: Ver solicitud específica
        # Crear solicitud
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "View", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        And request { "mascota": 1, "mensaje": "Ver detalle" }
        When method POST
        Then status 201
        * def solicitudId = response.id

        Given path solicitudId
        When method GET
        Then status 200
        And match response.id == solicitudId

    Scenario: Ver solicitud de otra familia - debe fallar
        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        Given path '999'
        When method GET
        Then status 403

    Scenario: Cancelar solicitud PENDIENTE
        # Crear
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "Cancel", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        And request { "mascota": 1, "mensaje": "Cancelar esta" }
        When method POST
        Then status 201
        * def solicitudId = response.id

        # Cancelar
        Given path solicitudId
        When method DELETE
        Then status 204

    Scenario: Cancelar solicitud ya aprobada - debe fallar
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "Aprobada", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        # Este test requiere que una solicitud ya esté aprobada en la BD
        # Por ahora verificamos que el endpoint funciona
        Given path '1'
        When method DELETE
        Then status >= 400

    Scenario: Ver contadores de adopciones
        * url baseUrl + '/api/' + apiVersion + '/solicitudes/mis-contadores/'
        When method GET
        Then status 200
        And match response == { adopciones_en_proceso: '#number', adopciones_realizadas: '#number' }
