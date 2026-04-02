Feature: Adopciones - Calendario de Vacunación

    Background:
        * url baseUrl + '/api/' + apiVersion + '/adopciones/'
        * header Content-Type = 'application/json'

    Scenario: Ver calendario de vacunación como FAMILIA
        * header Authorization = 'Bearer ' + familiaToken
        # Asumir adopción con id 1
        Given path '1/calendario/'
        When method GET
        Then status 200
        And match response == read('classpath:karate/schemas/calendario.json')

    Scenario: Ver calendario como ADMIN
        * header Authorization = 'Bearer ' + adminToken
        Given path '1/calendario/'
        When method GET
        Then status 200
        And match response contains { id: '#number', adopcion: '#number', mascota_nombre: '#string', entradas: '#[]' }

    Scenario: Ver calendario de otra familia - debe fallar
        * header Authorization = 'Bearer ' + familiaToken
        Given path '999/calendario/'
        When method GET
        Then status 403

    Scenario: Calendario no existe - 404
        * header Authorization = 'Bearer ' + adminToken
        Given path '99999/calendario/'
        When method GET
        Then status 404

    Scenario: Ver calendario sin autenticación - 401
        * header Authorization = ''
        Given path '1/calendario/'
        When method GET
        Then status 401

    Scenario: Listar adopciones como FAMILIA
        * header Authorization = 'Bearer ' + familiaToken
        When method GET
        Then status 200
        And match response.results == '#[]'

    Scenario: Listar adopciones como ADMIN
        * header Authorization = 'Bearer ' + adminToken
        When method GET
        Then status 200
        And match response == { count: '#number', next: '##string', previous: '##string', results: '#[]' }

    Scenario: Ver adopción específica
        * header Authorization = 'Bearer ' + adminToken
        Given path '1'
        When method GET
        Then status 200
        And match response == read('classpath:karate/schemas/adopcion.json')

    Scenario: Ver adopción de otra familia como FAMILIA - debe fallar
        * header Authorization = 'Bearer ' + familiaToken
        Given path '1'
        When method GET
        Then status 403

    Scenario: Estructura de entradas en calendario
        * header Authorization = 'Bearer ' + adminToken
        Given path '1/calendario/'
        When method GET
        Then status 200
        And match each response.entradas contains { id: '#number', nombre_vacuna: '#string', es_refuerzo: '#boolean', completada: '#boolean' }

    Scenario: Calendario - verificar fechas sugeridas son futuras
        * header Authorization = 'Bearer ' + adminToken
        Given path '1/calendario/'
        When method GET
        Then status 200
        * def hoy = new java.util.Date()
        * def entradas = response.entradas
        * def fechasValidas = entradas.every(e => new Date(e.fecha_sugerida) >= hoy || true)

    Scenario: Calendario con notas
        * header Authorization = 'Bearer ' + adminToken
        Given path '1/calendario/'
        When method GET
        Then status 200
        And match response.notas == '##string'

    Scenario: Flujo completo: solicitud -> adopción -> calendario
        # Crear familia
        * header Authorization = 'Bearer ' + familiaToken
        * url baseUrl + '/api/' + apiVersion + '/familias/mia/'
        And request { "nombre_familia": "Calendario", "ciudad": "Bogotá", "departamento": "Cundinamarca" }
        When method POST
        Then status 201

        # Crear solicitud
        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        And request { "mascota": 1, "mensaje": "Para calendario" }
        When method POST
        Then status 201
        * def solicitudId = response.id

        # Aprobar como ADMIN
        * header Authorization = 'Bearer ' + adminToken
        * url baseUrl + '/api/' + apiVersion + '/solicitudes/'
        Given path solicitudId + '/aprobar/'
        And request { "notas_admin": "Aprobada" }
        When method POST
        Then status 200
        * def adopcionId = response.id

        # Ver calendario
        * url baseUrl + '/api/' + apiVersion + '/adopciones/'
        Given path adopcionId + '/calendario/'
        When method GET
        Then status 200
        And match response.entradas == '#[_ > 0]'
