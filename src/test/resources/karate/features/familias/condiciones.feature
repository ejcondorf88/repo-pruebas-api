Feature: Familias - Condiciones de Hogar

    Background:
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/condiciones-hogar/'
        * header Content-Type = 'application/json'
        * def condicionesRequest =
        """
        {
            "tipo_vivienda": "CASA",
            "propiedad_vivienda": "PROPIA",
            "tiene_patio": true,
            "numero_personas": 4,
            "tiene_ninos": true,
            "tamano_hogar": "MEDIANO",
            "tiene_mascotas_actualmente": false,
            "otras_mascotas": [],
            "tiempo_solo_horas": 4,
            "ingresos_estimados": "2_4SMLV",
            "experiencia_mascotas": "Hemos tenido perros antes",
            "motivacion": "Queremos darle un hogar a un animal necesitado",
            "acuerdo_responsabilidad": true
        }
        """

    Scenario: Crear condiciones de hogar como FAMILIA - exitoso
        * header Authorization = 'Bearer ' + familiaToken
        # Primero crear familia
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "Test", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        # Crear condiciones
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/condiciones-hogar/'
        And request condicionesRequest
        When method POST
        Then status 201
        And match response == read('classpath:karate/schemas/condiciones.json')
        And match response.acuerdo_responsabilidad == true

    Scenario: Crear condiciones sin familia - debe fallar
        * header Authorization = 'Bearer ' + adminToken
        And request condicionesRequest
        When method POST
        Then status 400

    Scenario: Crear condiciones duplicadas - debe fallar
        * header Authorization = 'Bearer ' + familiaToken
        # Primera creación
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "DupTest", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        # Crear condiciones
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/condiciones-hogar/'
        And request condicionesRequest
        When method POST
        Then status 201

        # Segunda creación - debe fallar
        And request condicionesRequest
        When method POST
        Then status 400

    Scenario: Crear condiciones sin acuerdo - debe fallar
        * header Authorization = 'Bearer ' + familiaToken
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "NoAcuerdo", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        * url baseUrl + '/api/' + apiVersion + '/familias/mia/condiciones-hogar/'
        * def noAcuerdo = karate.toObject(condicionesRequest)
        * set noAcuerdo.acuerdo_responsabilidad = false
        And request noAcuerdo
        When method POST
        Then status 400

    Scenario: Obtener condiciones de hogar
        * header Authorization = 'Bearer ' + familiaToken
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "GetTest", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        * url baseUrl + '/api/' + apiVersion + '/familias/mia/condiciones-hogar/'
        And request condicionesRequest
        When method POST
        Then status 201

        When method GET
        Then status 200
        And match response.tipo_vivienda == 'CASA'

    Scenario: Actualizar condiciones de hogar
        * header Authorization = 'Bearer ' + familiaToken
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "UpdateCond", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        * url baseUrl + '/api/' + apiVersion + '/familias/mia/condiciones-hogar/'
        And request condicionesRequest
        When method POST
        Then status 201

        And request { "numero_personas": 6, "tiene_patio": false }
        When method PATCH
        Then status 200
        And match response.numero_personas == 6
        And match response.tiene_patio == false

    Scenario: Condiciones - validar campos requeridos
        * header Authorization = 'Bearer ' + familiaToken
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "ReqTest", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        * url baseUrl + '/api/' + apiVersion + '/familias/mia/condiciones-hogar/'
        And request { "tipo_vivienda": "CASA" }
        When method POST
        Then status 400
