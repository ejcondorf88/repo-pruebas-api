Feature: Mascotas - Creación

Background:
* def mascotasUrl = baseUrl + '/api/v1/mascotas/'
* def authUrl = baseUrl + '/api/v1/auth/'
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

@smoke
Scenario: Crear mascota como ADMIN - exitoso
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

# Crear mascota
Given url mascotasUrl
And request mascotaRequest
And header Authorization = 'Bearer ' + token
When method POST
Then status 201
And match response contains { id: '#number', nombre: 'Luna', especie: 'PERRO', estado: 'DISPONIBLE' }
And match response contains { registrado_por: '#number', registrado_por_email: '#string' }
And match response contains { fecha_ingreso: '#string', fecha_actualizacion: '#string' }
And match response.foto_url == '##string'
And match response.carnet_vacunas_url == '##string'

@regression @negative
Scenario: Crear mascota como FAMILIA - denegado
# Usar helper para crear usuario familia
* def setupResult = callonce read('classpath:karate/helpers/setup-familia.feature')
* def familiaToken = setupResult.familiaToken

# Intentar crear mascota
Given url mascotasUrl
And request { nombre: 'Test', especie: 'GATO', estado: 'DISPONIBLE' }
And header Authorization = 'Bearer ' + familiaToken
When method POST
Then status 403

@regression @negative
Scenario: Crear mascota sin autenticación
Given url mascotasUrl
And request { nombre: 'Test', especie: 'GATO', estado: 'DISPONIBLE' }
When method POST
Then status 401

@smoke
Scenario: Crear mascota - campos mínimos requeridos
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And request { "nombre": "Test", "especie": "GATO", "estado": "DISPONIBLE" }
And header Authorization = 'Bearer ' + token
When method POST
Then status 201
And match response.nombre == 'Test'

@regression @negative
Scenario: Crear mascota - nombre vacío
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And request { "nombre": "", "especie": "GATO", "estado": "DISPONIBLE" }
And header Authorization = 'Bearer ' + token
When method POST
Then status 400

@regression @negative
Scenario: Crear mascota - especie inválida
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And request { "nombre": "Test", "especie": "ELEFANTE", "estado": "DISPONIBLE" }
And header Authorization = 'Bearer ' + token
When method POST
Then status 400

@regression @negative
Scenario: Crear mascota - estado inválido
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And request { "nombre": "Test", "especie": "GATO", "estado": "EN_ADOPCION" }
And header Authorization = 'Bearer ' + token
When method POST
Then status 400

@regression @edgecase
Scenario: Crear mascota - edad negativa
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

* def invalidRequest = mascotaRequest
* set invalidRequest.edad_anios = -1
Given url mascotasUrl
And request invalidRequest
And header Authorization = 'Bearer ' + token
When method POST
Then status 400

@regression
Scenario: Crear mascota - validar respuesta contiene campos criticos
# Login
Given url authUrl + 'login/'
And request { email: 'admin@pettech.com', password: 'Admin1234!' }
When method POST
Then status 200
* def token = response.access

Given url mascotasUrl
And request mascotaRequest
And header Authorization = 'Bearer ' + token
When method POST
Then status 201
# Solo validar campos criticos, no campos opcionales que pueden ser vacios
And match response contains { id: '#number', nombre: '#string', especie: '#string', estado: '#string' }
And match response contains { registrado_por: '#number', registrado_por_email: '#string' }
And match response contains { fecha_ingreso: '#string', fecha_actualizacion: '#string' }
And match response.foto_url == '##string'
And match response.carnet_vacunas_url == '##string'
