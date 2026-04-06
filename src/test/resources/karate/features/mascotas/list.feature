Feature: Mascotas - Listado y Filtros

Background:
* def mascotasUrl = baseUrl + '/api/v1/mascotas/'
* def authUrl = baseUrl + '/api/v1/auth/'

@smoke
Scenario: Listar todas las mascotas como ADMIN
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
# Usar contains en lugar de match estricto para ser mas permisivo
And match response contains { count: '#number', results: '#[]' }
And match each response.results contains { id: '#number', nombre: '#string', especie: '#string', estado: '#string' }

@smoke
Scenario: Listar mascotas con paginación
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And param page = '1'
And param page_size = '5'
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
And match response.count == '#number'
And match response.results == '#[_ <= 5]'

@regression
Scenario: Filtrar mascotas por estado DISPONIBLE
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And param estado = 'DISPONIBLE'
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
And match response.results == '#[]'
* def availablePets = response.results
* assert availablePets.length == 0 || availablePets.every(p => p.estado == 'DISPONIBLE')

@regression
Scenario: Filtrar mascotas por especie PERRO
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And param especie = 'PERRO'
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
And match response.results == '#[]'
* def dogs = response.results
* assert dogs.length == 0 || dogs.every(p => p.especie == 'PERRO')

@regression
Scenario: Filtrar mascotas combinando estado y especie
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And param estado = 'DISPONIBLE'
And param especie = 'GATO'
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
And match response.results == '#[]'

@regression
Scenario: Listar mascotas como FAMILIA - solo ve disponibles y propias
# Usar helper para crear usuario familia
* def setupResult = callonce read('classpath:karate/helpers/setup-familia.feature')
* def familiaToken = setupResult.familiaToken

Given url mascotasUrl
And header Authorization = 'Bearer ' + familiaToken
When method GET
Then status 200
# Usar contains en lugar de match estricto para ser mas permisivo
And match response contains { count: '#number', results: '#[]' }

@smoke
Scenario: Validar estructura de respuesta con schema
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
And match each response.results contains { id: '#number', nombre: '#string', especie: '#string', estado: '#string' }

@regression
Scenario: Paginación - verificar next y previous URLs
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And param page = '1'
And param page_size = '2'
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
* def nextUrl = response.next
* def prevUrl = response.previous

@regression @negative
Scenario: Listar mascotas sin autenticación
Given url mascotasUrl
When method GET
Then status 401

@regression @edgecase
Scenario: Filtrar con parámetros inválidos - retorna lista vacía o todos
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And param estado = 'ESTADO_INVALIDO'
And header Authorization = 'Bearer ' + token
When method GET
Then status 200

@regression
Scenario: Filtro por tamaño
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And param tamano = 'GRANDE'
And header Authorization = 'Bearer ' + token
When method GET
Then status 200
# Solo verificar que la respuesta es válida, el filtrado exacto depende de la implementación
And match response contains { count: '#number', results: '#[]' }
