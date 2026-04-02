Feature: Mascotas - Creación

    Background:
        * url baseUrl + '/api/' + apiVersion + '/mascotas/'
        * header Content-Type = 'application/json'
        * def mascotaRequest =
        """
        {
            "nombre": "Luna",
            "especie": "PERRO",
            "raza": "Golden Retriever",
            "edad_anios": 2,
            "edad_unidad": "ANIOS",
            "fecha_nacimiento": "2022-01-15",
            "tamano": "GRANDE",
            "peso": 25.50,
            "sexo": "HEMBRA",
            "descripcion": "Muy juguetona y cariñosa",
            "estado": "DISPONIBLE",
            "nivel_energia": "ALTO",
            "nivel_independencia": "MEDIO",
            "nivel_complejidad": "BAJO",
            "nivel_sociabilidad": "ALTO",
            "apta_ninos": true,
            "costo_estimado_mensual": "1_2SMLV",
            "historial_vacunas": ["Rabia", "Parvovirus"],
            "historia_mascota": "Rescatada de la calle",
            "info_adicional": "Le gusta jugar con pelotas"
        }
        """

    Scenario: Crear mascota como ADMIN - exitoso
        * header Authorization = 'Bearer ' + adminToken
        And request mascotaRequest
        When method POST
        Then status 201
        And match response == read('classpath:karate/schemas/mascota.json')
        And match response.nombre == 'Luna'
        And match response.especie == 'PERRO'
        And match response.estado == 'DISPONIBLE'
        And match response.registrado_por == adminId

    Scenario: Crear mascota como FAMILIA - denegado
        * header Authorization = 'Bearer ' + familiaToken
        And request mascotaRequest
        When method POST
        Then status 403

    Scenario: Crear mascota sin autenticación
        * header Authorization = ''
        And request mascotaRequest
        When method POST
        Then status 401

    Scenario: Crear mascota - campos mínimos requeridos
        * header Authorization = 'Bearer ' + adminToken
        And request { "nombre": "Test", "especie": "GATO", "estado": "DISPONIBLE" }
        When method POST
        Then status 201
        And match response.nombre == 'Test'

    Scenario: Crear mascota - nombre vacío
        * header Authorization = 'Bearer ' + adminToken
        And request { "nombre": "", "especie": "GATO", "estado": "DISPONIBLE" }
        When method POST
        Then status 400

    Scenario: Crear mascota - especie inválida
        * header Authorization = 'Bearer ' + adminToken
        And request { "nombre": "Test", "especie": "ELEFANTE", "estado": "DISPONIBLE" }
        When method POST
        Then status 400

    Scenario: Crear mascota - estado inválido
        * header Authorization = 'Bearer ' + adminToken
        And request { "nombre": "Test", "especie": "GATO", "estado": "EN_ADOPCION" }
        When method POST
        Then status 400

    Scenario: Crear mascota - edad negativa
        * header Authorization = 'Bearer ' + adminToken
        * def invalidRequest = karate.toObject(mascotaRequest)
        * set invalidRequest.edad_anios = -1
        And request invalidRequest
        When method POST
        Then status 400

    Scenario: Crear mascota - validar respuesta contiene todos los campos
        * header Authorization = 'Bearer ' + adminToken
        And request mascotaRequest
        When method POST
        Then status 201
        And match response contains { id: '#number', fecha_ingreso: '#string', fecha_actualizacion: '#string' }
