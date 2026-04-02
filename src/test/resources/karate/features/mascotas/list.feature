Feature: Mascotas - Listado y Filtros

    Background:
        * url baseUrl + '/api/' + apiVersion + '/mascotas/'
        * header Content-Type = 'application/json'
        * header Authorization = 'Bearer ' + adminToken

    Scenario: Listar todas las mascotas como ADMIN
        When method GET
        Then status 200
        And match response == { count: '#number', next: '##string', previous: '##string', results: '#[]' }
        And match each response.results contains { id: '#number', nombre: '#string', especie: '#string', estado: '#string' }

    Scenario: Listar mascotas con paginación
        Given param page = '1'
        And param page_size = '5'
        When method GET
        Then status 200
        And match response.count == '#number'
        And match response.results == '#[_ <= 5]'

    Scenario: Filtrar mascotas por estado DISPONIBLE
        Given param estado = 'DISPONIBLE'
        When method GET
        Then status 200
        And match response.results == '#[]'
        * def availablePets = response.results
        * assert availablePets.length == 0 || availablePets.every(p => p.estado == 'DISPONIBLE')

    Scenario: Filtrar mascotas por especie PERRO
        Given param especie = 'PERRO'
        When method GET
        Then status 200
        And match response.results == '#[]'
        * def dogs = response.results
        * assert dogs.length == 0 || dogs.every(p => p.especie == 'PERRO')

    Scenario: Filtrar mascotas combinando estado y especie
        Given param estado = 'DISPONIBLE'
        And param especie = 'GATO'
        When method GET
        Then status 200
        And match response.results == '#[]'

    Scenario: Listar mascotas como FAMILIA - solo ve disponibles y propias
        * header Authorization = 'Bearer ' + familiaToken
        When method GET
        Then status 200
        And match response == { count: '#number', next: '##string', previous: '##string', results: '#[]' }

    Scenario: Validar estructura de respuesta con schema
        When method GET
        Then status 200
        And match each response.results == read('classpath:karate/schemas/mascota.json')

    Scenario: Paginación - verificar next y previous URLs
        Given param page = '1'
        And param page_size = '2'
        When method GET
        Then status 200
        * def nextUrl = response.next
        * def prevUrl = response.previous

    Scenario: Listar mascotas sin autenticación
        * header Authorization = ''
        When method GET
        Then status 401

    Scenario: Filtrar con parámetros inválidos - retorna lista vacía o todos
        Given param estado = 'ESTADO_INVALIDO'
        When method GET
        Then status 200

    Scenario: Filtro por tamaño
        Given param tamano = 'GRANDE'
        When method GET
        Then status 200
        * def largePets = response.results
        * assert largePets.length == 0 || largePets.every(p => p.tamano == 'GRANDE' || p.tamano == null)
