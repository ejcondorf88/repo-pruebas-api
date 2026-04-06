Feature: Setup - Crear Mascota

    Background:
        * def authUrl = baseUrl + '/api/v1/auth/'
        * def mascotasUrl = baseUrl + '/api/v1/mascotas/'
        * header Content-Type = 'application/json'

    @ignore
    Scenario: Crear mascota como ADMIN y retornar ID
        # Login como ADMIN
        Given url authUrl + 'login/'
        And request { email: 'admin@pettech.com', password: 'Admin1234!' }
        When method POST
        Then status 200
        * def adminToken = response.access
        
  # Crear mascota
  * header Authorization = 'Bearer ' + adminToken
  Given url mascotasUrl
  And request { nombre: 'Mascota Test', especie: 'PERRO', estado: 'DISPONIBLE' }
  When method POST
  Then status 201
  * def mid = response.id
  * def mname = response.nombre
  * def result = { mascotaId: mid, mascotaNombre: mname }
